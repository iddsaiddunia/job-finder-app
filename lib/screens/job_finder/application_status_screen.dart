import 'package:flutter/material.dart';

class ApplicationStatusScreen extends StatelessWidget {
  ApplicationStatusScreen({super.key});
  final List<Map<String, dynamic>> applications = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Application Status')),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        children: [
          ...applications.map((app) => Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  leading: Icon(Icons.work, color: Colors.deepPurple),
                  title: Text('${app['jobTitle']} @ ${app['company']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('Status: ${app['status']}', style: TextStyle(fontSize: 15)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text('Rating: ${app['rating']}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {},
                ),
              )),
        ],
      ),
    );
  }
}
