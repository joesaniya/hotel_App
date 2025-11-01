import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_app/services/google_sign_in_service.dart';
import 'package:hotel_app/services/local_storage_service.dart';


class AuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  /// Load stored user info on app start
  Future<void> loadUser() async {
    final data = await LocalStorageService.getUser();
    if (data != null) {
      // Only local data (for display)
      _user = FirebaseAuth.instance.currentUser;
      log('loaded user: ${_user?.email}');
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    final user = await GoogleSignInService.signInWithGoogle();
    if (user != null) {
      _user = user;
      await LocalStorageService.saveUser(user);
      notifyListeners();
    }
    return _user;
  }

  /// Logout (clear local + Firebase)
  Future<void> signOut() async {
    await GoogleSignInService.signOut();
    await LocalStorageService.clearUser();
    _user = null;
    notifyListeners();
  }
}
