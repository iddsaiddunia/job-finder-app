import 'package:flutter/material.dart';
import '../../widgets/applicant_card.dart';

class ApplicantListScreen extends StatelessWidget {
  final String jobTitle;
  final List<Map<String, dynamic>> applicants;
  final List<Map<String, dynamic>> recommendedApplicants;

  const ApplicantListScreen({
    super.key,
    this.jobTitle = 'Software Engineer',
    this.applicants = const [
      {
        'name': 'Jane Doe',
        'skills': 'Flutter, Django',
        'education': 'BSc Computer Science',
        'rating': 4.2,
      },
      {
        'name': 'John Smith',
        'skills': 'React, Node.js',
        'education': 'BSc IT',
        'rating': 3.9,
      },
      {
        'name': 'Alice Brown',
        'skills': 'PostgreSQL, Django',
        'education': 'MSc Data Science',
        'rating': 4.5,
      },
    ],
    this.recommendedApplicants = const [
      {
        'name': 'Emily Clark',
        'skills': 'Flutter, Firebase',
        'education': 'BSc Software Engineering',
        'rating': 4.8,
      },
      {
        'name': 'Michael Lee',
        'skills': 'Dart, Node.js',
        'education': 'MSc Computer Engineering',
        'rating': 4.6,
      },
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applicants')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        children: [
          Text('Job: $jobTitle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          if (recommendedApplicants.isNotEmpty) ...[
            const Text('Recommended Applicants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green)),
            const SizedBox(height: 8),
            ...recommendedApplicants.map((app) => ApplicantCard(
                  name: app['name'],
                  skills: app['skills'],
                  education: app['education'],
                  rating: app['rating'],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/employer/applicant_details',
                    arguments: {
                      'name': app['name'],
                      'skills': app['skills'],
                      'education': app['education'],
                      'rating': app['rating'],
                      'experience': [
                        {
                          'title': 'Mobile Developer',
                          'company': 'TechCorp',
                          'years': 2,
                        },
                        {
                          'title': 'Intern',
                          'company': 'StartupX',
                          'years': 1,
                        },
                      ],
                      'email': app['email'] ?? 'applicant@email.com',
                      'phone': app['phone'] ?? '+1234567890',
                      'status': app['status'] ?? 'Available',
                    },
                  ),
                )),
            const SizedBox(height: 18),
          ],
          const Text('All Applicants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...applicants.map((app) => ApplicantCard(
                name: app['name'],
                skills: app['skills'],
                education: app['education'],
                rating: app['rating'],
                onTap: () => Navigator.pushNamed(
                  context,
                  '/employer/applicant_details',
                  arguments: {
                    'name': app['name'],
                    'skills': app['skills'],
                    'education': app['education'],
                    'rating': app['rating'],
                    'experience': [
                      {
                        'title': 'Mobile Developer',
                        'company': 'TechCorp',
                        'years': 2,
                      },
                      {
                        'title': 'Intern',
                        'company': 'StartupX',
                        'years': 1,
                      },
                    ],
                    'email': app['email'] ?? 'applicant@email.com',
                    'phone': app['phone'] ?? '+1234567890',
                    'status': app['status'] ?? 'Available',
                  },
                ),
              )),
        ],
      ),
    );
  }
}

