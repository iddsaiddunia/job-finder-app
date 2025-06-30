import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_finder/screens/job_finder/application_status_screen.dart';
import 'package:job_finder/screens/job_finder/profile_screen.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../services/user_service.dart';
import '../../services/token_storage.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_badge.dart';
import '../common/notifications_screen.dart';

class JobFinderHomeScreen extends StatefulWidget {
  const JobFinderHomeScreen({super.key});

  @override
  State<JobFinderHomeScreen> createState() => _JobFinderHomeScreenState();
}

class _JobFinderHomeScreenState extends State<JobFinderHomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = [
    _DashboardView(),
    _JobListingsView(),
    ApplicationStatusScreen(),
    JobFinderProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return NotificationBadge(
                child: const Icon(Icons.notifications),
                onTap: () {
                  Navigator.of(context).pushNamed('/job_finder/notifications');
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Job Listings';
      case 2:
        return 'Application Status';
      case 3:
        return 'Profile';
      default:
        return 'Job RS';
    }
  }
}

// Dashboard View
class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

// Compact Stat Card Widget
class _CompactStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CompactStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _DashboardViewState extends State<_DashboardView> {
  String userName = 'User';
  Map<String, dynamic> dashboardStats = {};
  List<Map<String, dynamic>> recommendedJobs = [];
  bool isLoading = true;
  String? error;
  bool profileUpdated = true; // Track profile status

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load user data
      final loginData = await TokenStorage.getLoginData();
      final userEmail = loginData['email'] ?? 'User';
      String displayName = userEmail.split('@')[0]; // Default to username part of email
      bool isProfileUpdated = false;
      
      // Try to get user profile for full name and profile status
      try {
        // Try job seeker profile first
        try {
          final seekerProfile = await UserService().getJobSeekerProfile();
          displayName = seekerProfile['full_name'] ?? displayName;
          isProfileUpdated = seekerProfile['profile_updated'] ?? false;
        } catch (e) {
          // If not a job seeker, try recruiter profile
          try {
            final recruiterProfile = await UserService().getRecruiterProfile();
            displayName = recruiterProfile['company_name'] ?? displayName;
            isProfileUpdated = recruiterProfile['profile_updated'] ?? false;
          } catch (e) {
            // Not a recruiter either, keep default name
          }
        }
        
        setState(() {
          userName = displayName;
          profileUpdated = isProfileUpdated;
        });
        
        // Show profile update alert if profile is not updated
        if (!isProfileUpdated && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showProfileUpdateAlert();
          });
        }
      } catch (e) {
        setState(() {
          userName = displayName;
          profileUpdated = false; // Assume profile needs update if we can't verify
        });
      }

      // Load dashboard stats and recommended jobs in parallel
      final results = await Future.wait([
        JobService().getDashboardStats().catchError((e) => <String, dynamic>{}),
        JobService().getRecommendedJobs().catchError((e) => <Map<String, dynamic>>[]),
      ]);

      setState(() {
        dashboardStats = results[0] as Map<String, dynamic>;
        recommendedJobs = results[1] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _showProfileUpdateAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Your Profile'),
        content: const Text('Please update your profile to get better job recommendations.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/job_finder/profile'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Failed to load dashboard', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(error!, style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDashboardData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          // Greeting
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.deepPurple[100],
                child: Icon(Icons.person, color: Colors.deepPurple, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Profile Update Banner (show only if profile not updated)
          if (!profileUpdated)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your profile to get better job recommendations',
                          style: TextStyle(color: Colors.orange[700], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/job_finder/profile'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange[100],
                      foregroundColor: Colors.orange[800],
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CompactStatCard(
                        icon: Icons.work_outline,
                        label: 'Applied',
                        value: (dashboardStats['applications_count'] ?? 0).toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactStatCard(
                        icon: Icons.star_outline,
                        label: 'Matches',
                        value: (dashboardStats['matches_count'] ?? 0).toString(),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactStatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Interviews',
                        value: (dashboardStats['interviews_count'] ?? 0).toString(),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactStatCard(
                        icon: Icons.business_center,
                        label: 'Direct Hires',
                        value: (dashboardStats['direct_hires_count'] ?? 0).toString(),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Recommended Jobs Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recommended Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  if (context.findAncestorStateOfType<_JobFinderHomeScreenState>() != null) {
                    context.findAncestorStateOfType<_JobFinderHomeScreenState>()!._onItemTapped(1);
                  }
                },
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Recommended Jobs List
          if (recommendedJobs.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No recommended jobs yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('Complete your profile to get better job recommendations', style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            ...recommendedJobs.map((job) => _JobCard(job: job)).toList(),
        ],
      ),
    );
  }
}

// Job Card Widget for recommended jobs
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.work, color: Colors.deepPurple, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? 'Job Title',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company_name'] ?? job['company'] ?? 'Company',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job['location'] ?? 'Location',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (job['salary_range'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.attach_money, size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              job['salary_range'],
                              style: TextStyle(color: Colors.green[600], fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border, color: Colors.grey[400]),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Save job feature coming soon!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (job['job_type'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job['job_type'],
                      style: TextStyle(color: Colors.blue[700], fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showJobDetails(context, job),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showJobDetails(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _JobDetailsSheet(
          job: job,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// Job Details Sheet
class _JobDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> job;
  final ScrollController scrollController;

  const _JobDetailsSheet({required this.job, required this.scrollController});
  
  // Helper method to safely extract job data
  String _safeGet(String key, String defaultValue) {
    final value = job[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Extract job data with null safety
    final String title = _safeGet('title', 'Job Title');
    final String company = job['company_name']?.toString() ?? job['company']?.toString() ?? 'Company';
    final String location = _safeGet('location', 'Remote');
    final String salary = job['salary_range']?.toString() ?? job['salary']?.toString() ?? 'Negotiable';
    final String type = _safeGet('type', 'Full-time');
    final String duration = _safeGet('duration', 'Not specified');
    final String description = _safeGet('description', 'No description available');
    final String requirements = _safeGet('requirements', 'No specific requirements listed');
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  company,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(location)),
                  ],
                ),
                const SizedBox(height: 8),
                  Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(salary, style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w500))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.work_outline, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    Text(type, style: TextStyle(color: Colors.blue[700])),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, color: Colors.orange[400], size: 18),
                    const SizedBox(width: 8),
                    Text(duration, style: TextStyle(color: Colors.orange[700])),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 20),
                const Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(requirements),
                const SizedBox(height: 40),
              ],
            ),
          ),
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _applyForJob(context, job),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _applyForJob(BuildContext context, Map<String, dynamic> job) async {
    try {
      await JobService().applyForJob(jobId: job['id']);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }
}

// Job Listings View
class _JobListingsView extends StatefulWidget {
  const _JobListingsView();

  @override
  State<_JobListingsView> createState() => _JobListingsViewState();
}

class _JobListingsViewState extends State<_JobListingsView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  String _selectedDuration = 'Any';
  TabController? _tabController;
  
  // Data states
  List<Map<String, dynamic>> allJobs = [];
  List<Map<String, dynamic>> recommendedJobs = [];
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> _userApplications = []; // Store user's applications

  // Helper methods for formatting application status
  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.blue;
      case 'selected':
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _formatStatus(String status) {
    // Capitalize first letter and format status for display
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
  
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  // Sample data for fallback
  final List<Map<String, String>> sampleJobs = [
      {
        'title': 'Flutter Developer',
        'company': 'TechCorp',
        'location': 'Remote',
        'salary': '2,000/mo',
        'type': 'Contract',
        'duration': '6 months',
      },
      {
        'title': 'Backend Engineer',
        'company': 'DataSoft',
        'location': 'Nairobi',
        'salary': '3,000/mo',
        'type': 'Short Term',
        'duration': '3 months',
      },
      {
        'title': 'UI/UX Designer',
        'company': 'Creative Studio',
        'location': 'Dar es Salaam',
        'salary': '1,500/mo',
        'type': 'Contract',
        'duration': '1 year',
      },
    ];

  final List<String> durations = ['Any', '1 month', '3 months', '6 months', '1 year'];
  final List<String> types = ['All', 'Contract', 'Short Term'];
  
  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the correct vsync and length
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
    _loadUserApplications();
  }
  
  // Load user's applications to track which jobs they've applied to
  Future<void> _loadUserApplications() async {
    try {
      final applications = await JobService().getApplications();
      if (mounted) {
        setState(() {
          _userApplications = applications;
        });
      }
      print('Fetched ${applications.length} user applications');
    } catch (e) {
      print('Error fetching user applications: $e');
      // Don't update state or show error - this is a background operation
    }
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadJobs() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    
    try {
      // Load both regular and recommended jobs in parallel
      final results = await Future.wait([
        JobService().getJobs().catchError((e) => <Map<String, dynamic>>[]),
        JobService().getRecommendedJobs().catchError((e) => <Map<String, dynamic>>[]),
      ]);
      
      setState(() {
        allJobs = results[0];
        recommendedJobs = results[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Fallback to sample data if API fails
        allJobs = List<Map<String, dynamic>>.from(sampleJobs);
        recommendedJobs = [];
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Filter jobs based on search and filter criteria
  List<Map<String, dynamic>> _filterJobs(List<Map<String, dynamic>> jobsList) {
    return jobsList.where((job) {
      final matchesSearch = _searchController.text.isEmpty ||
          job['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          job['company'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesType = _selectedType == 'All' || job['type'].toString() == _selectedType;
      final matchesDuration = _selectedDuration == 'Any' || job['duration'].toString() == _selectedDuration;
      return matchesSearch && matchesType && matchesDuration;
    }).toList();
  }
  
  // Job card widget for displaying job listings
  Widget _buildJobCard(Map<String, dynamic> job, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Extract job data with null safety based on backend model
    final String title = job['title']?.toString() ?? 'Untitled Position';
    final String type = job['job_type']?.toString() ?? 'Full-time';
    final String company = job['company_name']?.toString() ?? job['recruiter']?['company_name']?.toString() ?? 'Company';
    final String location = job['location']?.toString() ?? 'Remote';
    final bool isRemote = job['is_remote'] == true;
    final String displayLocation = isRemote ? 'Remote' : location;
    
    // Format salary range
    final dynamic salaryMin = job['salary_min'];
    final dynamic salaryMax = job['salary_max'];
    String salary = 'Negotiable';
    if (salaryMin != null && salaryMax != null) {
      salary = '\$${salaryMin.toString()} - \$${salaryMax.toString()}';
    }
    
    // Get experience level for duration display
    final String experienceLevel = job['experience_level']?.toString() ?? '';
    
    // Check if this job is in the user's applications
    final int? jobId = job['id'];
    bool hasApplied = false;
    String? applicationStatus;
    String? appliedDate;
    
    // Check if this job has application status directly (from Applied tab)
    if (job.containsKey('application_status')) {
      hasApplied = true;
      applicationStatus = job['application_status']?.toString();
      appliedDate = job['applied_at']?.toString();
    }
    // Otherwise check if it's in the user's applications list
    else if (jobId != null && _userApplications.isNotEmpty) {
      for (final application in _userApplications) {
        // Handle different job response formats
        bool isMatch = false;
        if (application['job'] is Map) {
          // Job is a nested object with id field
          isMatch = application['job']['id'] == jobId;
        } else if (application['job'] is int) {
          // Job is just the ID
          isMatch = application['job'] == jobId;
        }
        
        if (isMatch) {
          hasApplied = true;
          applicationStatus = application['status']?.toString();
          appliedDate = application['applied_at']?.toString();
          break;
        }
      }
    }
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 7, horizontal: screenWidth < 400 ? 0 : 2),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: screenWidth < 400 ? 10 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.deepPurple[50],
                  child: Icon(Icons.business, color: Colors.deepPurple, size: 20),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: type == 'Contract'
                                  ? Color(0xFFEDE7F6) // light purple
                                  : Color(0xFFFFF3E0), // light orange
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: type == 'Contract'
                                    ? Colors.deepPurple
                                    : Colors.deepOrange,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(experienceLevel, 
                           style: TextStyle(fontSize: 11.5, color: Colors.blueGrey), 
                           maxLines: 1, 
                           overflow: TextOverflow.ellipsis),
                      SizedBox(height: 2),
                      Text(company, 
                           style: TextStyle(fontSize: 13, color: Colors.grey[700]), 
                           maxLines: 1, 
                           overflow: TextOverflow.ellipsis),
                      SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 13, color: Colors.deepPurple[200]),
                          SizedBox(width: 2),
                          Flexible(
                            child: Text(displayLocation, 
                                     style: TextStyle(fontSize: 11.5, color: Colors.grey[600]), 
                                     maxLines: 1, 
                                     overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Application status and date row (only shown if applied)
                if (hasApplied && applicationStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(applicationStatus).withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatStatus(applicationStatus),
                            style: TextStyle(
                              color: _getStatusColor(applicationStatus),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (appliedDate != null) ...[
                          SizedBox(width: 8),
                          Text(
                            'Applied: ${_formatDate(appliedDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        salary,
                        style: TextStyle(
                          color: Colors.deepPurple[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Spacer(),
                    if (hasApplied)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/job_finder/job_details',
                            arguments: job,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          minimumSize: Size(0, 32),
                          textStyle: TextStyle(fontSize: 13),
                        ),
                        child: Text('View'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/job_finder/job_details',
                            arguments: job,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          minimumSize: Size(0, 32),
                          textStyle: TextStyle(fontSize: 13),
                        ),
                        child: Text('Apply'),
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

  @override
  Widget build(BuildContext context) {
    // Apply filtering to both job lists
    final filteredAllJobs = _filterJobs(allJobs);
    final filteredRecommendedJobs = _filterJobs(recommendedJobs);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search jobs, companies... ',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Material(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      builder: (ctx) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Filter Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(height: 18),
                              Text('Job Type', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: types.map((type) => ChoiceChip(
                                  label: Text(type),
                                  selected: _selectedType == type,
                                  onSelected: (selected) {
                                    setState(() => _selectedType = type);
                                    Navigator.pop(context);
                                  },
                                )).toList(),
                              ),
                              SizedBox(height: 18),
                              Text('Duration', style: TextStyle(fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              DropdownButton<String>(
                                value: _selectedDuration,
                                items: durations.map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d),
                                )).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedDuration = val ?? 'Any');
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Active filter chips
        if (_selectedType != 'All' || _selectedDuration != 'Any')
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: Wrap(
              spacing: 8,
              children: [
                if (_selectedType != 'All')
                  InputChip(
                    label: Text(_selectedType),
                    onDeleted: () => setState(() => _selectedType = 'All'),
                  ),
                if (_selectedDuration != 'Any')
                  InputChip(
                    label: Text(_selectedDuration),
                    onDeleted: () => setState(() => _selectedDuration = 'Any'),
                  ),
              ],
            ),
          ),
          
        // Tab bar for All Jobs and Recommended Jobs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController!,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'All Jobs'),
              Tab(text: 'Recommended'),
              Tab(text: 'Applied'),
            ],
          ),
        ),
        
        // Loading indicator
        if (isLoading)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          )
        else if (error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('Failed to load jobs', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadJobs,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: [
                // All Jobs Tab
                filteredAllJobs.isEmpty
                  ? Center(child: Text('No jobs match your filters'))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredAllJobs.length,
                      itemBuilder: (context, index) => _buildJobCard(filteredAllJobs[index], context),
                    ),
                    
                // Recommended Jobs Tab
                filteredRecommendedJobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.recommend, color: Colors.grey[400], size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No recommended jobs yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Complete your profile to get personalized recommendations',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredRecommendedJobs.length,
                      itemBuilder: (context, index) => _buildJobCard(filteredRecommendedJobs[index], context),
                    ),
                    
                // Applied Jobs Tab
                _userApplications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, color: Colors.grey[400], size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No job applications yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Jobs you apply to will appear here',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _tabController?.animateTo(0),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text('Browse Jobs'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _userApplications.length,
                      itemBuilder: (context, index) {
                        final application = _userApplications[index];
                        final jobData = application['job'];
                        
                        // Handle different job response formats
                        Map<String, dynamic> jobDetails;
                        if (jobData is Map) {
                          // Job is already a map with details
                          jobDetails = Map<String, dynamic>.from(jobData);
                        } else {
                          // Find the job in allJobs by ID
                          final jobId = jobData;
                          final matchingJob = allJobs.firstWhere(
                            (job) => job['id'] == jobId,
                            orElse: () => <String, dynamic>{
                              'title': 'Job #$jobId',
                              'company_name': 'Unknown',
                              'location': 'Unknown',
                            },
                          );
                          jobDetails = matchingJob;
                        }
                        
                        // Add application status to the job details
                        jobDetails['application_status'] = application['status'];
                        jobDetails['applied_at'] = application['applied_at'];
                        
                        return _buildJobCard(jobDetails, context);
                      },
                    ),
              ],
            ),
          ),
      ],
    );
  }
}

// Application Status View
class _ApplicationStatusView extends StatelessWidget {
  const _ApplicationStatusView();

  final List<Map<String, dynamic>> applications = const [
    {
      'jobTitle': 'Flutter Developer',
      'company': 'TechCorp',
      'status': 'Under Review',
      'rating': 4.0,
    },
    {
      'jobTitle': 'Backend Engineer',
      'company': 'DataSoft',
      'status': 'Accepted',
      'rating': 4.5,
    },
    {
      'jobTitle': 'Full Stack Engineer',
      'company': 'WebGen',
      'status': 'Rejected',
      'rating': 3.0,
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green[100]!;
      case 'Rejected':
        return Colors.red[100]!;
      case 'Under Review':
      default:
        return Colors.amber[100]!;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green[800]!;
      case 'Rejected':
        return Colors.red[800]!;
      case 'Under Review':
      default:
        return Colors.amber[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      itemCount: applications.length,
      itemBuilder: (context, idx) {
        final app = applications[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple[50],
                  child: Icon(Icons.work, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${app['jobTitle']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(app['company'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(app['status']),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              app['status'],
                              style: TextStyle(
                                color: _statusTextColor(app['status']),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[700], size: 18),
                              const SizedBox(width: 4),
                              Text('Rating: ${app['rating']}', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Profile View
class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _isAvailable = true;

  void _logout() async {
    try {
      final success = await AuthService().logout();
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = 'Jane N. Doe';
    String email = 'jane.doe@email.com';
    String phone = '+255 712 345 678';
    String linkedIn = 'linkedin.com/in/janedoe';
    String education = 'BSc Software Engineering, University of Dar es Salaam';
    final ValueNotifier<List<String>> skills = ValueNotifier([
      'Flutter', 'Dart', 'OOP', 'Git', 'SQL', 'Firebase', 'UI/UX'
    ]);
    final ValueNotifier<List<Map<String, String>>> experiences = ValueNotifier([
      {
        'title': 'Flutter Developer',
        'company': 'TechCorp Solutions',
        'duration': 'Mar 2022 - Present',
        'desc': 'Developed and maintained cross-platform mobile apps for fintech and e-commerce clients.'
      },
      {
        'title': 'Software Engineering Intern',
        'company': 'WebGen Ltd.',
        'duration': 'Jun 2021 - Feb 2022',
        'desc': 'Assisted in full stack web development, QA testing, and documentation.'
      },
    ]);

    void _showAddSkillDialog(BuildContext context) {
      final skillController = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add Skill'),
          content: TextField(
            controller: skillController,
            decoration: const InputDecoration(hintText: 'Skill name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final skill = skillController.text.trim();
                if (skill.isNotEmpty && !skills.value.contains(skill)) {
                  skills.value = [...skills.value, skill];
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    void _showAddOrEditExperienceSheet(BuildContext context, {Map<String, String>? exp, int? idx}) {
      final titleController = TextEditingController(text: exp?['title'] ?? '');
      final companyController = TextEditingController(text: exp?['company'] ?? '');
      final durationController = TextEditingController(text: exp?['duration'] ?? '');
      final descController = TextEditingController(text: exp?['desc'] ?? '');
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24,
            top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(idx == null ? 'Add Experience' : 'Edit Experience', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Company', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    final newExp = {
                      'title': titleController.text.trim(),
                      'company': companyController.text.trim(),
                      'duration': durationController.text.trim(),
                      'desc': descController.text.trim(),
                    };
                    if (newExp.values.any((v) => v.isEmpty)) return;
                    if (idx == null) {
                      experiences.value = [...experiences.value, newExp];
                    } else {
                      final updated = [...experiences.value];
                      updated[idx] = newExp;
                      experiences.value = updated;
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: Text(idx == null ? 'Add' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _showEditProfile(BuildContext context) {
      final nameController = TextEditingController(text: name);
      final emailController = TextEditingController(text: email);
      final phoneController = TextEditingController(text: phone);
      final educationController = TextEditingController(text: education);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24,
            top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: educationController,
                decoration: const InputDecoration(labelText: 'Education', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  // Save logic here
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      children: [
        // Availability toggle at the top
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _isAvailable ? 'Active' : 'Inactive',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isAvailable ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            Switch(
              value: _isAvailable,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              onChanged: (val) {
                setState(() {
                  _isAvailable = val;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.deepPurple[50],
                      child: Text(
                        name.split(' ').map((e) => e[0]).take(2).join(),
                        style: const TextStyle(fontSize: 28, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                onPressed: () => _showEditProfile(context),
                                tooltip: 'Edit Profile',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.school, size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 6),
                              Expanded(child: Text(education, style: TextStyle(fontSize: 15, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 1.2),
                const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.email, color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(email, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(phone, style: const TextStyle(fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.link, color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(linkedIn, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const Divider(height: 32, thickness: 1.2),
                const Text('Skills', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                ValueListenableBuilder<List<String>>(
                  valueListenable: skills,
                  builder: (context, skillList, _) => Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: skillList.map<Widget>((skill) => Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.deepPurple[50],
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      visualDensity: VisualDensity.compact,
                      deleteIcon: const Icon(Icons.close, size: 17),
                      onDeleted: () {
                        final updated = [...skillList]..remove(skill);
                        skills.value = updated;
                      },
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<Map<String, String>>>(
          valueListenable: experiences,
          builder: (context, expList, _) => Column(
            children: expList.asMap().entries.map((entry) {
              final idx = entry.key;
              final exp = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exp['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(exp['company']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(exp['duration']!, style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(exp['desc']!, style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple, size: 20),
                            tooltip: 'Edit',
                            onPressed: () => _showAddOrEditExperienceSheet(context, exp: exp, idx: idx),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            tooltip: 'Delete',
                            onPressed: () {
                              final updated = [...expList]..removeAt(idx);
                              experiences.value = updated;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _showAddOrEditExperienceSheet(context),
          icon: const Icon(Icons.add, color: Colors.deepPurple),
          label: const Text('Add Experience', style: TextStyle(color: Colors.deepPurple)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepPurple),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: _logout,
          ),
        ),
      ],
    );
  }
}

// Notifications are now handled by the NotificationsScreen in common/notifications_screen.dart
