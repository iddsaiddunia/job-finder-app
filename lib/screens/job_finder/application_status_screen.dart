import 'package:flutter/material.dart';
import 'package:job_finder/services/job_service.dart';
import 'dart:developer' as developer;

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  final JobService _jobService = JobService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      developer.log('Fetching applications...');
      final applications = await _jobService.getApplications();
      developer.log('Fetched ${applications.length} applications');
      
      // Print the raw response for debugging
      developer.log('Applications data: $applications');
      
      // Fetch job details for each application if job is just an ID
      List<Map<String, dynamic>> enhancedApplications = [];
      
      for (var application in applications) {
        if (application['job'] is int) {
          // If job is just an ID, fetch the job details
          try {
            final jobId = application['job'];
            developer.log('Fetching details for job ID: $jobId');
            final jobDetails = await _jobService.getJobDetails(jobId);
            
            // Create a new application object with the job details
            final enhancedApplication = Map<String, dynamic>.from(application);
            enhancedApplication['job'] = jobDetails;
            enhancedApplications.add(enhancedApplication);
          } catch (e) {
            developer.log('Error fetching job details: $e');
            // Still add the original application even if we couldn't get job details
            enhancedApplications.add(application);
          }
        } else {
          // Job is already an object with details
          enhancedApplications.add(application);
        }
      }
      
      developer.log('Enhanced applications: $enhancedApplications');

      setState(() {
        // Use the enhanced applications with job details
        _applications = enhancedApplications;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error fetching applications: $e');
      setState(() {
        _errorMessage = 'Failed to load applications: $e';
        _isLoading = false;
        // Ensure we clear any previous application data on error
        _applications = [];
      });
    }
  }

  // Helper method to get job title from application data
  String _getJobTitle(Map<String, dynamic> application) {
    developer.log('Getting job title from: ${application['job']}');
    if (application['job'] is Map) {
      final jobData = application['job'] as Map<String, dynamic>;
      return jobData['title'] ?? 'Unknown Job';
    } else {
      return 'Job #${application['job']}';
    }
  }

  // Helper method to get company name from application data
  String _getCompanyName(Map<String, dynamic> application) {
    developer.log('Getting company name from: ${application['job']}');
    if (application['job'] is Map) {
      final jobData = application['job'] as Map<String, dynamic>;
      // Try different possible field names for company
      if (jobData['company_name'] != null) {
        return jobData['company_name'].toString();
      } else if (jobData['company'] != null) {
        return jobData['company'].toString();
      } else if (jobData['employer'] != null && jobData['employer'] is Map) {
        final employer = jobData['employer'] as Map<String, dynamic>;
        if (employer['company_name'] != null) {
          return employer['company_name'].toString();
        } else if (employer['name'] != null) {
          return employer['name'].toString();
        }
      }
    }
    return 'Unknown Company';
  }

  // Helper method to get application status
  String _getApplicationStatus(Map<String, dynamic> application) {
    return application['status'] ?? 'Pending';
  }

  // Helper method to format application date
  String _getApplicationDate(Map<String, dynamic> application) {
    if (application['applied_at'] != null) {
      final DateTime date = DateTime.parse(application['applied_at']);
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Unknown Date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchApplications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchApplications,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _applications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off, color: Colors.grey[400], size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No applications yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start applying for jobs to see your applications here',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/job_finder/home'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                            child: const Text('Browse Jobs'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        final app = _applications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.work, color: Colors.deepPurple),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getJobTitle(app),
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getCompanyName(app),
                                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusBadge(_getApplicationStatus(app)),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Applied: ${_getApplicationDate(app)}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to job details
                                        if (app['job'] is Map) {
                                          Navigator.pushNamed(
                                            context,
                                            '/job_finder/job_details',
                                            arguments: app['job'],
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('View Job'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'hired':
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        badgeColor = Colors.red;
        icon = Icons.cancel;
        break;
      case 'interview':
        badgeColor = Colors.blue;
        icon = Icons.people;
        break;
      case 'pending':
      default:
        badgeColor = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
