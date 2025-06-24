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

class _ApplicantListScreenState extends State<ApplicantListScreen> {
  final JobService _jobService = JobService();
  bool _isLoading = true;
  String _errorMessage = '';
  String _jobTitle = '';
  List<Map<String, dynamic>> _allApplicants = [];
  List<Map<String, dynamic>> _recommendedApplicants = [];
  Map<String, dynamic>? _jobDetails;

  @override
  void initState() {
    super.initState();
    _fetchJobAndApplicants();
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
        // If the API fails, use mock data for now
        applicantsResponse = {
          'applicants': [
            {
              'id': 1,
              'status': 'Pending Review',
              'user': {
                'id': 1,
                'name': 'Jane Doe',
                'email': 'jane.doe@example.com',
                'phone': '+1234567890',
                'skills': ['Flutter', 'Django'],
                'education': 'BSc Computer Science'
              },
              'match_score': 4.2,
              'resume_url': null,
              'cover_letter': 'I am interested in this position...',
              'created_at': '2025-06-20'
            },
            {
              'id': 2,
              'status': 'Interviewed',
              'user': {
                'id': 2,
                'name': 'John Smith',
                'email': 'john.smith@example.com',
                'phone': '+0987654321',
                'skills': ['React', 'Node.js'],
                'education': 'BSc IT'
              },
              'match_score': 3.9,
              'resume_url': null,
              'cover_letter': 'I have experience in...',
              'created_at': '2025-06-19'
            }
          ],
          'total_count': 2
        };
        print('Using mock data for applicants');
      }
      
      setState(() {
        _isLoading = false;
        _jobDetails = jobResponse;
        _jobTitle = _jobDetails?['title'] ?? 'Unknown Job';
        
        // Process recommended candidates
        _recommendedApplicants = recommendedCandidates.map((candidate) => {
          'name': candidate['name'] ?? 'Unknown',
          'skills': candidate['skills']?.join(', ') ?? '',
          'education': candidate['education'] ?? 'Not specified',
          'rating': candidate['match_score'] ?? 0.0,
          'email': candidate['email'] ?? '',
          'phone': candidate['phone'] ?? '',
          'status': 'Recommended',
          'id': candidate['id'],
          'profile_id': candidate['profile_id'],
          'resume_url': candidate['resume_url'],
        }).toList();
        
        // Process all applicants
        final List<dynamic> applicants = applicantsResponse['applicants'] ?? [];
        _allApplicants = applicants.map((applicant) => {
          'name': applicant['user']['name'] ?? 'Unknown',
          'skills': (applicant['user']['skills'] as List<dynamic>?)?.join(', ') ?? '',
          'education': applicant['user']['education'] ?? 'Not specified',
          'rating': applicant['match_score'] ?? 0.0,
          'email': applicant['user']['email'] ?? '',
          'phone': applicant['user']['phone'] ?? '',
          'status': applicant['status'] ?? 'Applied',
          'id': applicant['id'],
          'application_id': applicant['id'],
          'profile_id': applicant['user']['id'],
          'resume_url': applicant['resume_url'],
          'cover_letter': applicant['cover_letter'],
          'applied_date': applicant['created_at'],
        }).toList();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load job details and applicants: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Applicants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _fetchJobAndApplicants();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job: $_jobTitle',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Applicants: ${_allApplicants.length + _recommendedApplicants.length}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_recommendedApplicants.isNotEmpty) ...[
            Card(
              color: Colors.green[50],
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.recommend, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Recommended Applicants',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._recommendedApplicants.map((app) => ApplicantCard(
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
                              'experience': [
                                {
                                  'title': 'Mobile Developer',
                                  'company': 'TechCorp',
                                  'years': 2,
                                },
                                {
                                  'title': 'Intern',
                                  'company': 'StartupX',
                                  'years': 1,
                                },
                              ],
                              'email': app['email'] ?? 'applicant@email.com',
                              'phone': app['phone'] ?? '+1234567890',
                              'status': app['status'] ?? 'Available',
                              'jobId': widget.jobId,
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'All Applicants',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._allApplicants.map((app) => ApplicantCard(
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
                            'experience': [
                              {
                                'title': 'Mobile Developer',
                                'company': 'TechCorp',
                                'years': 2,
                              },
                              {
                                'title': 'Intern',
                                'company': 'StartupX',
                                'years': 1,
                              },
                            ],
                            'email': app['email'] ?? 'applicant@email.com',
                            'phone': app['phone'] ?? '+1234567890',
                            'status': app['status'] ?? 'Available',
                            'jobId': widget.jobId,
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

