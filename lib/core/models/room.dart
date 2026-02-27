import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String createdBy;
  final String status; // waiting, playing, finished
  final String currentWord;
  final String currentTurn; // player ID whose turn it is
  final int maxPlayers;
  final int playerCount; // denormalized counter
  final List<String> playerIds; // denormalized for lobby join checks
  final int wordCount; // number of valid plays so far
  final List<String> winnerIds; // supports multiple winners (word-limit scenario)
  final DateTime turnStartedAt;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime? finishedAt;

  Room({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.status,
    required this.currentWord,
    required this.currentTurn,
    required this.maxPlayers,
    required this.playerCount,
    required this.playerIds,
    required this.wordCount,
    required this.winnerIds,
    required this.turnStartedAt,
    required this.winnerId,
    required this.createdAt,
    required this.finishedAt,
  });

  factory Room.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Room(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      status: data['status'] as String? ?? 'waiting',
      currentWord: data['currentWord'] as String? ?? '',
      currentTurn: data['currentTurn'] as String? ?? '',
      maxPlayers: (data['maxPlayers'] as num?)?.toInt() ?? 4,
      playerCount: (data['playerCount'] as num?)?.toInt() ?? 0,
      playerIds: List<String>.from(data['playerIds'] as List? ?? []),
      wordCount: (data['wordCount'] as num?)?.toInt() ?? 0,
      winnerIds: List<String>.from(data['winnerIds'] as List? ?? []),
      turnStartedAt:
          (data['turnStartedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      winnerId: data['winnerId'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'status': status,
      'currentWord': currentWord,
      'currentTurn': currentTurn,
      'maxPlayers': maxPlayers,
      'playerCount': playerCount,
      'playerIds': playerIds,
      'wordCount': wordCount,
      'winnerIds': winnerIds,
      'turnStartedAt': Timestamp.fromDate(turnStartedAt),
      'winnerId': winnerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
    };
  }

  Room copyWith({
    String? id,
    String? name,
    String? createdBy,
    String? status,
    String? currentWord,
    String? currentTurn,
    int? maxPlayers,
    int? playerCount,
    List<String>? playerIds,
    int? wordCount,
    List<String>? winnerIds,
    DateTime? turnStartedAt,
    String? winnerId,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      currentWord: currentWord ?? this.currentWord,
      currentTurn: currentTurn ?? this.currentTurn,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      playerCount: playerCount ?? this.playerCount,
      playerIds: playerIds ?? this.playerIds,
      wordCount: wordCount ?? this.wordCount,
      winnerIds: winnerIds ?? this.winnerIds,
      turnStartedAt: turnStartedAt ?? this.turnStartedAt,
      winnerId: winnerId ?? this.winnerId,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}
