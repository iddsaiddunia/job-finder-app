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
      for (var application in applications) {
        if (application['job'] != null) {
          // Handle different job response formats
          if (application['job'] is Map && application['job']['id'] == jobId) {
            // Job is a nested object with id field
            hasApplied = true;
            developer.log('Found existing application for job ID: $jobId (nested object)');
            break;
          } else if (application['job'] is int && application['job'] == jobId) {
            // Job is just the ID
            hasApplied = true;
            developer.log('Found existing application for job ID: $jobId (direct ID)');
            break;
          }
        }
      }
      
      setState(() {
        _hasApplied = hasApplied;
        _isLoading = false;
      });
      developer.log('Application status: ${_hasApplied ? "Already applied" : "Not applied"}');
    } catch (e) {
      developer.log('Error checking application status: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking application status: $e';
      });
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
            
            // Application status or apply button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _hasApplied
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'You have already applied for this job',
                            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
