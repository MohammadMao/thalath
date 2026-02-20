import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String name;
  final String email;
  final List<String> cards;
  final int cardsCount;
  final String status; // playing, lost
  final int mistakes;
  final DateTime joinedAt;

  Player({
    required this.id,
    required this.name,
    required this.email,
    required this.cards,
    required this.cardsCount,
    required this.status,
    required this.mistakes,
    required this.joinedAt,
  });

  factory Player.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Player(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      cards: List<String>.from((data['cards'] as List?) ?? const []),
      cardsCount: (data['cardsCount'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'playing',
      mistakes: (data['mistakes'] as num?)?.toInt() ?? 0,
      joinedAt:
          (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'cards': cards,
      'cardsCount': cardsCount,
      'status': status,
      'mistakes': mistakes,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? cards,
    int? cardsCount,
    String? status,
    int? mistakes,
    DateTime? joinedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cards: cards ?? this.cards,
      cardsCount: cardsCount ?? this.cardsCount,
      status: status ?? this.status,
      mistakes: mistakes ?? this.mistakes,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
