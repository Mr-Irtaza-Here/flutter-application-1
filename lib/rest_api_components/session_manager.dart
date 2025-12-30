import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyToken = 'token';
  static const String _keyDisplayName = 'displayName';
  static const String _keyUserData = 'userData';
  static const String _keyClientData = 'clientData';

  // Save session after successful login
  static Future<void> saveSession({
    required String token,
    required String displayName,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? clientData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyDisplayName, displayName);
    
    if (userData != null) {
      await prefs.setString(_keyUserData, jsonEncode(userData));
    }
    if (clientData != null) {
      await prefs.setString(_keyClientData, jsonEncode(clientData));
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Get saved display name
  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisplayName);
  }

  // Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Get saved client data
  static Future<Map<String, dynamic>?> getClientData() async {
    final prefs = await SharedPreferences.getInstance();
    final clientDataString = prefs.getString(_keyClientData);
    if (clientDataString != null) {
      return jsonDecode(clientDataString);
    }
    return null;
  }

  // Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyDisplayName);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyClientData);
  }
}
