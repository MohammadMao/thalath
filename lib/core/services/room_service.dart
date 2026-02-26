import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';
import '../models/player.dart';
import '../../features/chat/models/chat_message.dart';

class RoomService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RoomService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _players(String roomId) =>
      _rooms.doc(roomId).collection('players');

  CollectionReference<Map<String, dynamic>> _messages(String roomId) =>
      _rooms.doc(roomId).collection('messages');


  // Create a room and add the creator as the first player.
  Future<String> createRoom({String? name, int? maxPlayers}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('no-user');
    }

    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : 'غرفة';
    final resolvedMaxPlayers = (maxPlayers != null && maxPlayers > 0)
        ? maxPlayers
        : 4;

    final roomDoc = _rooms.doc();
    final userDoc = _users.doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDoc);
      final userData = userSnapshot.data();
      final userName = (userData?['name'] as String?) ?? '';

      transaction.set(roomDoc, {
        'name': resolvedName,
        'createdBy': user.uid,
        'status': 'waiting',
        'currentWord': 'كتب',
        'currentTurn': '',
        'maxPlayers': resolvedMaxPlayers,
        'winnerId': null,
        'createdAt': Timestamp.now(),
        'finishedAt': null,
      });

      transaction.set(roomDoc.collection('players').doc(user.uid), {
        'name': userName,
        'email': user.email ?? '',
        'cardsCount': 0,
        'status': 'playing',
        'mistakes': 0,
        'score': 0,
        'joinedAt': Timestamp.now(),
      });

      transaction.set(roomDoc.collection('messages').doc('messageId'), {
        'senderId': user.uid,
        'senderName': userName,
        'sentAt': Timestamp.now(),
        'text': '',
      });
    });

    return roomDoc.id;
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

  // Ensure current user has a player document in the room.
  Future<void> ensurePlayerInRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('no-user');
    }

    final playerRef = _players(roomId).doc(user.uid);
    final userRef = _users.doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final playerSnapshot = await transaction.get(playerRef);
      if (playerSnapshot.exists) {
        return;
      }

      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data();
      final userName = (userData?['name'] as String?) ?? '';

      transaction.set(playerRef, {
        'name': userName,
        'email': user.email ?? '',
        'cardsCount': 0,
        'status': 'playing',
        'mistakes': 0,
        'score': 0,
        'joinedAt': Timestamp.now(),
      });
    });
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

  // Start game: set status to playing, assign cards, and set current turn.
  Future<void> startGame(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('no-user');
    }

    final roomRef = _rooms.doc(roomId);
    final playersQuery = _players(roomId).orderBy('joinedAt');

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      if (!roomSnapshot.exists) {
        throw StateError('room-not-found');
      }

      final roomData = roomSnapshot.data() ?? <String, dynamic>{};
      if ((roomData['createdBy'] as String?) != user.uid) {
        throw StateError('not-authorized');
      }

      if ((roomData['status'] as String?) == 'playing') {
        return;
      }

      final playersSnapshot = await playersQuery.get();
      if (playersSnapshot.docs.length < 2) {
        throw StateError('not-enough-players');
      }

      final firstPlayerId = playersSnapshot.docs.first.id;

      for (final playerDoc in playersSnapshot.docs) {
        transaction.update(playerDoc.reference, {
          'cardsCount': 15,
          'status': 'playing',
          'mistakes': 0,
        });
      }

      final currentWord = (roomData['currentWord'] as String?) ?? '';
      transaction.update(roomRef, {
        'status': 'playing',
        'currentTurn': firstPlayerId,
        'currentWord': currentWord.isNotEmpty ? currentWord : 'كتب',
        'winnerId': null,
        'finishedAt': null,
      });
    });
  }

  // Replay a room - reset game state, increment winner score, keep players & messages
  Future<void> replayRoom(String roomId) async {
    final room = await getRoom(roomId);
    if (room == null) {
      throw StateError('room-not-found');
    }

    await _firestore.runTransaction((transaction) async {
      // Reset room fields
      transaction.update(_rooms.doc(roomId), {
        'status': 'waiting',
        'currentWord': '',
        'currentTurn': '',
        'winnerId': null,
        'finishedAt': null,
      });

      // If there was a winner, increment their score
      if (room.winnerId != null && room.winnerId!.isNotEmpty) {
        final winnerRef = _players(roomId).doc(room.winnerId);
        final winnerDoc = await transaction.get(winnerRef);
        if (winnerDoc.exists) {
          final currentScore = (winnerDoc.data()?['score'] as num?)?.toInt() ?? 0;
          transaction.update(winnerRef, {'score': currentScore + 1});
        }
      }

      // Reset all players' game state (cards, mistakes, status)
      final playersSnapshot = await _players(roomId).get();
      for (final playerDoc in playersSnapshot.docs) {
        transaction.update(playerDoc.reference, {
          'cardsCount': 0,
          'status': 'playing',
          'mistakes': 0,
        });
      }
    });
  }

  // Delete a room and all its subcollections (players and messages)
  Future<void> deleteRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('no-user');
    }

    final room = await getRoom(roomId);
    if (room == null) {
      throw StateError('room-not-found');
    }

    if (room.createdBy != user.uid) {
      throw StateError('not-authorized');
    }

    // Delete messages subcollection
    final messagesSnapshot = await _messages(roomId).get();
    final messageBatch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      messageBatch.delete(doc.reference);
    }
    await messageBatch.commit();

    // Delete players subcollection
    final playersSnapshot = await _players(roomId).get();
    final playersBatch = _firestore.batch();
    for (final doc in playersSnapshot.docs) {
      playersBatch.delete(doc.reference);
    }
    await playersBatch.commit();

    // Delete room document
    await _rooms.doc(roomId).delete();
  }

  /// Play a card: atomically update currentWord, currentTurn, and player's cardsCount.
  Future<void> playCard({
    required String roomId,
    required String playerId,
    required String newWord,
    required int newCardsCount,
    required String nextTurnPlayerId,
  }) async {
    final roomRef = _rooms.doc(roomId);
    final playerRef = _players(roomId).doc(playerId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(roomRef, {
        'currentWord': newWord,
        'currentTurn': nextTurnPlayerId,
        'turnStartedAt': Timestamp.now(),
      });

      transaction.update(playerRef, {
        'cardsCount': newCardsCount,
      });
    });
  }

  /// Advance the turn without changing the word (e.g. when 3 mistakes reached).
  Future<void> advanceTurn({
    required String roomId,
    required String nextTurnPlayerId,
  }) async {
    await _rooms.doc(roomId).update({
      'currentTurn': nextTurnPlayerId,
      'turnStartedAt': Timestamp.now(),
    });
  }

  /// Mark the current player as lost and advance to the next player.
  Future<void> loseAndAdvanceTurn({
    required String roomId,
    required String playerId,
    required int newCardsCount,
    required String nextTurnPlayerId,
  }) async {
    final roomRef = _rooms.doc(roomId);
    final playerRef = _players(roomId).doc(playerId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(playerRef, {
        'status': 'lost',
        'cardsCount': newCardsCount,
      });
      transaction.update(roomRef, {
        'currentTurn': nextTurnPlayerId,
        'turnStartedAt': Timestamp.now(),
      });
    });
  }

  /// Draw a card: update player cardsCount and advance turn.
  Future<void> drawCard({
    required String roomId,
    required String playerId,
    required int newCardsCount,
    required String nextTurnPlayerId,
  }) async {
    final roomRef = _rooms.doc(roomId);
    final playerRef = _players(roomId).doc(playerId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(playerRef, {
        'cardsCount': newCardsCount,
      });
      transaction.update(roomRef, {
        'currentTurn': nextTurnPlayerId,
        'turnStartedAt': Timestamp.now(),
      });
    });
  }
}
