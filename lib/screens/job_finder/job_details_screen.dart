import 'package:flutter/material.dart';
import 'package:job_finder/services/job_service.dart';
import 'dart:async';
import 'dart:developer' as developer;

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isLoading = true;
  bool _hasApplied = false;
  String _errorMessage = '';
  
  // Application details
  Map<String, dynamic>? _applicationData;
  String? _applicationStatus;
  String? _recruiterNotes;
  bool _isSelected = false;
  bool _isApproved = false;
  String? _appliedDate;
  bool _isApprovingOffer = false;
  String? _nextStepType;
  bool _isRejected = false;

  @override
  void initState() {
    super.initState();
    // We need to wait for the widget to be fully built before accessing route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApplicationStatus();
    });
  }

  Future<void> _checkApplicationStatus() async {
    final Map<String, dynamic> job = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int? jobId = job['id'];
    
    if (jobId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Cannot check application status: Job ID is missing';
      });
      return;
    }
    
    try {
      developer.log('Checking application status for job ID: $jobId');
      
      // Get all applications for the current user
      final applications = await JobService().getApplications();
      developer.log('Retrieved ${applications.length} applications');
      
      // Check if any application is for the specified job
      bool hasApplied = false;
      Map<String, dynamic>? applicationData;
      
      for (var application in applications) {
        if (application['job'] != null) {
          // Handle different job response formats
          bool isMatch = false;
          if (application['job'] is Map && application['job']['id'] == jobId) {
            // Job is a nested object with id field
            isMatch = true;
          } else if (application['job'] is int && application['job'] == jobId) {
            // Job is just the ID
            isMatch = true;
          }
          
          if (isMatch) {
            hasApplied = true;
            applicationData = application;
            developer.log('Found existing application for job ID: $jobId');
            developer.log('Application data: $applicationData');
            break;
          }
        }
      }
      
      setState(() {
        _hasApplied = hasApplied;
        _isLoading = false;
        
        if (applicationData != null) {
          _applicationData = applicationData;
          _applicationStatus = applicationData['status']?.toString();
          _recruiterNotes = applicationData['recruiter_notes']?.toString();
          _appliedDate = applicationData['applied_at']?.toString();
          
          // Get the next step type
          _nextStepType = applicationData['next_step_type']?.toString();
          
          // Check if the application is selected and needs approval
          _isSelected = (_applicationStatus?.toLowerCase() == 'selected') || 
                       (applicationData['selected_for_next_step'] == true);
          _isApproved = applicationData['applicant_approved'] == true;
          
          // Check if the application is rejected
          _isRejected = _applicationStatus?.toLowerCase() == 'rejected';
          
          developer.log('Is selected for next step: ${applicationData['selected_for_next_step']}');
          developer.log('Next step type: $_nextStepType');
          
          developer.log('Application status: $_applicationStatus');
          developer.log('Recruiter notes: $_recruiterNotes');
          developer.log('Is selected: $_isSelected');
          developer.log('Is approved: $_isApproved');
        }
      });
    } catch (e) {
      developer.log('Error checking application status: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking application status: $e';
      });
    }
  }
  
  // Helper methods for formatting status and dates
  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'selected':
        return Colors.blue;
      case 'shortlisted':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch(status.toLowerCase()) {
      case 'selected':
        return Icons.star;
      case 'shortlisted':
        return Icons.person_search;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }
  
  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
  
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
  
  // Method to handle offer approval or rejection
  Future<void> _approveOffer(bool approve) async {
    if (_applicationData == null) return;
    
    final int? applicationId = _applicationData!['id'];
    if (applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot process: Application ID is missing'))
      );
      return;
    }
    
    setState(() {
      _isApprovingOffer = true;
    });
    
    try {
      await JobService().approveApplicationNextStep(
        applicationId: applicationId,
        approve: approve,
      );
      
      setState(() {
        _isApprovingOffer = false;
        _isApproved = approve;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve 
            ? 'You have accepted the offer!' 
            : 'You have declined the offer.'),
          backgroundColor: approve ? Colors.green : Colors.red,
        )
      );
    } catch (e) {
      setState(() {
        _isApprovingOffer = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'))
      );
    }
  }
  
  Future<void> _applyForJob(int jobId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      developer.log('Applying for job ID: $jobId');
      await JobService().applyForJob(jobId: jobId);
      
      setState(() {
        _hasApplied = true;
        _isLoading = false;
      });
      developer.log('Successfully applied for job ID: $jobId');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully applied for this job!')),
      );
    } catch (e) {
      developer.log('Error applying for job: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Check if this is a duplicate application error
      final String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('already applied')) {
        setState(() {
          _hasApplied = true; // Update UI to show already applied
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have already applied for this job')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get job data from route arguments
    final Map<String, dynamic> job = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    // Extract job data with null safety
    final String title = job['title']?.toString() ?? 'Untitled Position';
    final String jobType = job['job_type']?.toString() ?? 'Full-time';
    final String location = job['location']?.toString() ?? 'Remote';
    final bool isRemote = job['is_remote'] == true;
    final String displayLocation = isRemote ? 'Remote' : location;
    
    // Format salary range
    final dynamic salaryMin = job['salary_min'];
    final dynamic salaryMax = job['salary_max'];
    final String salary = (salaryMin != null && salaryMax != null)
        ? '\$${salaryMin.toString()} - \$${salaryMax.toString()}'
        : 'Negotiable';
    
    // Get description and requirements
    final String description = job['description']?.toString() ?? 'No description available';
    final List<dynamic> requirementsList = job['requirements'] is List ? job['requirements'] : [];
    final String requirements = requirementsList.isNotEmpty
        ? requirementsList.join('\n• ')
        : 'No specific requirements listed';
    
    // Get skills
    final List<dynamic> skillsList = job['skills'] is List ? job['skills'] : [];
    final String skills = skillsList.isNotEmpty
        ? skillsList.join(', ')
        : 'Not specified';
    
    // Get experience level
    final String experienceLevel = job['experience_level']?.toString() ?? 'Not specified';
    
    return Scaffold(
      appBar: AppBar(title: Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            // Job type and location
            Row(
              children: [
                Icon(Icons.work_outline, size: 18, color: Colors.deepPurple),
                SizedBox(width: 6),
                Text(jobType, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 18, color: Colors.deepPurple),
                SizedBox(width: 6),
                Text(displayLocation, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Experience level
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: Colors.deepPurple),
                SizedBox(width: 6),
                Text('Experience: $experienceLevel', style: TextStyle(fontSize: 16, color: Colors.grey[800])),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Salary
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                  SizedBox(width: 4),
                  Text(salary, style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Divider(height: 32),
            
            // Skills section
            Text('Skills Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text(skills, style: TextStyle(fontSize: 16)),
            
            SizedBox(height: 24),
            
            // Description section
            Text('Job Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            
            SizedBox(height: 24),
            
            // Requirements section
            Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text('• $requirements', style: TextStyle(fontSize: 16)),
            
            SizedBox(height: 40),
            
            // Application status section
            SizedBox(
              width: double.infinity,
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _hasApplied
                  ? Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Application Status Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_applicationStatus ?? 'pending').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(_applicationStatus ?? 'pending').withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(_applicationStatus ?? 'pending'), 
                                    color: _getStatusColor(_applicationStatus ?? 'pending')
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Application Status: ${_formatStatus(_applicationStatus ?? 'Pending')}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(_applicationStatus ?? 'pending'),
                                    ),
                                  ),
                                ],
                              ),
                              if (_appliedDate != null) ...[  
                                SizedBox(height: 8),
                                Text(
                                  'Applied on: ${_formatDate(_appliedDate!)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                              
                              // Recruiter Notes Section (only if available)
                              if (_recruiterNotes != null && _recruiterNotes!.isNotEmpty) ...[  
                                SizedBox(height: 16),
                                Text(
                                  'Recruiter Notes:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(_recruiterNotes!),
                                ),
                              ],
                              
                              // Direct Hire Selection
                              if (_isSelected && !_isApproved && _nextStepType?.toUpperCase() == 'DIRECT_HIRE') ...[  
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.blue[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.celebration, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Congratulations! You have been selected for direct hire!',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'If you accept this offer, you will be contacted by the employer with further details.',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isApprovingOffer ? null : () => _approveOffer(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: _isApprovingOffer 
                                                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : Text('Accept Offer'),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isApprovingOffer ? null : () => _approveOffer(false),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: Text('Decline'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Interview Selection
                              if (_isSelected && !_isApproved && _nextStepType?.toUpperCase() == 'INTERVIEW') ...[  
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.amber[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.event, color: Colors.amber[800]),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Congratulations! You have been selected for an interview!',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Please check the recruiter notes for interview details and confirm your availability.',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isApprovingOffer ? null : () => _approveOffer(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.amber[700],
                                                foregroundColor: Colors.white,
                                              ),
                                              child: _isApprovingOffer 
                                                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : Text('Confirm Availability'),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isApprovingOffer ? null : () => _approveOffer(false),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: Text('Decline'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Generic selection (fallback for other selection types)
                              if (_isSelected && !_isApproved && _nextStepType == null) ...[  
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.blue[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.celebration, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Congratulations! You have been selected for this position.',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Please review the details and approve to confirm your acceptance.',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isApprovingOffer ? null : () => _approveOffer(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: _isApprovingOffer 
                                                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : Text('Accept Offer'),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isApprovingOffer ? null : () => _approveOffer(false),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: Text('Decline'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Rejection message
                              if (_isRejected) ...[  
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.red[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.red),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Your application was not selected for this position.',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_recruiterNotes != null && _recruiterNotes!.isNotEmpty) ...[  
                                        SizedBox(height: 12),
                                        Text(
                                          'Feedback from the recruiter:',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Already approved message
                              if (_isSelected && _isApproved) ...[  
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.verified, color: Colors.green),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You have accepted this offer. The employer will contact you with next steps.',
                                          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final jobId = job['id'];
                          if (jobId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cannot apply: Job ID is missing')),
                            );
                            return;
                          }
                          
                          setState(() => _isLoading = true);
                          await _applyForJob(jobId);
                        } catch (e) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to apply: ${e.toString().replaceAll("Exception: ", "")}'))
                          );
                        }
                      },
                      icon: Icon(Icons.send),
                      label: Text('Apply Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ),
            
            // Show error message if any
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
