import 'package:flutter/material.dart';

class JobPostingsScreen extends StatefulWidget {
  const JobPostingsScreen({super.key});

  @override
  State<JobPostingsScreen> createState() => _JobPostingsScreenState();
}

class _JobPostingsScreenState extends State<JobPostingsScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> jobPostings = [
    {
      'title': 'Flutter Developer',
      'company': 'TechCorp',
      'location': 'Remote',
      'skills': 'Flutter, Dart',
      'salary': '₵2,000/mo',
      'status': 'Active',
      'applicants': 12,
    },
    {
      'title': 'Backend Engineer',
      'company': 'DataSoft',
      'location': 'Nairobi',
      'skills': 'Django, PostgreSQL',
      'salary': '₵3,000/mo',
      'status': 'Closed',
      'applicants': 7,
    },
    {
      'title': 'Product Manager',
      'company': 'BizPro',
      'location': 'Accra',
      'skills': 'Agile, Leadership',
      'salary': '₵4,500/mo',
      'status': 'Active',
      'applicants': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredJobs = selectedFilter == 'All'
        ? jobPostings
        : jobPostings.where((job) => job['status'] == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Job Postings')),
      body: ListView(
        padding: EdgeInsets.zero,
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
          if (filteredJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Center(
                child: Text(
                  'No job postings found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            )
          else ...filteredJobs.map((job) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/employer/applicant_list'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: Icon(Icons.work, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 12),
                        // Main info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${job['company']} • ${job['location']}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Skills: ${job['skills']}', style: TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Salary: ${job['salary']}', style: TextStyle(color: Colors.green[700], fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tags
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(minWidth: 54, maxWidth: 70),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people, color: Colors.blue, size: 15),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${job['applicants']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              constraints: const BoxConstraints(minWidth: 54, maxWidth: 70),
                              child: Chip(
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    job['status'],
                                    style: TextStyle(
                                      color: job['status'] == 'Active' ? Colors.green : Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                backgroundColor: job['status'] == 'Active' ? Colors.green[50] : Colors.red[50],
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
