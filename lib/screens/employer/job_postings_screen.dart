import 'package:flutter/material.dart';
import '../../services/job_service.dart';

class JobPostingsScreen extends StatefulWidget {
  const JobPostingsScreen({super.key});

  @override
  State<JobPostingsScreen> createState() => _JobPostingsScreenState();
}

class _JobPostingsScreenState extends State<JobPostingsScreen> {
  final JobService _jobService = JobService();
  String selectedFilter = 'All';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _jobPostings = [];
  
  @override
  void initState() {
    super.initState();
    _fetchJobPostings();
  }
  
  Future<void> _fetchJobPostings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final jobs = await _jobService.getEmployerJobs();
      setState(() {
        _jobPostings = jobs;
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
    // Filter jobs based on selected filter
    List<Map<String, dynamic>> filteredJobs = [];
    
    if (!_isLoading && !_hasError) {
      filteredJobs = selectedFilter == 'All'
          ? _jobPostings
          : _jobPostings.where((job) => 
              job['is_active'] == (selectedFilter == 'Active')).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Postings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchJobPostings,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/employer/post_job');
              if (result == true) {
                _fetchJobPostings();
              }
            },
            tooltip: 'Post New Job',
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
                          'Error loading jobs', 
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
                          onPressed: _fetchJobPostings,
                          child: const Text('Try Again'),
                        ),
                    ],
                  ),
                ))
              : RefreshIndicator(
                  onRefresh: _fetchJobPostings,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: selectedFilter == 'All',
                                onSelected: (val) => setState(() => selectedFilter = 'All'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Active'),
                                selected: selectedFilter == 'Active',
                                onSelected: (val) => setState(() => selectedFilter = 'Active'),
                                selectedColor: Colors.green.shade100,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Closed'),
                                selected: selectedFilter == 'Closed',
                                onSelected: (val) => setState(() => selectedFilter = 'Closed'),
                                selectedColor: Colors.red.shade100,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _jobPostings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.work_off, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No job postings found',
                                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Post Your First Job'),
                                    onPressed: () => Navigator.pushNamed(context, '/employer/post_job'),
                                  ),
                                ],
                              ),
                            )
                                                    : ListView.builder(
                              itemCount: filteredJobs.length,
                              padding: const EdgeInsets.only(bottom: 16),
                              itemBuilder: (context, index) {
                                final job = filteredJobs[index];
                                final bool isActive = job['is_active'] ?? true;
                                final String status = isActive ? 'Active' : 'Closed';
                                final int applicantCount = job['applicant_count'] ?? 0;
                                
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to job details screen
                                    Navigator.pushNamed(
                                      context,
                                      '/employer/job_details',
                                      arguments: job['id'],
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Header with title and status
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Job icon
                                              CircleAvatar(
                                                backgroundColor: Colors.deepPurple.shade50,
                                                child: const Icon(Icons.work, color: Colors.deepPurple),
                                              ),
                                              const SizedBox(width: 12),
                                              // Title and location
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      job['title'] ?? 'Untitled Job',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold, 
                                                        fontSize: 18
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                        const SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            job['location'] ?? 'No location specified',
                                                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Status chip
                                              Chip(
                                                label: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: isActive ? Colors.green[700] : Colors.red[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor: isActive ? Colors.green[50] : Colors.red[50],
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          const Divider(height: 1),
                                          const SizedBox(height: 12),
                                          // Job details
                                          Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  _buildInfoChip(
                                                    Icons.attach_money, 
                                                    '${job['salary_min'] ?? 0} - ${job['salary_max'] ?? 0}',
                                                    Colors.green,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildInfoChip(
                                                    Icons.business_center, 
                                                    job['job_type'] ?? 'Unknown',
                                                    Colors.blue,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildInfoChip(
                                                    Icons.people, 
                                                    '$applicantCount applicants',
                                                    Colors.orange,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildInfoChip(
                                                    Icons.calendar_today, 
                                                    'Posted: ${job['created_at']?.toString().substring(0, 10) ?? 'Unknown'}',
                                                    Colors.purple,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // View details indicator
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Tap to view details',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/employer/post_job'),
        child: const Icon(Icons.add),
        tooltip: 'Post New Job',
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}