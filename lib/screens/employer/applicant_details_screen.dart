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
  final int? feedbackCount;
  final List<dynamic>? feedbacks;

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
    this.feedbackCount,
    this.feedbacks,
  });

  @override
  State<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends State<ApplicantDetailsScreen> {
  String? _currentStatus;
  bool _isLoading = false;
  bool _isFeedbackLoading = false;
  final JobService _jobService = JobService();
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  List<dynamic> _allFeedbacks = [];
  double _averageRating = 0.0;
  
  /// Builds a widget to display education details
  Widget _buildEducationDetails(dynamic education) {
    if (education == null) return const Text('No education information available');
    
    try {
      // Parse education data
      List<dynamic> educationList;
      if (education is String) {
        // If it's already a string and not JSON, display as is
        if (!education.toString().trim().startsWith('[')) {
          return Text(education.toString());
        }
        
        // Try to parse as JSON
        try {
          educationList = jsonDecode(education);
        } catch (e) {
          return Text(education.toString());
        }
      } else if (education is List) {
        educationList = education;
      } else {
        return Text(education.toString());
      }
      
      if (educationList.isEmpty) return const Text('No education information available');
      
      // Display all education entries
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: educationList.map((edu) {
          if (edu is Map) {
            final degree = edu['degree'] ?? '';
            final institution = edu['institution'] ?? '';
            final year = edu['year'] ?? '';
            final description = edu['description'] ?? '';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$degree${degree.isNotEmpty && institution.isNotEmpty ? ' at ' : ''}$institution',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (year.isNotEmpty)
                    Text(
                      'Year: $year',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(edu.toString()),
            );
          }
        }).toList(),
      );
    } catch (e) {
      // Fallback for any parsing errors
      return Text(education.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _loadSavedStatus();
    _loadAllFeedbacks();

    // Debug application ID
    print('Application ID in ApplicantDetailsScreen: ${widget.applicationId}');
    print('Application ID type: ${widget.applicationId?.runtimeType}');
  }

  void _loadAllFeedbacks() async {
    if (widget.profileId == null) {
      print('DEBUG: Cannot load feedback - profileId is null');
      return;
    }

    print('DEBUG: Loading feedback for profile ID: ${widget.profileId}');
    setState(() {
      _isFeedbackLoading = true;
    });

    try {
      final feedbackData = await _jobService.getSeekerFeedback(widget.profileId!);
      print('DEBUG: Feedback data received: $feedbackData');
      
      final feedbacks = feedbackData['feedbacks'] ?? [];
      final avgRating = (feedbackData['average_rating'] ?? 0.0).toDouble();
      
      print('DEBUG: Loaded ${feedbacks.length} feedbacks with average rating $avgRating');
      
      setState(() {
        _allFeedbacks = feedbacks;
        _averageRating = avgRating;
        _isFeedbackLoading = false;
      });
    } catch (e) {
      print('ERROR: Failed to load feedback: $e');
      setState(() {
        _isFeedbackLoading = false;
      });
      
      // Only show error if this is not the initial load
      if (_allFeedbacks.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not refresh feedback: ${e.toString().split("Exception:").last}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Load saved application status from SharedPreferences
  Future<void> _loadSavedStatus() async {
    if (widget.applicationId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStatus = prefs.getString('application_status_${widget.applicationId}');

      if (savedStatus != null) {
        print('Loaded saved status for application ${widget.applicationId}: $savedStatus');
        setState(() => _currentStatus = savedStatus);
      } else {
        // Fall back to the status passed in from navigation args
        setState(() => _currentStatus = widget.status);
      }

      print('Current status after loading: $_currentStatus');
    } catch (e) {
      print('Error loading saved status: $e');
      setState(() => _currentStatus = widget.status);
    }
  }

  // Save application status to SharedPreferences
  Future<void> _saveStatus(String status) async {
    if (widget.applicationId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('application_status_${widget.applicationId}', status);
      print('Saved status for application ${widget.applicationId}: $status');
    } catch (e) {
      print('Error saving status: $e');
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

    print('DEBUG: Building feedback section with ${feedbacks.length} feedbacks');
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
        print('DEBUG: Rendering feedback item: $feedback');
        
        // Handle different feedback formats safely with detailed debugging
        print('DEBUG: Raw feedback item: $feedback');
        print('DEBUG: Feedback keys: ${feedback.keys.toList()}');
        
        final rating = feedback['rating'] != null ? (feedback['rating'] as num).toDouble() : 0.0;
        print('DEBUG: Rating: $rating');
        
        // Check if comment exists and its type
        final hasComment = feedback.containsKey('comment');
        final commentValue = feedback['comment'];
        final commentType = commentValue?.runtimeType;
        print('DEBUG: Has comment key: $hasComment, Comment value: $commentValue, Type: $commentType');
        
        final comment = hasComment ? (commentValue?.toString() ?? '') : '';
        print('DEBUG: Processed comment: "$comment"');
        
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
                color: Colors.grey.withOpacity(0.1),
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

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
  
  // Show dialog to select next step type (interview or direct hire) or reject
  void _showNextStepDialog(bool isSelect) {
    if (!isSelect) {
      // If rejecting, show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reject Applicant'),
          content: const Text('Are you sure you want to reject this applicant?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateApplicationStatus('REJECTED');
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return;
    }
    
    // If selecting, show next step options
    String selectedNextStep = 'INTERVIEW'; // Default
    int? jobDurationDays;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Next Step'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose the next step for this applicant:'),
              const SizedBox(height: 16),
              
              // Radio buttons for next step options
              RadioListTile<String>(
                title: const Text('Interview'),
                value: 'INTERVIEW',
                groupValue: selectedNextStep,
                onChanged: (value) {
                  setState(() => selectedNextStep = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Direct Hire'),
                value: 'DIRECT_HIRE',
                groupValue: selectedNextStep,
                onChanged: (value) {
                  setState(() => selectedNextStep = value!);
                },
              ),
              
              // Show job duration field only for direct hire
              if (selectedNextStep == 'DIRECT_HIRE')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Job Duration (days)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      jobDurationDays = int.tryParse(value);
                    },
                  ),
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
                _setApplicationNextStep(selectedNextStep, jobDurationDays);
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        ),
      ),
    );
  }
  
  // Update application status (reject)
  Future<void> _updateApplicationStatus(String status) async {
    if (widget.applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Application ID not found')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // This is a simplified approach - in a real app, you'd have an API endpoint to update status
      // For now, we'll use the next step API with a rejected status
      await _jobService.setApplicationNextStep(
        applicationId: widget.applicationId!,
        nextStepType: 'REJECTED', // This isn't a real next step type, but for demonstration
      );
      
      setState(() {
        _currentStatus = 'REJECTED';
        _isLoading = false;
      });
      
      // Save the rejected status to SharedPreferences
      await _saveStatus('REJECTED');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applicant rejected successfully')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  // Set application next step (interview or direct hire)
  Future<void> _setApplicationNextStep(String nextStepType, int? jobDurationDays) async {
    // Debug application ID before using it
    print('Setting next step for application ID: ${widget.applicationId}');
    
    if (widget.applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Application ID not found')),
      );
      return;
    }
    
    // Check if the applicant is already selected or rejected
    if (_isApplicantSelected || _currentStatus == 'REJECTED') {
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
      final newStatus = nextStepType == 'DIRECT_HIRE' ? 'HIRED' : 'INTERVIEW';
      
      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });
      
      // Save the status to SharedPreferences
      await _saveStatus(newStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applicant ${nextStepType == 'DIRECT_HIRE' ? 'hired' : 'selected for interview'} successfully')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Show dialog to add rating and feedback for an approved applicant
  void _showFeedbackDialog() {
    // Reset rating and feedback for new submission
    _rating = 0;
    _feedbackController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate & Give Feedback'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How would you rate this applicant?'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1.0;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Your feedback:'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _feedbackController,
                      decoration: const InputDecoration(
                        hintText: 'Share your experience working with this applicant...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _rating == 0
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _submitFeedback();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Submit feedback and rating to the backend
  void _submitFeedback() async {
    if (_rating == 0 || widget.profileId == null || widget.applicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('DEBUG: Submitting feedback for application ${widget.applicationId} with rating $_rating');
      final result = await _jobService.submitApplicantFeedback(
        applicationId: widget.applicationId!,
        profileId: widget.profileId!,
        rating: _rating,
        comment: _feedbackController.text.trim(),
      );
      
      print('DEBUG: Feedback submission result: $result');
      
      // Close the dialog
      Navigator.of(context).pop();
      
      // Reset the form
      _rating = 0;
      _feedbackController.clear();
      
      // Reload the feedback data
      _loadAllFeedbacks();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('DEBUG: Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: ${e.toString().split("Exception:").last}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            // Basic profile information
            ApplicantProfileCard(
              name: name,
              skills: skills,
              education: education,
              rating: rating,
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading || _isApplicantSelected ? null : () => _showNextStepDialog(true),
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: Text(_currentStatus == 'HIRED' || _currentStatus == 'INTERVIEW' 
                            ? 'Selected' 
                            : 'Select Applicant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.deepPurple.withOpacity(0.5),
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading || _isApplicantSelected ? null : () => _showNextStepDialog(false),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: Text(_currentStatus == 'REJECTED' ? 'Rejected' : 'Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.redAccent.withOpacity(0.5),
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  
                  // Add feedback button only for selected applicants
                  if (_isApplicantSelected) ...[  
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showFeedbackDialog(),
                        icon: const Icon(Icons.star_rate_rounded, size: 24),
                        label: const Text('Rate & Give Feedback'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
