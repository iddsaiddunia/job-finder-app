import 'package:flutter/material.dart';
import '../../widgets/applicant_profile_card.dart';
import '../../widgets/resume_viewer.dart';
import '../../widgets/experience_timeline.dart';
import '../../services/job_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicantDetailsScreen extends StatefulWidget {
  final String applicantName;
  final String skills;
  final dynamic education;
  final double rating;
  final List<dynamic>? experience;
  final String? email;
  final String? phone;
  final String? status;
  final String? resumeUrl;
  final String? coverLetter;
  final String? appliedDate;
  final int? profileId;
  final int? applicationId;
  final int? jobId;
  final int? feedbackCount;
  final List<dynamic>? feedbacks;
  final bool? selectedForNextStep;
  final bool? applicantApproved;
  final String? nextStepType;

  const ApplicantDetailsScreen({
    super.key,
    this.applicantName = 'Jane Doe',
    this.skills = 'Flutter, Django, PostgreSQL',
    this.education,
    this.rating = 0.0,
    this.experience,
    this.email,
    this.phone,
    this.status,
    this.resumeUrl,
    this.coverLetter,
    this.appliedDate,
    this.profileId,
    this.applicationId,
    this.jobId,
    this.feedbackCount,
    this.feedbacks,
    this.selectedForNextStep,
    this.applicantApproved,
    this.nextStepType,
  });

  @override
  State<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends State<ApplicantDetailsScreen> {
  String? _currentStatus;
  bool _isLoading = false;
  bool _isFeedbackLoading = false;
  final JobService _jobService = JobService();
  List<dynamic> _allFeedbacks = [];
  double _averageRating = 0.0;
  bool _applicantApproved = false;
  String _employerNotes = '';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  String _nextStepType = '';
  bool _isSelectedApplicant = false;
  double _ratingValue = 3.0; // Default rating value
  
  /// Builds a widget to display education details with improved visual design
  /// Prioritizes showing education level and field for better matching
  Widget _buildEducationDetails(dynamic education) {
    if (education == null) return _buildEmptyEducation();
    
    try {
      // Handle different education data formats
      
      // Case 1: Direct Map with level and field
      if (education is Map) {
        if (education.containsKey('level')) {
          return _buildStructuredEducationList([education]);
        }
      }
      
      // Case 2: String that's not JSON
      if (education is String && !education.toString().trim().startsWith('[') && 
          !education.toString().trim().startsWith('{')) {
        return _buildSimpleEducation(education.toString());
      }
      
      // Case 3: List of education entries or JSON string
      List<dynamic> educationList;
      
      if (education is String) {
        // Try to parse as JSON
        try {
          final parsed = jsonDecode(education);
          if (parsed is List) {
            educationList = parsed;
          } else if (parsed is Map) {
            // Handle single education entry as JSON object
            if (parsed.containsKey('level')) {
              return _buildStructuredEducationList([parsed]);
            }
            // If it's a map but doesn't have level, treat as a list with one item
            educationList = [parsed];
          } else {
            return _buildSimpleEducation(education.toString());
          }
        } catch (e) {
          return _buildSimpleEducation(education.toString());
        }
      } else if (education is List) {
        educationList = education;
      } else {
        return _buildSimpleEducation(education.toString());
      }
      
      if (educationList.isEmpty) return _buildEmptyEducation();
      
      // Check if we have structured education data with level and field
      bool hasStructuredFormat = false;
      for (var edu in educationList) {
        if (edu is Map && edu.containsKey('level')) {
          hasStructuredFormat = true;
          break;
        }
      }
      
      if (hasStructuredFormat) {
        return _buildStructuredEducationList(educationList);
      } else {
        return _buildLegacyEducationList(educationList);
      }
    } catch (e) {
      // Fallback for any parsing errors
      return _buildSimpleEducation('Error parsing education data');
    }
  }
  
  /// Builds a widget for empty education data
  Widget _buildEmptyEducation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.school_outlined, color: Colors.grey),
          SizedBox(width: 12),
          Text('No education information available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
  
  /// Builds a widget for simple text education data
  Widget _buildSimpleEducation(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(text, style: TextStyle(fontSize: 15)),
    );
  }
  
  /// Builds a list of structured education entries (new format with level and field)
  Widget _buildStructuredEducationList(List<dynamic> educationList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: educationList.map((edu) {
        if (edu is Map) {
          final level = edu['level'] ?? '';
          final field = edu['field'] ?? '';
          final institution = edu['institution'] ?? '';
          final year = edu['year'] ?? '';
          final type = edu['type'] ?? '';
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Education level and field (most important for matching)
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$level${field.isNotEmpty ? ' in $field' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Additional details
                if (institution.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            institution,
                            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (type.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          type,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                if (year.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        year,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
              ],
            ),
          );
        } else {
          return _buildSimpleEducation(edu.toString());
        }
      }).toList(),
    );
  }
  
  /// Builds a list of legacy education entries (old format with degree and institution)
  Widget _buildLegacyEducationList(List<dynamic> educationList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: educationList.map((edu) {
        if (edu is Map) {
          final degree = edu['degree'] ?? '';
          final institution = edu['institution'] ?? '';
          final year = edu['year'] ?? '';
          final description = edu['description'] ?? '';
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.purple[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$degree${degree.isNotEmpty && institution.isNotEmpty ? ' at ' : ''}$institution',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.purple[800],
                        ),
                      ),
                    ),
                  ],
                ),
                if (year.isNotEmpty || description.isNotEmpty)
                  const SizedBox(height: 8),
                if (year.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Year: $year',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return _buildSimpleEducation(edu.toString());
        }
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize status information from route arguments
    _currentStatus = widget.status ?? '';
    _isSelectedApplicant = widget.selectedForNextStep ?? false;
    _applicantApproved = widget.applicantApproved ?? false;
    _nextStepType = widget.nextStepType ?? '';
    
    // Load feedback data
    _loadAllFeedbacks();
    
    // Load application details if we have an application ID
    if (widget.applicationId != null) {
      _loadApplicationDetails();
    } else if (widget.profileId != null && widget.jobId != null) {
      // Try to find application by profile ID and job ID
      _loadApplicationDetailsByProfileId();
    }

    // Debug info
    print('ApplicantDetailsScreen initialized with:');
    print('- Application ID: ${widget.applicationId}');
    print('- Profile ID: ${widget.profileId}');
    print('- Status: ${widget.status}');
    print('- Selected: ${widget.selectedForNextStep}');
    print('- Approved: ${widget.applicantApproved}');
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  // Load application details using application ID
  Future<void> _loadApplicationDetails() async {
    if (widget.applicationId == null) return;
    
    try {
      final response = await _jobService.getApplicationDetails(widget.applicationId!);
      
      setState(() {
        _applicantApproved = response['applicant_approved'] ?? false;
        _employerNotes = response['recruiter_notes'] ?? '';
        _nextStepType = response['next_step_type'] ?? '';
        _isSelectedApplicant = response['selected_for_next_step'] ?? false;
        _notesController.text = _employerNotes;
        _currentStatus = response['status'] ?? '';
      });
    } catch (e) {
      print('Error loading application details: $e');
    }
  }
  
  // Load application details by profile ID and job ID
  Future<void> _loadApplicationDetailsByProfileId() async {
    if (widget.profileId == null || widget.jobId == null) return;
    
    try {
      // Get all applications for this job
      final applications = await _jobService.getJobApplications(widget.jobId!);
      
      // Find if this profile has an application
      for (var application in applications) {
        if (application['seeker'] == widget.profileId) {
          // Found an application for this profile
          setState(() {
            _applicantApproved = application['applicant_approved'] ?? false;
            _employerNotes = application['recruiter_notes'] ?? '';
            _nextStepType = application['next_step_type'] ?? '';
            _isSelectedApplicant = application['selected_for_next_step'] ?? false;
            _notesController.text = _employerNotes;
            _currentStatus = application['status'] ?? '';
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking for existing application: $e');
    }
  }
  
  // Update employer notes for the application
  Future<void> _updateEmployerNotes() async {
    if (widget.applicationId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Get the current notes from the text controller
      final notes = _notesController.text.trim();
      
      // Call the API to update the application with the new notes
      await _jobService.setApplicationNextStep(
        applicationId: widget.applicationId!,
        nextStepType: _nextStepType.isEmpty ? (_currentStatus == 'HIRED' ? 'DIRECT_HIRE' : 'INTERVIEW') : _nextStepType,
        recruiterNotes: notes,
      );
      
      setState(() {
        _employerNotes = notes;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating notes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadAllFeedbacks() async {
    if (widget.profileId == null) {
      return;
    }

    setState(() {
      _isFeedbackLoading = true;
    });

    try {
      final feedbackData = await _jobService.getSeekerFeedback(widget.profileId!);
      
      final feedbacks = feedbackData['feedbacks'] ?? [];
      final avgRating = (feedbackData['average_rating'] ?? 0.0).toDouble();
      
      setState(() {
        _allFeedbacks = feedbacks;
        _averageRating = avgRating;
        _isFeedbackLoading = false;
      });
    } catch (e) {
      setState(() {
        _isFeedbackLoading = false;
      });
      
      if (_allFeedbacks.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh feedback'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // No longer needed - status is now passed directly via route arguments

  // Save application status to SharedPreferences
  Future<void> _saveStatus(String status) async {
    if (widget.applicationId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('application_status_${widget.applicationId}', status);
    } catch (e) {
    }
  }

  // Check if applicant is selected (interview or hired)
  bool get _isApplicantSelected {
    return _currentStatus == 'HIRED' ||
           _currentStatus == 'INTERVIEW' ||
           _currentStatus == 'DIRECT_HIRE';
  }
  
  // Builds a widget to display feedback information
  Widget _buildFeedbackSection(List<dynamic> feedbacks) {
    if (_isFeedbackLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (feedbacks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No feedback available yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Feedback will appear here once provided',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedbacks.length,
      itemBuilder: (context, index) {
        final feedback = feedbacks[index];
        
        double rating = 0.0;
        if (feedback['rating'] != null) {
          if (feedback['rating'] is num) {
            rating = (feedback['rating'] as num).toDouble();
          } else if (feedback['rating'] is String) {
            rating = double.tryParse(feedback['rating'] as String) ?? 0.0;
          }
        }
        
        final hasComment = feedback.containsKey('comment');
        final commentValue = feedback['comment'];
        final commentType = commentValue?.runtimeType;
        
        final comment = hasComment ? (commentValue?.toString() ?? '') : '';
        
        final date = feedback['created_at'] as String? ?? '';
        final recruiterName = feedback['recruiter_name'] as String? ?? 'Unknown';
        final source = feedback['source'] as String? ?? 'application_feedback';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(26),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < rating.floor() 
                            ? Icons.star 
                            : i < rating 
                              ? Icons.star_half
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: source == 'application_feedback' 
                        ? Colors.blue[50] 
                        : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      source == 'application_feedback' ? 'Job Specific' : 'General',
                      style: TextStyle(
                        fontSize: 12,
                        color: source == 'application_feedback' 
                          ? Colors.blue[700] 
                          : Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              if (comment.isNotEmpty) ...[  
                const SizedBox(height: 8),
                Text(comment),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'By $recruiterName',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Fetch job details to get the predefined next step
  Future<void> _fetchJobNextStepAndProcess(bool isSelect) async {
    if (!isSelect) {
      final TextEditingController notesController = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reject Applicant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to reject this applicant?'),
              const SizedBox(height: 16),
              const Text('Optional: Add notes about this rejection'),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  hintText: 'Reason for rejection, feedback, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateApplicationStatus('REJECTED', notesController.text);
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.jobId == null) {
        throw Exception('Job ID is missing');
      }
      
      final jobDetails = await _jobService.getJobDetails(widget.jobId!);
      final predefinedNextStep = jobDetails['next_step'] ?? 'INTERVIEW'; // Default to INTERVIEW if not found
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        _showConfirmationDialog(predefinedNextStep);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching job details: ${e.toString()}')),
        );
      }
    }
  }

  // Show confirmation dialog with the predefined next step
  void _showConfirmationDialog(String nextStepType) {
    int? jobDurationDays;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirm Selection'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nextStepType == 'DIRECT_HIRE'
                  ? 'This applicant will be hired directly.'
                  : 'This applicant will be scheduled for an interview.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (nextStepType == 'DIRECT_HIRE') ...[  
                const Text('Job Duration (days):'),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter job duration in days',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      jobDurationDays = int.tryParse(value);
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _setApplicationNextStep(nextStepType, jobDurationDays);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  // Update application status (reject)
  Future<void> _updateApplicationStatus(String status, [String? recruiterNotes]) async {
    if (widget.applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Application ID not found')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _jobService.setApplicationNextStep(
        applicationId: widget.applicationId!,
        nextStepType: 'REJECTED',
        recruiterNotes: recruiterNotes?.trim(),
      );
      
      setState(() {
        _currentStatus = 'REJECTED';
        _isLoading = false;
      });
      
      await _saveStatus('REJECTED');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Applicant rejected successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Set application next step (interview or direct hire)
  Future<void> _setApplicationNextStep(String nextStepType, int? jobDurationDays) async {
    if (widget.applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Application ID not found')),
      );
      return;
    }
    
    // Only check for already processed if not handling interview completion
    // Allow interview completion (HIRED or REJECTED) even if already selected
    if (_currentStatus != 'INTERVIEW' && _isApplicantSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This applicant has already been processed')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _jobService.setApplicationNextStep(
        applicationId: widget.applicationId!,
        nextStepType: nextStepType,
        jobDurationDays: jobDurationDays,
      );
      
      // Update the status based on the next step type
      final newStatus = nextStepType == 'DIRECT_HIRE' || nextStepType == 'HIRED' 
          ? 'HIRED' 
          : nextStepType == 'INTERVIEW' 
              ? 'INTERVIEW' 
              : 'REJECTED';
      
      setState(() {
        _currentStatus = newStatus;
        _nextStepType = nextStepType;
        _isLoading = false;
      });
      
      // Save the status to SharedPreferences
      await _saveStatus(newStatus);
      
      String message;
      if (nextStepType == 'DIRECT_HIRE' || nextStepType == 'HIRED') {
        message = 'Applicant hired successfully';
      } else if (nextStepType == 'INTERVIEW') {
        message = 'Applicant selected for interview successfully';
      } else {
        message = 'Applicant rejected successfully';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      
      // Only pop if not completing an interview
      if (nextStepType != 'HIRED' && nextStepType != 'REJECTED') {
        // Pop with result to trigger refresh in the applicant list screen
        Navigator.pop(context, true);
      } else {
        // Refresh application details
        _loadApplicationDetails();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  // Handle interview completion (pass/fail)
  Future<void> _completeInterview(bool passed) async {
    if (widget.applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Application ID not found')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final String status = passed ? 'HIRED' : 'REJECTED';
      
      await _jobService.updateApplicationStatus(
        applicationId: widget.applicationId!,
        status: status,
      );
      
      setState(() {
        _currentStatus = status;
        _isLoading = false;
      });
      
      // Save the status to SharedPreferences
      await _saveStatus(status);
      
      String message = passed 
          ? 'Applicant hired successfully' 
          : 'Applicant rejected successfully';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      
      // Refresh application details
      _loadApplicationDetails();
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  // Submit feedback for a hired applicant
  Future<void> _submitFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback comments'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_ratingValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _jobService.submitApplicantFeedback(
        applicationId: widget.applicationId!,
        profileId: widget.profileId!,
        rating: _ratingValue,
        comment: _feedbackController.text,
      );
      
      setState(() {
        _isLoading = false;
        _feedbackController.clear();
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reload feedbacks
      _loadAllFeedbacks();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show dialog to add rating and feedback for an approved applicant
  // Feedback dialog removed as it's no longer needed
  
  // Submit feedback and rating to the backend
  // Feedback submission method removed as it's no longer needed

  @override
  Widget build(BuildContext context) {
    
    // Get arguments from Navigator if available
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Basic profile information
    final name = args?['name'] as String? ?? widget.applicantName;
    final skills = args?['skills'] as String? ?? widget.skills;
    final education = args?['education'] ?? widget.education;
    final rating = args?['rating'] != null ? (args!['rating'] as num).toDouble() : widget.rating;
    
    // Experience and contact information
    final experience = args?['experience'] as List<dynamic>? ?? widget.experience ?? [];
    final email = args?['email'] as String? ?? widget.email;
    final phone = args?['phone'] as String? ?? widget.phone;
    
    // Application details
    final status = args?['status'] as String? ?? widget.status ?? 'Pending';
    final resumeUrl = args?['resume_url'] as String? ?? widget.resumeUrl;
    final coverLetter = args?['cover_letter'] as String? ?? widget.coverLetter;
    final appliedDate = args?['applied_at'] as String? ?? widget.appliedDate;
    final profileId = args?['profile_id'] as int? ?? widget.profileId;
    final applicationId = args?['application_id'] as int? ?? widget.applicationId;
    // We don't need feedbackCount anymore as we're using the length of the feedback list
    final feedbacks = args?['feedbacks'] as List<dynamic>? ?? widget.feedbacks;
    
    // Additional profile details
    final location = args?['location'] as String? ?? '';
    final willingToRelocate = args?['willing_to_relocate'] as bool? ?? false;
    final salaryExpectation = args?['salary_expectation'] as int?;
    final linkedin = args?['linkedin'] as String? ?? '';
    
    // Format the applied date if available
    String formattedDate = '';
    if (appliedDate != null) {
      try {
        final date = DateTime.parse(appliedDate);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = appliedDate;
      }
    }

    Color statusColor;
    switch (status) {
      case 'Busy':
        statusColor = Colors.orange;
        break;
      case 'Interviewing':
        statusColor = Colors.blue;
        break;
      case 'Available':
      default:
        statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Basic profile information - simplified to only show avatar, name and rating
            ApplicantProfileCard(
              name: name,
              rating: rating,
            ),
            const SizedBox(height: 16),
            
            // Skills section in a separate styled container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.split(',').map((skill) {
                      final trimmedSkill = skill.trim();
                      if (trimmedSkill.isEmpty) return const SizedBox.shrink();
                      
                      return Chip(
                        label: Text(trimmedSkill),
                        backgroundColor: Colors.purple.shade100,
                        labelStyle: TextStyle(color: Colors.purple.shade800),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Resume and additional profile information
            ResumeViewer(
              resumeUrl: resumeUrl,
              linkedinUrl: linkedin,
              location: location,
              willingToRelocate: willingToRelocate,
              salaryExpectation: salaryExpectation,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(_currentStatus ?? status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                const SizedBox(width: 16),
                // Only show contact buttons if applicant is selected
                if (_isApplicantSelected && email != null) ...[
                  IconButton(
                    icon: Icon(Icons.email, color: Colors.blue),
                    tooltip: 'Send Email',
                    onPressed: () async {
                      final uri = Uri(scheme: 'mailto', path: email);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Could not open email client.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                ],
                if (_isApplicantSelected && phone != null) ...[
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    tooltip: 'Call',
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Could not start call.')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            // Application date and status
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Application Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Applied on: $formattedDate', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_search, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Application ID: #${applicationId ?? 'N/A'}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.fingerprint, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Profile ID: #${profileId ?? 'N/A'}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cover letter if available
            if (coverLetter != null && coverLetter.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cover Letter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 12),
                      Text(
                        coverLetter,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Experience timeline
            if (experience.isNotEmpty) ...[
              const Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 12),
              ExperienceTimeline(experience: experience),
              const SizedBox(height: 16),
            ],
            // Display formatted education information
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 8),
                    _buildEducationDetails(education),
                  ],
                ),
              ),
            ),
            
            // Feedback section - always visible
            const SizedBox(height: 24),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Feedback & Ratings', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                ),
                if (_averageRating > 0 || rating > 0)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Average: ', style: TextStyle(fontSize: 14)),
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < (_averageRating > 0 ? _averageRating : rating).floor() 
                            ? Icons.star 
                            : index < (_averageRating > 0 ? _averageRating : rating) 
                              ? Icons.star_half
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        (_averageRating > 0 ? _averageRating : rating).toStringAsFixed(1), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeedbackSection(_allFeedbacks.isEmpty ? (feedbacks ?? []) : _allFeedbacks),
            
            const SizedBox(height: 24),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Show applicant approval status for selected applicants
                  if (_isSelectedApplicant || _currentStatus == 'HIRED' || _currentStatus == 'INTERVIEW')
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Applicant Approval Status', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _applicantApproved ? Colors.green.shade100 : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _applicantApproved ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  child: Text(
                                    _applicantApproved ? 'Approved' : 'Pending Approval',
                                    style: TextStyle(
                                      color: _applicantApproved ? Colors.green.shade800 : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _nextStepType == 'DIRECT_HIRE'
                                ? 'This applicant has been selected for direct hire.'
                                : 'This applicant has been selected for interview.',
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _applicantApproved
                                ? 'The applicant has approved this selection.'
                                : 'Waiting for applicant to approve this selection.',
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: _applicantApproved ? FontStyle.normal : FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                  // Notes section for selected applicants
                  if (_isSelectedApplicant || _currentStatus == 'HIRED' || _currentStatus == 'INTERVIEW')
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Employer Notes', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            const SizedBox(height: 12),
                            
                            // Notes section - always show existing notes
                            if (_employerNotes.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Recruiter Notes:',
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blue)),
                                        if (_applicantApproved)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Chip(
                                              label: Text('Approved by Applicant', 
                                                style: TextStyle(fontSize: 11, color: Colors.white)),
                                              backgroundColor: Colors.green,
                                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(_employerNotes,
                                      style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                              ),
                              
                            // Only show notes editing if applicant hasn't approved yet
                            if (!_applicantApproved) ...[  
                              const SizedBox(height: 16),
                              TextField(
                                controller: _notesController,
                                decoration: InputDecoration(
                                  hintText: _nextStepType == 'DIRECT_HIRE'
                                    ? 'Add notes about job details, start date, etc.'
                                    : 'Add notes about interview details, date, location, etc.',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                maxLines: 4,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateEmployerNotes(),
                                  icon: const Icon(Icons.save, color: Colors.white),
                                  label: const Text('Save Notes'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 16),
                  
                  Column(
                    children: [
                      // Show interview completion buttons when applicant is in INTERVIEW status and has approved
                      if (_currentStatus == 'INTERVIEW' && _applicantApproved)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Interview Completion', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Mark this interview as completed with the appropriate outcome:',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isLoading ? null : () => _completeInterview(true),
                                        icon: const Icon(Icons.check_circle, color: Colors.white),
                                        label: const Text('Pass Interview'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _isLoading ? null : () => _completeInterview(false),
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        label: const Text('Reject'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      // Show feedback submission UI when applicant is hired
                      if (_currentStatus == 'HIRED')
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Provide Feedback', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Rate this applicant and provide feedback:',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 16),
                                
                                // Rating slider
                                Row(
                                  children: [
                                    const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Slider(
                                        value: _ratingValue,
                                        min: 0.0,
                                        max: 5.0,
                                        divisions: 10,
                                        label: _ratingValue.toStringAsFixed(1),
                                        onChanged: (value) {
                                          setState(() {
                                            _ratingValue = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _ratingValue.toStringAsFixed(1),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Feedback text field
                                TextField(
                                  controller: _feedbackController,
                                  decoration: const InputDecoration(
                                    labelText: 'Feedback Comments',
                                    hintText: 'Provide your feedback about this applicant',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 4,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Submit button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading ? null : _submitFeedback,
                                    icon: const Icon(Icons.send, color: Colors.white),
                                    label: const Text('Submit Feedback'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      // Only show Select Applicant button if not rejected and not in interview or hired status
                      if (_currentStatus != 'REJECTED' && _currentStatus != 'INTERVIEW' && _currentStatus != 'HIRED')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            // Disable button if loading, already selected, or if isSelectedApplicant flag is true
                            onPressed: _isLoading || _isApplicantSelected || _isSelectedApplicant ? null : () => _fetchJobNextStepAndProcess(true),
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: Text(_currentStatus == 'HIRED' || _currentStatus == 'INTERVIEW' || _isSelectedApplicant
                              ? 'Selected' 
                              : 'Select Applicant'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.deepPurple.withAlpha(128),
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 3,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      
                      // Only show reject button if not already rejected, hired, or in interview
                      if (_currentStatus != 'REJECTED' && _currentStatus != 'HIRED' && _currentStatus != 'INTERVIEW')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : () => _fetchJobNextStepAndProcess(false),
                            icon: Icon(Icons.close, color: _currentStatus == 'REJECTED' ? Colors.grey : Colors.redAccent),
                            label: Text(_currentStatus == 'REJECTED' ? 'Rejected' : 'Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _currentStatus == 'REJECTED' ? Colors.grey : Colors.redAccent,
                              side: BorderSide(color: _currentStatus == 'REJECTED' ? Colors.grey : Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
