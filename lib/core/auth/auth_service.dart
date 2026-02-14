import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable user state
  Rx<User?> firebaseUser = Rx<User?>(null);

  // Getters
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ أثناء تسجيل الدخول';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'البريد الإلكتروني غير مسجل';
          break;
        case 'wrong-password':
          message = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صالح';
          break;
        case 'user-disabled':
          message = 'هذا الحساب معطل';
          break;
        case 'too-many-requests':
          message = 'محاولات كثيرة، حاول لاحقاً';
          break;
        case 'invalid-credential':
          message = 'البيانات غير صحيحة';
          break;
      }
      
      throw message;
    } catch (e) {
      throw 'حدث خطأ غير متوقع';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'حدث خطأ أثناء تسجيل الخروج';
    }
  }

  // Check if user is authenticated
  Future<bool> checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _auth.currentUser != null;
  }
}
