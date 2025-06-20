import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'post_job_screen.dart';
import 'job_postings_screen.dart';
import 'notifications_tab.dart';

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
    const EmployerNotificationsTab(),
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
            NavigationDestination(
              icon: const Icon(Icons.notifications_none_outlined, size: 22),
              selectedIcon: const Icon(Icons.notifications, size: 22),
              label: 'Notifications',
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

class _EmployerDashboardTab extends StatelessWidget {
  final VoidCallback? onPostJob;
  final VoidCallback? onNotifications;
  const _EmployerDashboardTab({this.onPostJob, this.onNotifications});

  @override
  Widget build(BuildContext context) {
    // Demo summary data
    final int totalJobs = 8;
    final int totalApplicants = 42;
    final int activeJobs = 3;
    final int newApplications = 5;
    final List<Map<String, String>> recentJobs = [
      {
        'title': 'Flutter Developer',
        'date': '2025-06-10',
        'status': 'Active',
      },
      {
        'title': 'Backend Engineer',
        'date': '2025-06-08',
        'status': 'Closed',
      },
      {
        'title': 'Product Manager',
        'date': '2025-06-05',
        'status': 'Active',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28),
                  onPressed: onNotifications,
                ),
                Positioned(
                  // Position the badge at the top right of the bell
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '2', // Number of notifications
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _DashboardSummaryCard(
                  icon: Icons.list_alt,
                  label: 'Total Jobs',
                  value: totalJobs.toString(),
                  color: Colors.deepPurple,
                ),
                _DashboardSummaryCard(
                  icon: Icons.people,
                  label: 'Applicants',
                  value: totalApplicants.toString(),
                  color: Colors.blue,
                ),
                _DashboardSummaryCard(
                  icon: Icons.check_circle,
                  label: 'Active',
                  value: activeJobs.toString(),
                  color: Colors.green,
                ),
                _DashboardSummaryCard(
                  icon: Icons.mail,
                  label: 'New Apps',
                  value: newApplications.toString(),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                icon: const Icon(Icons.add_box, size: 26, color: Colors.white),
                label: const Text('Post a New Job'),
                onPressed: onPostJob,
              ),
            ),
            const SizedBox(height: 32),
            Text('Recent Job Postings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...recentJobs.map((job) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.work_outline, color: Colors.deepPurple),
                    title: Text(job['title']!),
                    subtitle: Text('Posted on ${job['date']}'),
                    trailing: Chip(
                      label: Text(job['status']!, style: TextStyle(color: job['status'] == 'Active' ? Colors.green : Colors.grey)),
                      backgroundColor: job['status'] == 'Active' ? Colors.green[50] : Colors.grey[100],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DashboardSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
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

