import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/token_storage.dart';
import '../../widgets/applicant_card.dart';

class ApplicantListScreen extends StatefulWidget {
  final int? jobId;

  const ApplicantListScreen({
    super.key,
    this.jobId,
  });

  @override
  State<ApplicantListScreen> createState() => _ApplicantListScreenState();
}

class _ApplicantListScreenState extends State<ApplicantListScreen> with SingleTickerProviderStateMixin {
  // Helper function to format skills
  String _formatSkills(dynamic skills) {
    if (skills == null) return '';
    
    if (skills is List) {
      return skills.map((skill) => skill.toString()).join(', ');
    } else if (skills is String) {
      return skills;
    } else {
      return skills.toString();
    }
  }

  final JobService _jobService = JobService();
  bool _isLoading = true;
  String _errorMessage = '';
  String _jobTitle = '';
  List<Map<String, dynamic>> _allApplicants = [];
  List<Map<String, dynamic>> _recommendedApplicants = [];
  Map<String, dynamic>? _jobDetails;
  
  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchJobAndApplicants();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobAndApplicants() async {
    if (widget.jobId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No job ID provided';
      });
      return;
    }
    
    // Check authentication status
    final loginData = await TokenStorage.getLoginData();
    final token = loginData['access'];
    print('Authentication check - Token exists: ${token != null}');

    try {
      print('Fetching job details for job ID: ${widget.jobId}');
      // First get the job details to show the job title
      final jobResponse = await _jobService.getJobDetails(widget.jobId!);
      print('Job details fetched successfully: ${jobResponse['title']}');
      
      // Initialize empty lists for applicants and recommended candidates
      List<Map<String, dynamic>> recommendedCandidates = [];
      Map<String, dynamic> applicantsResponse = {'applicants': [], 'total_count': 0};
      
      // Try to fetch recommended candidates
      try {
        print('Fetching recommended candidates for job ID: ${widget.jobId}');
        recommendedCandidates = await _jobService.getCandidateRecommendations(widget.jobId!);
        print('Recommended candidates fetched successfully: ${recommendedCandidates.length}');
        
        // Debug log to examine the structure of recommended candidates
        if (recommendedCandidates.isNotEmpty) {
          print('Recommended candidates count: ${recommendedCandidates.length}');
          print('First recommended candidate data structure:');
          recommendedCandidates[0].forEach((key, value) {
            print('$key: $value (${value?.runtimeType})'); 
          });
          
          // Check for duplicate names
          final names = recommendedCandidates.map((c) => c['name'] ?? c['full_name'] ?? c['username']).toList();
          final uniqueNames = names.toSet().toList();
          print('Total names: ${names.length}, Unique names: ${uniqueNames.length}');
          if (names.length > uniqueNames.length) {
            print('Warning: Duplicate names detected in recommended candidates');
          }
        }
      } catch (e) {
        print('Error fetching recommended candidates: $e');
        // Continue with empty recommended candidates list
      }
      
      // Try to fetch all applicants
      try {
        print('Fetching all applicants for job ID: ${widget.jobId}');
        applicantsResponse = await _jobService.getJobApplicants(widget.jobId!);
        print('Applicants fetched successfully: ${applicantsResponse['total_count'] ?? 0}');
        print('Applicants data structure: ${applicantsResponse.keys}');
      } catch (e) {
        print('Error fetching applicants: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      
      setState(() {
        _isLoading = false;
        _jobDetails = jobResponse;
        _jobTitle = _jobDetails?['title'] ?? 'Unknown Job';
        
        // Process recommended candidates
        _recommendedApplicants = recommendedCandidates.map((candidate) => {
          // Ensure we get the proper name from the candidate data
          'name': candidate['name'] ?? candidate['full_name'] ?? candidate['username'] ?? 'Unknown',
          'skills': _formatSkills(candidate['skills']),
          'education': candidate['education'], // Pass raw education data
          // Normalize match_score to a 0-5 scale for rating display
          'rating': (candidate['match_score'] is num) 
              ? (candidate['match_score'] * 5.0 / 100.0).clamp(0.0, 5.0) 
              : (candidate['rating'] is num) 
                  ? candidate['rating'].toDouble() 
                  : 0.0,
          'email': candidate['email'] ?? '',
          'phone': candidate['phone'] ?? '',
          'status': 'Recommended',
          'id': candidate['id'],
          'profile_id': candidate['profile_id'],
          'application_id': candidate['id'], // Use id as application_id for recommended candidates
          'resume_url': candidate['resume_url'],
          'experience': candidate['experience'] ?? [],
        }).toList();
        
        // Process all applicants
        final List<dynamic> applicants = applicantsResponse['applicants'] ?? [];
        _allApplicants = applicants.map((applicant) => {
          'name': applicant['name'] ?? 'Unknown',
          'skills': _formatSkills(applicant['skills']),
          'education': applicant['education'], // Pass raw education data
          'rating': applicant['rating'] ?? 0.0,
          'email': applicant['email'] ?? '',
          'phone': applicant['phone'] ?? '',
          'status': applicant['status'] ?? 'Applied',
          'id': applicant['application_id'],
          'application_id': applicant['application_id'],
          'profile_id': applicant['profile_id'],
          'resume_url': applicant['resume_url'],
          'cover_letter': applicant['cover_letter'],
          'applied_at': applicant['applied_at'],
          'experience': applicant['experience'] ?? [],
        }).toList();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load job details and applicants: $e';
      });
    }
  }
  
  // Build a tab for displaying applicants
  Widget _buildApplicantsTab(List<Map<String, dynamic>> applicants, String title) {
    return applicants.isEmpty
        ? Center(child: Text('No ${title.toLowerCase()} available'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ${applicants.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...applicants.map((app) => ApplicantCard(
                  name: app['name'],
                  skills: app['skills'],
                  education: app['education'],
                  rating: app['rating'],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/employer/applicant_details',
                    arguments: {
                      'name': app['name'],
                      'skills': app['skills'],
                      'education': app['education'],
                      'rating': app['rating'],
                      'experience': app['experience'] ?? [],
                      'email': app['email'] ?? '',
                      'phone': app['phone'] ?? '',
                      'status': app['status'] ?? '',
                      'jobId': widget.jobId,
                      'resume_url': app['resume_url'],
                      'profile_id': app['profile_id'],
                      'application_id': app['application_id'],
                      'cover_letter': app['cover_letter'],
                      'applied_at': app['applied_at'],
                      'feedbacks': app['feedbacks'],
                      'feedback_count': app['feedback_count'],
                    },
                  ),
                )),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_jobTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Applicants'),
            Tab(text: 'Recommended'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // All Applicants Tab
                    _buildApplicantsTab(_allApplicants, 'All Applicants'),
                    
                    // Recommended Tab
                    _buildApplicantsTab(_recommendedApplicants, 'Recommended Applicants'),
                  ],
                ),
    );
  }
}