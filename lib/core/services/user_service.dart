import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserService extends GetxService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final RxnString displayName = RxnString();

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // Update cached display name locally.
  void setDisplayName(String name) {
    displayName.value = name.trim();
  }

  // Fetch user name from Firestore and cache it.
  Future<String?> fetchUserName() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data() ?? {};
    final name = data['name'] as String?;
    if (name != null && name.isNotEmpty) {
      displayName.value = name;
    }
    return name;
  }

  // Create user document in Firestore and cache the name.
  Future<void> createUserDocument({required String name}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('no-user');
    }

    await _users.doc(user.uid).set({
      'name': name.trim(),
      'email': user.email ?? '',
      'createdAt': Timestamp.now(),
    });

    displayName.value = name.trim();
  }

  // Ensure user document exists; if missing, requires cached name.
  Future<void> ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('no-user');
    }

    final doc = await _users.doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data() ?? {};
      final name = data['name'] as String?;
      if (name != null && name.isNotEmpty) {
        displayName.value = name;
      }
      return;
    }

    final name = displayName.value;
    if (name == null || name.trim().isEmpty) {
      throw StateError('missing-display-name');
    }

    await _users.doc(user.uid).set({
      'name': name.trim(),
      'email': user.email ?? '',
      'createdAt': Timestamp.now(),
    });
  }
}
