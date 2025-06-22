import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'token_storage.dart';

class JobService {
  static final JobService _instance = JobService._internal();
  factory JobService() => _instance;
  JobService._internal();

  // Get authorization headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final loginData = await TokenStorage.getLoginData();
    final token = loginData['access'];
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all jobs (matches /api/jobs/)
  Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  // Get recommended jobs for current user (matches /api/jobs/recommended/)
  Future<List<Map<String, dynamic>>> getRecommendedJobs() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/recommended/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        throw Exception('Only job seekers can get recommendations');
      } else {
        throw Exception('Failed to fetch recommended jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommended jobs: $e');
    }
  }

  // Create a new job (matches /api/jobs/create/)
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/create/');
      final headers = await _getHeaders();
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(jobData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  // Get user's applications (matches /api/applications/)
  Future<List<Map<String, dynamic>>> getApplications() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch applications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching applications: $e');
    }
  }

  // Apply for a job (matches /api/applications/create/)
  Future<Map<String, dynamic>> applyForJob({
    required int jobId,
    String? coverLetter,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/create/');
      final headers = await _getHeaders();
      
      final applicationData = {
        'job': jobId,
        if (coverLetter != null && coverLetter.isNotEmpty) 'cover_letter': coverLetter,
      };
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(applicationData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to apply for job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error applying for job: $e');
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
        throw Exception('Only job seekers can toggle availability');
      } else {
        throw Exception('Failed to toggle availability: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling availability: $e');
    }
  }

  // Get candidate recommendations for a job (matches /api/jobs/{job_id}/candidates/)
  Future<List<Map<String, dynamic>>> getCandidateRecommendations(int jobId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/$jobId/candidates/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        throw Exception('Only recruiters can get candidate recommendations');
      } else if (response.statusCode == 404) {
        throw Exception('Job not found or not owned by recruiter');
      } else {
        throw Exception('Failed to fetch candidate recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching candidate recommendations: $e');
    }
  }

  // Update job next step (matches /api/jobs/{pk}/update-next-step/)
  Future<Map<String, dynamic>> updateJobNextStep(int jobId, Map<String, dynamic> updateData) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/$jobId/update-next-step/');
      final headers = await _getHeaders();
      
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(updateData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update job next step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating job next step: $e');
    }
  }

  // Set application next step (matches /api/applications/{pk}/next-step/)
  Future<Map<String, dynamic>> setApplicationNextStep({
    required int applicationId,
    required String nextStepType,
    int? jobDurationDays,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/$applicationId/next-step/');
      final headers = await _getHeaders();
      
      final requestData = {
        'next_step_type': nextStepType,
        if (jobDurationDays != null) 'job_duration_days': jobDurationDays,
      };
      
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to set application next step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error setting application next step: $e');
    }
  }

  // Approve/decline application next step (matches /api/applications/{pk}/approve-next-step/)
  Future<Map<String, dynamic>> approveApplicationNextStep({
    required int applicationId,
    required bool approve,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/$applicationId/approve-next-step/');
      final headers = await _getHeaders();
      
      final requestData = {'approve': approve};
      
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to approve application next step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving application next step: $e');
    }
  }

  // Get dashboard statistics from backend (matches /api/dashboard/stats/)
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/dashboard/stats/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('Only job seekers can access dashboard stats');
      } else {
        throw Exception('Failed to fetch dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }
}
