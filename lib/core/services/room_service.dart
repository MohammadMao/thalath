import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../models/player.dart';
import '../../features/chat/models/chat_message.dart';

class RoomService {
  final FirebaseFirestore _firestore;

  RoomService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  CollectionReference<Map<String, dynamic>> _players(String roomId) =>
      _rooms.doc(roomId).collection('players');

  CollectionReference<Map<String, dynamic>> _messages(String roomId) =>
      _rooms.doc(roomId).collection('messages');

  // Create a room document and return its id.
  Future<String> createRoom(Room room) async {
    final doc = room.id.isEmpty ? _rooms.doc() : _rooms.doc(room.id);
    final data = room.copyWith(id: doc.id).toFirestore();
    await doc.set(data);
    return doc.id;
  }

  // Update fields on a room document.
  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _rooms.doc(roomId).update(data);
  }

  // Fetch a room once by id.
  Future<Room?> getRoom(String roomId) async {
    final doc = await _rooms.doc(roomId).get();
    if (!doc.exists) {
      return null;
    }
    return Room.fromFirestore(doc);
  }

  // Stream a room document by id.
  Stream<Room> streamRoom(String roomId) {
    return _rooms.doc(roomId).snapshots().map(Room.fromFirestore);
  }

  // Stream rooms ordered by creation time.
  Stream<List<Room>> streamRooms() {
    return _rooms
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Room.fromFirestore).toList());
  }

  // Add or replace a player in a room.
  Future<void> addPlayer(String roomId, Player player) async {
    await _players(roomId).doc(player.id).set(player.toFirestore());
  }

  // Update fields on a player document in a room.
  Future<void> updatePlayer(
    String roomId,
    String playerId,
    Map<String, dynamic> data,
  ) async {
    await _players(roomId).doc(playerId).update(data);
  }

  // Stream players in a room ordered by join time.
  Stream<List<Player>> streamPlayers(String roomId) {
    return _players(roomId)
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Player.fromFirestore).toList());
  }

  // Add a chat message to a room.
  Future<void> addMessage(String roomId, ChatMessage message) async {
    final doc = _messages(roomId).doc();
    await doc.set(message.copyWith(id: doc.id).toFirestore());
  }

  // Stream chat messages in a room ordered by creation time.
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    return _messages(roomId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatMessage.fromFirestore).toList());
  }
}
