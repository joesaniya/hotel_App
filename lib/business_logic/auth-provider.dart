import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_app/services/api_service.dart';
import 'package:hotel_app/services/google_sign_in_service.dart';
import 'package:hotel_app/services/local_storage_service.dart';
import 'package:hotel_app/services/device_registration_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _visitorToken;
  bool _isLoading = false;

  User? get user => _user;
  String? get visitorToken => _visitorToken;
  bool get isLoading => _isLoading;

  final DeviceRegistrationService _deviceService = DeviceRegistrationService();
  final MyTravalyApiService _apiService = MyTravalyApiService();

  /// Load stored user info on app start
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    final data = await LocalStorageService.getUser();
    if (data != null) {
      _user = FirebaseAuth.instance.currentUser;
      _visitorToken = await LocalStorageService.getVisitorToken();
      log('Loaded user: ${_user?.email}');
      log('Visitor token: $_visitorToken');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sign in with Google and register device
  Future<User?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step 1: Sign in with Google
      final user = await GoogleSignInService.signInWithGoogle();
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      _user = user;
      await LocalStorageService.saveUser(user);
      log('Google sign-in successful: ${user.email}');

      // Step 2: Get device information
      final deviceData = await _deviceService.getDeviceRegistrationData();
      log('Device data collected: $deviceData');

      // Step 3: Register device and get visitor token
      final visitorToken = await _apiService.registerDevice(deviceData);

      if (visitorToken != null) {
        _visitorToken = visitorToken;
        await LocalStorageService.saveVisitorToken(visitorToken);
        log('Visitor token saved: $visitorToken');
      } else {
        log('Warning: Failed to get visitor token');
        // You might want to handle this case - continue anyway or show error
      }

      _isLoading = false;
      notifyListeners();
      return _user;
    } catch (e) {
      log('Error during sign in: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Logout (clear local + Firebase)
  Future<void> signOut() async {
    await GoogleSignInService.signOut();
    await LocalStorageService.clearUser();
    _user = null;
    _visitorToken = null;
    notifyListeners();
  }
}
