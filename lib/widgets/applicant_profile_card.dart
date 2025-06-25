import 'package:flutter/material.dart';
import 'dart:convert';

class ApplicantProfileCard extends StatelessWidget {
  final String name;
  final String skills;
  final dynamic education;
  final double rating;

  const ApplicantProfileCard({
    super.key,
    required this.name,
    required this.skills,
    required this.education,
    required this.rating,
  });
  
  /// Formats education data into a readable string
  /// Handles different formats: string, list, or JSON string
  String _formatEducation() {
    if (education == null) return '';
    
    try {
      // If it's already a string and not JSON, return as is
      if (education is String && !education.toString().trim().startsWith('[')) {
        return education.toString();
      }
      
      // Parse education data
      List<dynamic> educationList;
      if (education is String) {
        // Try to parse as JSON
        try {
          educationList = jsonDecode(education);
        } catch (e) {
          return education;
        }
      } else if (education is List) {
        educationList = education;
      } else {
        return education.toString();
      }
      
      if (educationList.isEmpty) return '';
      
      // Format the most recent education entry (assuming the list is ordered with most recent first)
      var recentEducation = educationList.first;
      if (recentEducation is Map) {
        final degree = recentEducation['degree'] ?? '';
        final institution = recentEducation['institution'] ?? '';
        final year = recentEducation['year'] ?? '';
        
        return '$degree${degree.isNotEmpty && institution.isNotEmpty ? ' at ' : ''}$institution${year.isNotEmpty ? ' ($year)' : ''}';
      } else {
        return recentEducation.toString();
      }
    } catch (e) {
      // Fallback for any parsing errors
      return education.toString();
    }
  }

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
                      Text('Education: ${_formatEducation()}', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
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
