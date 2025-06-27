import 'package:flutter/material.dart';
import '../../services/job_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;
  
  const JobDetailsScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final JobService _jobService = JobService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic> _jobDetails = {};
  
  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }
  
  Future<void> _fetchJobDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final jobDetails = await _jobService.getJobDetails(widget.jobId);
      setState(() {
        _jobDetails = jobDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Job Details' : _jobDetails['title'] ?? 'Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchJobDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading job details', 
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _errorMessage.length > 200 
                            ? '${_errorMessage.substring(0, 200)}...'
                            : _errorMessage,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchJobDetails,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            )
          : _buildJobDetails(),
    );
  }
  
  Widget _buildJobDetails() {
    final bool isActive = _jobDetails['is_active'] ?? true;
    final String status = isActive ? 'Active' : 'Closed';
    final int applicantCount = _jobDetails['applicant_count'] ?? 0;
    final List<dynamic> skills = _jobDetails['skills'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  _jobDetails['title'] ?? 'Untitled Job',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: isActive ? Colors.green[50] : Colors.red[50],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Location and job type
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _jobDetails['location'] ?? 'No location specified',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.business_center, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _jobDetails['job_type'] ?? 'Unknown',
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (_jobDetails['is_remote'] == true) ...[
                const SizedBox(width: 16),
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Remote',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Salary range
          _buildSectionTitle('Salary Range'),
          Text(
            '${_jobDetails['salary_min'] ?? 0} - ${_jobDetails['salary_max'] ?? 0}',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          _buildSectionTitle('Description'),
          Text(
            _jobDetails['description'] ?? 'No description provided',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Requirements
          _buildSectionTitle('Requirements'),
          _buildListItems(_jobDetails['requirements'] ?? []),
          
          const SizedBox(height: 16),
          
          // Skills
          _buildSectionTitle('Required Skills'),
          skills.isEmpty
              ? const Text('No specific skills required')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.blue.shade50,
                  )).toList(),
                ),
          
          const SizedBox(height: 16),
          
          // Benefits
          _buildSectionTitle('Benefits'),
          _buildListItems(_jobDetails['benefits'] ?? []),
          
          const SizedBox(height: 16),
          
          // Experience level
          _buildSectionTitle('Experience Level'),
          Text(
            _jobDetails['experience_level'] ?? 'Not specified',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Application deadline
          _buildSectionTitle('Application Deadline'),
          Text(
            _jobDetails['application_deadline'] ?? 'No deadline specified',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Recruiting size
          _buildSectionTitle('Recruiting Size'),
          Text(
            '${_jobDetails['recruiting_size'] ?? 'Not specified'} positions',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Next step
          _buildSectionTitle('Next Step'),
          Text(
            _jobDetails['next_step'] ?? 'Not specified',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Applicant count
          _buildSectionTitle('Applications'),
          Text(
            '$applicantCount applicant${applicantCount == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          // Always show buttons for employer view
          if (true) ...[            
            // View Applicants button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/employer/job_applicants',
                  arguments: {'jobId': _jobDetails['id']},
                );
              },
              icon: const Icon(Icons.people),
              label: Text('View Applicants ($applicantCount)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Edit and Close buttons
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     ElevatedButton.icon(
            //       onPressed: () {
            //         // Navigate to edit job screen
            //         Navigator.pushNamed(
            //           context,
            //           '/employer/edit_job',
            //           arguments: _jobDetails['id'],
            //         );
            //       },
            //       icon: const Icon(Icons.edit),
            //       label: const Text('Edit Job'),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.blue,
            //         foregroundColor: Colors.white,
            //       ),
            //     ),
            //     ElevatedButton.icon(
            //       onPressed: () {
            //         // Toggle job status
            //         // This is a placeholder - implement the actual API call
            //         showDialog(
            //           context: context,
            //           builder: (context) => AlertDialog(
            //             title: Text(isActive ? 'Close Job' : 'Reopen Job'),
            //             content: Text(
            //               isActive 
            //                 ? 'Are you sure you want to close this job posting? It will no longer be visible to job seekers.'
            //                 : 'Are you sure you want to reopen this job posting? It will be visible to job seekers again.'
            //             ),
            //             actions: [
            //               TextButton(
            //                 onPressed: () => Navigator.pop(context),
            //                 child: const Text('Cancel'),
            //               ),
            //               TextButton(
            //                 onPressed: () {
            //                   // Implement toggle job status API call
            //                   Navigator.pop(context);
            //                 },
            //                 child: const Text('Confirm'),
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //       icon: Icon(isActive ? Icons.close : Icons.check),
            //       label: Text(isActive ? 'Close Job' : 'Reopen Job'),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: isActive ? Colors.red : Colors.green,
            //         foregroundColor: Colors.white,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
  
  Widget _buildListItems(List<dynamic> items) {
    if (items.isEmpty) {
      return const Text('None specified');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        // Handle different item types (String or Map)
        String displayText;
        if (item is String) {
          displayText = item;
        } else if (item is Map) {
          // If it's a map, try to get a meaningful value to display
          // Assuming the map has a 'name' or 'title' field, or use toString() as fallback
          displayText = item['name'] ?? item['title'] ?? item['value'] ?? item.toString();
        } else {
          // For any other type, convert to string
          displayText = item.toString();
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
