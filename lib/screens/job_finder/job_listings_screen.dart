import 'package:flutter/material.dart';
import '../../widgets/job_card.dart';

class JobListingsScreen extends StatelessWidget {
  JobListingsScreen({super.key});
  final List<Map<String, String>> jobs = [
    {
      'title': 'Mobile App Developer',
      'company': 'Appify',
      'location': 'Remote',
      'skills': 'Flutter, Firebase',
      'salary': ' 2,500/mo',
    },
    {
      'title': 'Full Stack Engineer',
      'company': 'WebGen',
      'location': 'Nairobi',
      'skills': 'Django, React',
      'salary': ' 3,200/mo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Listings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search jobs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list),
                  label: Text('Filter'),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: jobs.map((job) => JobCard(
                title: job['title']!,
                company: job['company']!,
                location: job['location']!,
                skills: job['skills']!,
                salary: job['salary']!,
                onTap: () => Navigator.pushNamed(context, '/job_finder/job_details'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
