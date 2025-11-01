import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocalStorageService {
  static const _userKey = 'google_user';

  /// Save user details locally
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = {
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'uid': user.uid,
    };
    await prefs.setString(_userKey, jsonEncode(userMap));
  }

  /// Load user details
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  /// Clear stored user data
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
