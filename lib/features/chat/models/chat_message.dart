import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['sentAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'sentAt': Timestamp.fromDate(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
