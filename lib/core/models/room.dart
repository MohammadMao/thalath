class Room {
  final String id;
  final String status; // waiting, playing, finished
  final String currentWord;
  final String currentTurn; // player ID whose turn it is
  final List<String> playerIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Room({
    required this.id,
    required this.status,
    required this.currentWord,
    required this.currentTurn,
    required this.playerIds,
    required this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      status: json['status'] as String,
      currentWord: json['currentWord'] as String,
      currentTurn: json['currentTurn'] as String,
      playerIds: List<String>.from(json['playerIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'currentWord': currentWord,
      'currentTurn': currentTurn,
      'playerIds': playerIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Room copyWith({
    String? id,
    String? status,
    String? currentWord,
    String? currentTurn,
    List<String>? playerIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      status: status ?? this.status,
      currentWord: currentWord ?? this.currentWord,
      currentTurn: currentTurn ?? this.currentTurn,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
