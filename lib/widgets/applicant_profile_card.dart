import 'package:flutter/material.dart';

class ApplicantProfileCard extends StatelessWidget {
  final String name;
  final String skills;
  final String education;
  final double rating;

  const ApplicantProfileCard({
    super.key,
    required this.name,
    required this.skills,
    required this.education,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blueGrey.shade100,
                  child: Icon(Icons.person, size: 40, color: Colors.blueGrey),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Education: $education', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Text('Skills: $skills', style: TextStyle(fontSize: 16)),
            SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 22),
                SizedBox(width: 6),
                Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Text('Rating', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
