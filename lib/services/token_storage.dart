import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey = 'user_type';
  static const String _userEmailKey = 'user_email';

  // Save tokens and user info
  static Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required String userType,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userTypeKey, userType);
    await prefs.setString(_userEmailKey, userEmail);
  }

  // Retrieve tokens and user info
  static Future<Map<String, String?>> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access': prefs.getString(_accessTokenKey),
      'refresh': prefs.getString(_refreshTokenKey),
      'user_type': prefs.getString(_userTypeKey),
      'email': prefs.getString(_userEmailKey),
    };
  }

  // Clear tokens and user info (logout)
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userEmailKey);
  }

  // Check if logged in (access token exists)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey) != null;
  }
}
