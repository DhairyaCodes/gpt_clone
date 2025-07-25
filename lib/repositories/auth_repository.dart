import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gpt_clone/providers/auth_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  Future<User?> signInWithGoogle() async {
    try {
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("Anonymous sign-in error: ${e.message}");
      return null;
    }
  }

  Future<void> signInWithApple() async {
    // Apple sign-in logic will go here
  }

  Future<void> signInWithMicrosoft() async {
    // Microsoft sign-in logic will go here
  }
}
