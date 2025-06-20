import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'token_storage.dart';

class AuthService {
  // Singleton pattern (optional)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Login
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final url = Uri.parse('${ApiConstants.BASE_URL}/auth/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save tokens and user info for persistence
      await TokenStorage.saveLoginData(
        accessToken: data['access'],
        refreshToken: data['refresh'],
        userType: data['user_type'],
        userEmail: data['email'],
      );
      return data;
    } else {
      throw Exception(_parseError(response));
    }
  }

  // Register Job Seeker
  Future<Map<String, dynamic>> registerSeeker({required String email, required String password, required String fullName}) async {
    final url = Uri.parse('${ApiConstants.BASE_URL}/auth/seeker/signup/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'full_name': fullName}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_parseError(response));
    }
  }

  // Register Recruiter
  Future<Map<String, dynamic>> registerRecruiter({required String email, required String password, required String companyName}) async {
    final url = Uri.parse('${ApiConstants.BASE_URL}/auth/recruiter/signup/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'company_name': companyName}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_parseError(response));
    }
  }

  // Logout: clear tokens and user info
  Future<void> logout() async {
    await TokenStorage.clearLoginData();
  }

  // Check if logged in (access token exists)
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isLoggedIn();
  }

  // Utility: parse error message from backend
  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      } else if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return response.body;
    } catch (_) {
      return 'Unknown error: ${response.statusCode}';
    }
  }
}
