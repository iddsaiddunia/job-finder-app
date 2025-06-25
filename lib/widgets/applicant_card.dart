import 'package:flutter/material.dart';
import 'dart:convert';

class ApplicantCard extends StatelessWidget {
  final String name;
  final String skills;
  final dynamic education;
  final double rating;
  final VoidCallback? onTap;

  const ApplicantCard({
    super.key,
    required this.name,
    required this.skills,
    required this.education,
    required this.rating,
    this.onTap,
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
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(child: Icon(Icons.person)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Skills: $skills', style: TextStyle(fontSize: 13)),
                        Text('Education: ${_formatEducation()}', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),

                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 15),
                      SizedBox(width: 3),
                      Text(rating.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
