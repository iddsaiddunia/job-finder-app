import 'package:flutter/material.dart';
import '../../services/fake_auth_service.dart';

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
    _ApplicationStatusView(),
    _ProfileView(),
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
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _NotificationsView()),
              );
            },
          ),
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
        return 'Job Finder';
    }
  }
}

// Dashboard View
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final String userName = 'Jane'; // Placeholder, replace with real user data
    final List<Map<String, String>> recommendedJobs = [
      {
        'title': 'Flutter Developer',
        'company': 'TechCorp',
        'location': 'Remote',
        'skills': 'Flutter, Dart',
        'salary': '2,000/mo',
      },
      {
        'title': 'Backend Engineer',
        'company': 'DataSoft',
        'location': 'Nairobi',
        'skills': 'Django, PostgreSQL',
        'salary': '3,000/mo',
      },
    ];

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        // Greeting
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.deepPurple[100],
              child: Icon(Icons.person, color: Colors.deepPurple, size: 32),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        SizedBox(height: 24),
        // Quick Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCard(icon: Icons.work_outline, label: 'Applied', value: '5'),
            _StatCard(icon: Icons.star_outline, label: 'Matches', value: '2'),
            _StatCard(icon: Icons.check_circle_outline, label: 'Interviews', value: '1'),
          ],
        ),
        SizedBox(height: 28),
        // Recommended Jobs Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recommended Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {},
              child: Text('See all'),
            ),
          ],
        ),
        ...recommendedJobs.map((job) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.work), backgroundColor: Colors.deepPurple[50]),
                title: Text(job['title']!, style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${job['company']} • ${job['location']}\n${job['skills']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(job['salary']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
                onTap: () => Navigator.pushNamed(context, '/job_finder/job_details'),
              ),
            )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 90,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 28),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// Job Listings View
class _JobListingsView extends StatefulWidget {
  const _JobListingsView();

  @override
  State<_JobListingsView> createState() => _JobListingsViewState();
}

class _JobListingsViewState extends State<_JobListingsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  String _selectedDuration = 'Any';

  final List<Map<String, String>> jobs = [
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
  Widget build(BuildContext context) {
    // Filtering logic in build
    List<Map<String, String>> filteredJobs = jobs.where((job) {
      final matchesSearch = _searchController.text.isEmpty ||
          job['title']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          job['company']!.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesType = _selectedType == 'All' || job['type'] == _selectedType;
      final matchesDuration = _selectedDuration == 'Any' || job['duration'] == _selectedDuration;
      return matchesSearch && matchesType && matchesDuration;
    }).toList();

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
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];
              final screenWidth = MediaQuery.of(context).size.width;
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
                                        job['title']!,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: job['type'] == 'Contract'
                                            ? Color(0xFFEDE7F6) // light purple
                                            : Color(0xFFFFF3E0), // light orange
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      child: Text(
                                        job['type']!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: job['type'] == 'Contract'
                                              ? Colors.deepPurple
                                              : Colors.deepOrange,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                                Text(job['duration']!, style: TextStyle(fontSize: 11.5, color: Colors.blueGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 2),
                                Text(job['company']!, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 1),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 13, color: Colors.deepPurple[200]),
                                    SizedBox(width: 2),
                                    Flexible(
                                      child: Text(job['location']!, style: TextStyle(fontSize: 11.5, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              job['salary']!,
                              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 28,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.deepPurple),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/job_finder/job_details'),
                              child: Text('View', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
                    children: [
                      ...skillList.map((skill) => Chip(
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
                      )),
                      ActionChip(
                        label: const Text('Add Skill', style: TextStyle(color: Colors.deepPurple)),
                        avatar: const Icon(Icons.add, color: Colors.deepPurple, size: 18),
                        backgroundColor: Colors.deepPurple[50],
                        onPressed: () => _showAddSkillDialog(context),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
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
            children: [
              ...expList.asMap().entries.map((entry) {
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
            ],
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
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}


// Notifications View
class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue[50],
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.blue),
              title: Text('You have 2 new job matches!'),
              subtitle: Text('Check out the latest recommended jobs.'),
            ),
          ),
          // Add more notifications here
        ],
      ),
    );
  }
}
