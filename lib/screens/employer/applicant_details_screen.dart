import 'package:flutter/material.dart';
import '../../widgets/applicant_profile_card.dart';
import '../../widgets/resume_viewer.dart';
import '../../widgets/experience_timeline.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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
  }

  /// Builds a widget to display feedback information
  Widget _buildFeedbackSection(List<dynamic>? feedbacks) {
    if (feedbacks == null || feedbacks.isEmpty) {
      return const Text('No feedback available for this applicant.');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...feedbacks.map((feedback) {
          final rating = feedback['rating'] ?? 0.0;
          final comment = feedback['comment'] ?? 'No comment provided';
          final date = feedback['created_at'] ?? '';
          final providerName = feedback['provider_name'] ?? 'Anonymous';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
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
                            (index) => Icon(
                              index < (rating as num).floor() 
                                ? Icons.star 
                                : index < rating 
                                  ? Icons.star_half
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From: $providerName',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
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
    final feedbackCount = args?['feedback_count'] as int? ?? widget.feedbackCount ?? 0;
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
                  label: Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                const SizedBox(width: 16),
                if (email != null) ...[
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
                if (phone != null) ...[
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
            
            // Feedback section if available
            if (feedbacks != null && feedbacks.isNotEmpty) ...[  
              const SizedBox(height: 24),
              Divider(height: 1, thickness: 1, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Feedback ($feedbackCount)', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                  ),
                  if (feedbackCount > 0)
                    Row(
                      children: [
                        const Text('Average: ', style: TextStyle(fontSize: 14)),
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating.floor() 
                              ? Icons.star 
                              : index < rating 
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeedbackSection(feedbacks),
            ],
            
            const SizedBox(height: 24),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Demo: mark as selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Applicant selected!')),
                      );
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Select Applicant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Demo: reject applicant
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Applicant rejected')),
                    );
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
