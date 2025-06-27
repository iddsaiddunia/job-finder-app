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
    print('Auth token retrieved: ${token != null ? 'Token exists' : 'Token is null'}');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('Request headers: $headers');
    return headers;
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

  // This method was removed as we already have getJobDetails

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
      // Use the correct endpoint for job creation
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/create/');
      final headers = await _getHeaders();
      
      print('Sending job data to: $url');
      print('Job data: ${jsonEncode(jobData)}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(jobData),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create job: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  // Get employer's job postings
  Future<List<Map<String, dynamic>>> getEmployerJobs() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/employer/');
      final headers = await _getHeaders();
      
      print('Fetching employer jobs from: $url');
      final response = await http.get(url, headers: headers);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jobsJson = jsonDecode(response.body);
        return jobsJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch employer jobs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching employer jobs: $e');
      throw Exception('Error fetching employer jobs: $e');
    }
  }
  
  // Get application details by ID
  Future<Map<String, dynamic>> getApplicationDetails(int applicationId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/$applicationId/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch application details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching application details: $e');
    }
  }

  // Get job details by ID
  Future<Map<String, dynamic>> getJobDetails(int jobId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/$jobId/');
      final headers = await _getHeaders();
      
      print('Fetching job details from: $url');
      final response = await http.get(url, headers: headers);
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jobData = jsonDecode(response.body);
        return jobData;
      } else {
        throw Exception('Failed to fetch job details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching job details: $e');
      throw Exception('Error fetching job details: $e');
    }
  }

  // Get applicants for a specific job
  Future<Map<String, dynamic>> getJobApplicants(int jobId) async {
    try {
      // Get all applicants for this job
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/$jobId/applicants/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch job applicants: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching job applicants: $e');
      throw Exception('Error fetching job applicants: $e');
    }
  }

  // Get all applications for a specific job
  Future<List<Map<String, dynamic>>> getJobApplications(int jobId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/jobs/$jobId/applications/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch job applications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching job applications: $e');
      throw Exception('Error fetching job applications: $e');
    }
  }
  
  // Get user's applications (matches /api/applications/)
  Future<List<Map<String, dynamic>>> getApplications() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      print('Applications API response status: ${response.statusCode}');
      print('Applications API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Handle both array and object response formats
        final dynamic responseData = jsonDecode(response.body);
        
        if (responseData is List) {
          // If the response is already a list, use it directly
          return responseData.cast<Map<String, dynamic>>();
        } else if (responseData is Map) {
          // If the response is an object with a results field (common Django REST pattern)
          if (responseData.containsKey('results') && responseData['results'] is List) {
            return (responseData['results'] as List).cast<Map<String, dynamic>>();
          }
          // If it's some other kind of object response, return an empty list
          return [];
        }
        // Default to empty list for any other response format
        return [];
      } else if (response.statusCode == 204) {
        // No content means no applications
        return [];
      } else {
        throw Exception('Failed to fetch applications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getApplications: $e');
      // Return empty list instead of throwing to avoid crashes
      return [];
    }
  }

  // Apply for a job (matches /api/applications/create/)
  // Check if user has already applied for a job
  Future<bool> hasAppliedForJob(int jobId) async {
    try {
      // Get all applications for the current user
      final applications = await getApplications();
      print('Checking applications for job ID: $jobId');
      print('Found ${applications.length} total applications');
      
      // Check if any application is for the specified job
      for (var application in applications) {
        if (application['job'] != null) {
          print('Application job ID: ${application['job']['id']}');
          if (application['job']['id'] == jobId) {
            print('Found existing application for job ID: $jobId');
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error checking application status: $e');
      return false; // Default to false if there's an error
    }
  }

  Future<Map<String, dynamic>> applyForJob({
    required int jobId,
    String? coverLetter,
  }) async {
    try {
      print('Attempting to apply for job ID: $jobId');
      
      // First check if the user has already applied
      final alreadyApplied = await hasAppliedForJob(jobId);
      if (alreadyApplied) {
        print('User has already applied for job ID: $jobId');
        throw Exception('You have already applied for this job');
      }
      
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/create/');
      final headers = await _getHeaders();
      
      final applicationData = {
        'job': jobId,
        if (coverLetter != null && coverLetter.isNotEmpty) 'cover_letter': coverLetter,
      };
      
      print('Sending application data: $applicationData');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(applicationData),
      );
      
      print('Application response status: ${response.statusCode}');
      print('Application response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        // Try to parse the error message from the response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            throw Exception(errorData['detail']);
          }
        } catch (_) {}
        throw Exception('Failed to apply for job: Bad request');
      } else {
        throw Exception('Failed to apply for job: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in applyForJob: $e');
      if (e is Exception) {
        throw e;
      }
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
    String? recruiterNotes,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/$applicationId/next-step/');
      final headers = await _getHeaders();
      
      final requestData = {
        'next_step_type': nextStepType,
        if (jobDurationDays != null) 'job_duration_days': jobDurationDays,
        if (recruiterNotes != null && recruiterNotes.isNotEmpty) 'recruiter_notes': recruiterNotes,
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
  
  // Get recruiter dashboard statistics from backend (matches /api/dashboard/recruiter-stats/)
  Future<Map<String, dynamic>> getRecruiterDashboardStats() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/dashboard/recruiter-stats/');
      final loginData = await TokenStorage.getLoginData();
      final token = loginData['access'];
      
      print('DEBUG: Token for recruiter stats: $token'); // Debug log
      
      if (token == null) {
        throw Exception('Authentication token is missing');
      }
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      print('DEBUG: Making request to $url with headers: $headers'); // Debug log
      
      final response = await http.get(url, headers: headers);
      
      print('DEBUG: Response status: ${response.statusCode}'); // Debug log
      print('DEBUG: Response body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 403) {
        throw Exception('Only recruiters can access dashboard stats');
      } else {
        throw Exception('Failed to fetch recruiter dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error in getRecruiterDashboardStats: $e'); // Debug log
      throw Exception('Error fetching recruiter dashboard stats: $e');
    }
  }
  
  // Submit feedback and rating for an applicant
  Future<Map<String, dynamic>> submitApplicantFeedback({
    required int applicationId,
    required int profileId,
    required double rating,
    required String comment,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/$applicationId/feedback/');
      final headers = await _getHeaders();
      
      // Make sure headers include content-type for JSON
      headers['Content-Type'] = 'application/json';
      
      final requestData = {
        'profile_id': profileId,
        'rating': rating,
        'comment': comment,
      };
      
      print('DEBUG: Submitting feedback to $url');
      print('DEBUG: Headers: $headers');
      print('DEBUG: Request data: $requestData');
      print('DEBUG: Comment length: ${comment.length}');
      print('DEBUG: Comment content: "$comment"');
      
      final String jsonBody = jsonEncode(requestData);
      print('DEBUG: JSON encoded body: $jsonBody');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      );
      
      print('DEBUG: Feedback submission response code: ${response.statusCode}');
      print('DEBUG: Response headers: ${response.headers}');
      print('DEBUG: Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('DEBUG: Parsed response data: $responseData');
        return responseData;
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Error submitting feedback: $e');
      throw Exception('Error submitting feedback: $e');
    }
  }
  
  // Get all feedback for a job seeker profile
  Future<Map<String, dynamic>> getSeekerFeedback(int profileId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/seekers/$profileId/feedback/');
      final headers = await _getHeaders();
      
      print('DEBUG: Fetching seeker feedback from $url');
      print('DEBUG: Using headers: $headers');
      
      final response = await http.get(url, headers: headers);
      
      print('DEBUG: Feedback response status: ${response.statusCode}');
      print('DEBUG: Feedback response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Parsed feedback data: $data');
        return data;
      } else {
        throw Exception('Failed to get seeker feedback: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ERROR: Exception in getSeekerFeedback: $e');
      throw Exception('Error getting seeker feedback: $e');
    }
  }
  
  // Update application status (for interview completion)
  Future<Map<String, dynamic>> updateApplicationStatus({
    required int applicationId,
    required String status,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/applications/$applicationId/status/');
      final headers = await _getHeaders();
      
      // Make sure headers include content-type for JSON
      headers['Content-Type'] = 'application/json';
      
      final requestData = {
        'status': status,
      };
      
      print('DEBUG: Updating application status to $url');
      print('DEBUG: Headers: $headers');
      print('DEBUG: Request data: $requestData');
      
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(requestData),
      );
      
      print('DEBUG: Status update response code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update application status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ERROR: Exception in updateApplicationStatus: $e');
      throw Exception('Error updating application status: $e');
    }
  }
}
