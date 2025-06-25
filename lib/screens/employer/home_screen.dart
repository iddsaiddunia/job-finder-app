import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_badge.dart';
import 'profile_screen.dart';
import 'post_job_screen.dart';
import 'job_postings_screen.dart';
import 'notifications_tab.dart';
import '../../services/job_service.dart';
import '../common/notifications_screen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    _EmployerDashboardTab(
      onPostJob: () => _onItemTapped(2),
      onNotifications: () => _onItemTapped(3), // Notifications is now index 3
    ),
    const _EmployerJobPostingsTab(),
    const _EmployerPostJobTab(),
    // const EmployerNotificationsTab(),
    NotificationsScreen(),
    const _EmployerProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) => const TextStyle(fontSize: 11)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          height: 60,
          backgroundColor: Colors.white,
          indicatorColor: Colors.deepPurple.shade50,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined, size: 22),
              selectedIcon: const Icon(Icons.dashboard, size: 22),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: const Icon(Icons.list_alt_outlined, size: 22),
              selectedIcon: const Icon(Icons.list_alt, size: 22),
              label: 'Postings',
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_box_outlined, size: 22),
              selectedIcon: const Icon(Icons.add_box, size: 22),
              label: 'Post Job',
            ),
            Consumer<NotificationProvider>(
              builder: (context, notificationProvider, _) {
                return NavigationDestination(
                  icon: NotificationBadge(
                    child: const Icon(Icons.notifications_none_outlined, size: 22),
                    onTap: () {
                      if (_selectedIndex != 3) {
                        _onItemTapped(3);
                      }
                    },
                  ),
                  selectedIcon: const Icon(Icons.notifications, size: 22),
                  label: 'Notifications',
                );
              },
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, size: 22),
              selectedIcon: const Icon(Icons.person, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployerDashboardTab extends StatefulWidget {
  final VoidCallback? onPostJob;
  final VoidCallback? onNotifications;
  const _EmployerDashboardTab({this.onPostJob, this.onNotifications});

  @override
  State<_EmployerDashboardTab> createState() => _EmployerDashboardTabState();
}

class _EmployerDashboardTabState extends State<_EmployerDashboardTab> {
  final JobService _jobService = JobService();
  bool _isLoading = true;
  String? _error;
  
  // Dashboard data
  int totalJobs = 0;
  int totalApplicants = 0;
  int activeJobs = 0;
  int newApplications = 0;
  int applicationsTrend = 0;
  List<Map<String, dynamic>> recentJobs = [];
  
  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }
  
  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final stats = await _jobService.getRecruiterDashboardStats();
      
      // Assign colors to recent jobs
      final colors = [Colors.deepPurple, Colors.blue, Colors.teal, Colors.orange, Colors.indigo];
      final recentJobsData = List<Map<String, dynamic>>.from(stats['recent_jobs'] ?? []);
      
      for (int i = 0; i < recentJobsData.length; i++) {
        recentJobsData[i]['color'] = colors[i % colors.length];
      }
      
      setState(() {
        totalJobs = stats['total_jobs'] ?? 0;
        totalApplicants = stats['total_applicants'] ?? 0;
        activeJobs = stats['active_jobs'] ?? 0;
        newApplications = stats['new_applications'] ?? 0;
        applicationsTrend = stats['trends']?['applications'] ?? 0;
        recentJobs = recentJobsData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _fetchDashboardData: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employer Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: widget.onNotifications,
                ),
                Positioned(
                  right: 0,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading dashboard data',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_error!.contains('Unauthorized') || _error!.contains('401'))
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to login screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Log In Again'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _fetchDashboardData,
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome banner with gradient background
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple,
                                Colors.deepPurple.shade700,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Today is ${DateFormat('d MMMM, yyyy').format(DateTime.now())}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: widget.onPostJob,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Post a New Job'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Dashboard summary section
                        const Text(
                          'Dashboard Summary',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.25, // Further adjusted to prevent overflow
                          children: [
                            _DashboardSummaryCard(
                              title: 'Total Jobs',
                              value: totalJobs.toString(),
                              icon: Icons.work,
                              color: Colors.blue,
                              trend: null,
                            ),
                            _DashboardSummaryCard(
                              title: 'Active Jobs',
                              value: activeJobs.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                              trend: null,
                            ),
                            _DashboardSummaryCard(
                              title: 'Total Applicants',
                              value: totalApplicants.toString(),
                              icon: Icons.people,
                              color: Colors.orange,
                              trend: null,
                            ),
                            _DashboardSummaryCard(
                              title: 'New Applications',
                              value: newApplications.toString(),
                              icon: Icons.person_add,
                              color: Colors.purple,
                              trend: applicationsTrend,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Recent job postings section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Job Postings',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to job postings screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const JobPostingsScreen(),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (recentJobs.isNotEmpty)
                          ...recentJobs.map((job) => _JobPostingCard(job: job)).toList()
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No job postings yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
            
        ),);
      
  
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int? trend;

  const _DashboardSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    bool? trendDirection;
    if (trend != null) {
      trendDirection = trend! > 0 ? true : (trend! < 0 ? false : null);
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: trendDirection == true
                          ? Colors.green.withAlpha(26)
                          : trendDirection == false
                              ? Colors.red.withAlpha(26)
                              : Colors.grey.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendDirection == true
                              ? Icons.arrow_upward
                              : trendDirection == false
                                  ? Icons.arrow_downward
                                  : Icons.remove,
                          color: trendDirection == true
                              ? Colors.green
                              : trendDirection == false
                                  ? Colors.red
                                  : Colors.grey,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend!.abs().toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trendDirection == true
                                ? Colors.green
                                : trendDirection == false
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 1),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobPostingCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const _JobPostingCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final bool isActive = job['status'] == 'Active';
    final Color statusColor = isActive ? Colors.green : Colors.grey;
    final Color cardColor = isActive ? Colors.white : Colors.grey[50]!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isActive ? 2 : 1,
      shadowColor: isActive ? job['color'].withAlpha(51) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: job['color'].withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.work_outline, color: job['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posted on ${job['date']}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(26)),
                  ),
                  child: Text(
                    job['status'],
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      '${job['applicants']} applicants',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: job['color'],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployerProfileTab extends StatelessWidget {
  const _EmployerProfileTab();

  @override
  Widget build(BuildContext context) {
    return const EmployerProfileScreen();
  }
}

class _EmployerPostJobTab extends StatelessWidget {
  const _EmployerPostJobTab();

  @override
  Widget build(BuildContext context) {
    return const PostJobScreen();
  }
}

class _EmployerJobPostingsTab extends StatelessWidget {
  const _EmployerJobPostingsTab();

  @override
  Widget build(BuildContext context) {
    return JobPostingsScreen();
  }
}

