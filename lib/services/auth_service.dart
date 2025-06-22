import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'token_storage.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Login
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login/');
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  // Register Job Seeker
  Future<Map<String, dynamic>> registerSeeker({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/signup/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_parseError(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register Recruiter
  Future<Map<String, dynamic>> registerRecruiter({
    required String email,
    required String password,
    required String companyName,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/recruiter/signup/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'company_name': companyName,
        }),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_parseError(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<bool> logout() async {
    final loginData = await TokenStorage.getLoginData();
    final refreshToken = loginData['refresh'];
    
    if (refreshToken == null) {
      await TokenStorage.clearLoginData();
      return true;
    }
    
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/logout/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${loginData['access']}',
        },
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      await TokenStorage.clearLoginData();
      return response.statusCode == 200;
    } catch (e) {
      await TokenStorage.clearLoginData();
      return false;
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isLoggedIn();
  }

  // Get stored user data
  static Future<Map<String, String?>> getCurrentUser() async {
    return await TokenStorage.getLoginData();
  }

  // Parse error message from backend
  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      } else if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      } else if (data is Map && data.containsKey('non_field_errors')) {
        return data['non_field_errors'][0].toString();
      }
      return response.body;
    } catch (_) {
      return 'An error occurred (${response.statusCode})';
    }
  }

}
