class Player {
  final String id;
  final String name;
  final List<String> cards;
  final int cardsCount;
  final String status; // playing, lost, observer
  final bool isReady;
  final int mistakes; // Track mistakes in current turn
  final DateTime joinedAt;

  Player({
    required this.id,
    required this.name,
    required this.cards,
    required this.cardsCount,
    required this.status,
    this.isReady = false,
    this.mistakes = 0,
    required this.joinedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      cards: List<String>.from(json['cards'] as List),
      cardsCount: json['cardsCount'] as int,
      status: json['status'] as String,
      isReady: json['isReady'] as bool? ?? false,
      mistakes: json['mistakes'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cards': cards,
      'cardsCount': cardsCount,
      'status': status,
      'isReady': isReady,
      'mistakes': mistakes,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    List<String>? cards,
    int? cardsCount,
    String? status,
    bool? isReady,
    int? mistakes,
    DateTime? joinedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      cards: cards ?? this.cards,
      cardsCount: cardsCount ?? this.cardsCount,
      status: status ?? this.status,
      isReady: isReady ?? this.isReady,
      mistakes: mistakes ?? this.mistakes,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
