import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String name;
  final String email;
  final int cardsCount;
  final String status; // playing, lost
  final int mistakes;
  final int score;
  final DateTime joinedAt;

  Player({
    required this.id,
    required this.name,
    required this.email,
    required this.cardsCount,
    required this.status,
    required this.mistakes,
    required this.score,
    required this.joinedAt,
  });

  factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Player(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      cardsCount: (data['cardsCount'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'playing',
      mistakes: (data['mistakes'] as num?)?.toInt() ?? 0,
      score: (data['score'] as num?)?.toInt() ?? 0,
      joinedAt:
          (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'cardsCount': cardsCount,
      'status': status,
      'mistakes': mistakes,
      'score': score,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? email,
    int? cardsCount,
    String? status,
    int? mistakes,
    int? score,
    DateTime? joinedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cardsCount: cardsCount ?? this.cardsCount,
      status: status ?? this.status,
      mistakes: mistakes ?? this.mistakes,
      score: score ?? this.score,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
