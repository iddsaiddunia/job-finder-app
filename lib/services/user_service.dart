import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'token_storage.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final loginData = await TokenStorage.getLoginData();
    final token = loginData['access'];
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get job seeker profile (matches /auth/seeker/profile/)
  Future<Map<String, dynamic>> getJobSeekerProfile() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/profile/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Job seeker profile not found');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job seeker profile: $e');
    }
  }

  // Update job seeker profile (matches /auth/seeker/profile/update/)
  Future<Map<String, dynamic>> updateJobSeekerProfile(Map<String, dynamic> profileData) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/profile/update/');
      final headers = await _getHeaders();
      
      print('Updating profile at: $url');
      print('Headers: $headers');
      print('Profile data: $profileData');
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(profileData),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Include response body in error for better debugging
        String errorMessage = 'Failed to update profile: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage += ' - ${errorBody.toString()}';
        } catch (_) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('UserService error: $e');
      throw Exception('Error updating job seeker profile: $e');
    }
  }

  // Get recruiter profile (matches /auth/recruiter/profile/)
  Future<Map<String, dynamic>> getRecruiterProfile() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/recruiter/profile/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Recruiter profile not found');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recruiter profile: $e');
    }
  }

  // Update recruiter profile (matches /auth/recruiter/profile/update/)
  Future<Map<String, dynamic>> updateRecruiterProfile(Map<String, dynamic> profileData) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/recruiter/profile/update/');
      final headers = await _getHeaders();
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(profileData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Include response body in error for better debugging
        String errorMessage = 'Failed to update profile: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage += ' - ${errorBody.toString()}';
        } catch (_) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error updating recruiter profile: $e');
    }
  }

  // Mark job seeker profile as updated (matches /auth/seeker/mark-profile-updated/)
  Future<Map<String, dynamic>> markJobSeekerProfileUpdated() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/mark-profile-updated/');
      final headers = await _getHeaders();
      
      final response = await http.post(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to mark profile as updated: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking job seeker profile as updated: $e');
    }
  }

  // Mark recruiter profile as updated (matches /auth/recruiter/mark-profile-updated/)
  Future<Map<String, dynamic>> markRecruiterProfileUpdated() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/recruiter/mark-profile-updated/');
      final headers = await _getHeaders();
      
      final response = await http.post(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to mark profile as updated: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking recruiter profile as updated: $e');
    }
  }

  // Create feedback for job seeker (matches /auth/seeker/feedback/)
  Future<Map<String, dynamic>> createSeekerFeedback({
    required int seekerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/feedback/');
      final headers = await _getHeaders();
      
      final feedbackData = {
        'seeker': seekerId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(feedbackData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating seeker feedback: $e');
    }
  }


  // Get feedback for a job seeker (matches /auth/seeker/{seeker_id}/feedbacks/)
  Future<List<Map<String, dynamic>>> getSeekerFeedbacks(int seekerId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/$seekerId/feedbacks/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch feedbacks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching seeker feedbacks: $e');
    }
  }

  // Helper method to get user profile based on user type
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final loginData = await TokenStorage.getLoginData();
      final userType = loginData['user_type'];
      
      if (userType == 'seeker') {
        return await getJobSeekerProfile();
      } else if (userType == 'recruiter') {
        return await getRecruiterProfile();
      } else {
        throw Exception('Unknown user type: $userType');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  // Helper method to update user profile based on user type
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final loginData = await TokenStorage.getLoginData();
      final userType = loginData['user_type'];
      
      if (userType == 'seeker') {
        return await updateJobSeekerProfile(profileData);
      } else if (userType == 'recruiter') {
        return await updateRecruiterProfile(profileData);
      } else {
        throw Exception('Unknown user type: $userType');
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Helper method to mark profile as updated based on user type
  Future<Map<String, dynamic>> markProfileUpdated() async {
    try {
      final loginData = await TokenStorage.getLoginData();
      final userType = loginData['user_type'];
      
      if (userType == 'seeker') {
        return await markJobSeekerProfileUpdated();
      } else if (userType == 'recruiter') {
        return await markRecruiterProfileUpdated();
      } else {
        throw Exception('Unknown user type: $userType');
      }
    } catch (e) {
      throw Exception('Error marking profile as updated: $e');
    }
  }

  // Toggle job seeker availability (matches /api/seeker/toggle-availability/)
  Future<Map<String, dynamic>> toggleAvailability() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/seeker/toggle-availability/');
      final headers = await _getHeaders();
      
      final response = await http.post(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('Not authorized to toggle availability');
      } else {
        throw Exception('Failed to toggle availability: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling availability: $e');
    }
  }

  // Helper method to get user name from profile
  Future<String> getUserName() async {
    try {
      final profile = await getUserProfile();
      final loginData = await TokenStorage.getLoginData();
      final userType = loginData['user_type'];
      
      if (userType == 'seeker') {
        return profile['full_name'] ?? 'Job Seeker';
      } else if (userType == 'recruiter') {
        return profile['company_name'] ?? 'Recruiter';
      } else {
        // Fallback to email prefix
        final email = loginData['email'] ?? '';
        return email.split('@').first;
      }
    } catch (e) {
      // Fallback to email prefix if profile fetch fails
      try {
        final loginData = await TokenStorage.getLoginData();
        final email = loginData['email'] ?? '';
        return email.split('@').first;
      } catch (_) {
        return 'User';
      }
    }
  }

  // Upload profile picture (matches /auth/seeker/profile/picture/)
  Future<Map<String, dynamic>> uploadProfilePicture(File image) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/profile/picture/');
      final headers = await _getHeaders();
      
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'profile_picture',
        await image.readAsBytes(),
        filename: image.path.split('/').last,
      ));
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        throw Exception('Failed to upload profile picture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  // Upload resume (matches /auth/seeker/resume/)
  Future<Map<String, dynamic>> uploadResume(File resume) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/seeker/resume/');
      final headers = await _getHeaders();
      
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'resume',
        await resume.readAsBytes(),
        filename: resume.path.split('/').last,
      ));
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        throw Exception('Failed to upload resume: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading resume: $e');
    }
  }
}
