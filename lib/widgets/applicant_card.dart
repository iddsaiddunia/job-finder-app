import 'package:flutter/material.dart';
import 'dart:convert';

class ApplicantCard extends StatelessWidget {
  final String name;
  final String skills;
  final dynamic education;
  final double rating;
  final VoidCallback? onTap;
  final String? status;
  final bool? isSelected;
  final bool? applicantApproved;

  const ApplicantCard({
    super.key,
    required this.name,
    required this.skills,
    required this.education,
    required this.rating,
    this.onTap,
    this.status,
    this.isSelected,
    this.applicantApproved,
  });
  
  /// Formats education data into a readable string
  /// Handles different formats: string, list, or JSON string
  /// Prioritizes showing education level and field for the card view
  // Get status color based on application status and selection state
  Color _getStatusColor() {
    if (status == 'rejected') {
      return Colors.red;
    } else if (status == 'selected' || isSelected == true) {
      return applicantApproved == true ? Colors.green : Colors.orange;
    } else if (status == 'pending') {
      return Colors.blue;
    } else if (status == 'approved') {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }
  
  // Get status icon based on application status and selection state
  IconData _getStatusIcon() {
    if (status == 'rejected') {
      return Icons.cancel_outlined;
    } else if (status == 'selected' || isSelected == true) {
      return applicantApproved == true ? Icons.check_circle_outline : Icons.star_outline;
    } else if (status == 'pending') {
      return Icons.hourglass_empty;
    } else if (status == 'approved') {
      return Icons.check_circle_outline;
    } else {
      return Icons.info_outline;
    }
  }
  
  // Get status text based on application status and selection state
  String _getStatusText() {
    if (status == 'rejected') {
      return 'Rejected';
    } else if (status == 'selected' || isSelected == true) {
      return applicantApproved == true ? 'Approved' : 'Selected';
    } else if (status == 'pending') {
      return 'Pending';
    } else if (status == 'approved') {
      return 'Approved';
    } else {
      return status ?? 'Applied';
    }
  }
  
  String _formatEducation() {
    if (education == null) return 'No education data';
    
    // Debug print to see what we're working with
    print('DEBUG: Education data type: ${education.runtimeType}');
    print('DEBUG: Raw education data: $education');
    
    try {
      // Handle different education data formats
      
      // Case 1: Direct Map with level and field
      if (education is Map) {
        print('DEBUG: Education is a Map');
        if (education.containsKey('level')) {
          final level = education['level'] ?? '';
          final field = education['field'] ?? '';
          print('DEBUG: Direct Map - Level: $level, Field: $field');
          return '$level${field.isNotEmpty ? ' in $field' : ''}';
        }
      }
      
      // Case 2: String that's not JSON
      if (education is String && !education.toString().trim().startsWith('[') && 
          !education.toString().trim().startsWith('{')) {
        print('DEBUG: Education is a simple string');
        return education.toString();
      }
      
      // Case 3: List of education entries
      List<dynamic> educationList;
      
      if (education is String) {
        // Try to parse as JSON
        try {
          final parsed = jsonDecode(education);
          if (parsed is List) {
            educationList = parsed;
          } else if (parsed is Map) {
            // Handle single education entry as JSON object
            if (parsed.containsKey('level')) {
              final level = parsed['level'] ?? '';
              final field = parsed['field'] ?? '';
              print('DEBUG: Single JSON object - Level: $level, Field: $field');
              return '$level${field.isNotEmpty ? ' in $field' : ''}';
            }
            // If it's a map but doesn't have level, treat as a list with one item
            educationList = [parsed];
          } else {
            return education.toString();
          }
          print('DEBUG: Parsed education from JSON: $educationList');
        } catch (e) {
          print('DEBUG: Failed to parse education JSON: $e');
          return education.toString();
        }
      } else if (education is List) {
        educationList = education;
        print('DEBUG: Education is already a List: $educationList');
      } else {
        print('DEBUG: Education is an unsupported type: ${education.runtimeType}');
        return education.toString();
      }
      
      if (educationList.isEmpty) {
        print('DEBUG: Education list is empty');
        return 'No education data';
      }
      
      // Find the most relevant education entry (most recent or highest level)
      // Try each entry until we find one with level and field
      for (var eduEntry in educationList) {
        if (eduEntry is Map) {
          print('DEBUG: Examining education entry: $eduEntry');
          
          // New structured format with level and field
          if (eduEntry.containsKey('level')) {
            final level = eduEntry['level'] ?? '';
            final field = eduEntry['field'] ?? '';
            
            print('DEBUG: Found structured format - Level: $level, Field: $field');
            return '$level${field.isNotEmpty ? ' in $field' : ''}';
          }
          
          // Old format with degree and institution
          if (eduEntry.containsKey('degree')) {
            final degree = eduEntry['degree'] ?? '';
            final institution = eduEntry['institution'] ?? '';
            
            print('DEBUG: Using old format - Degree: $degree, Institution: $institution');
            return degree.isNotEmpty ? degree : institution;
          }
        }
      }
      
      // If we got here, we couldn't find a properly formatted education entry
      print('DEBUG: No properly formatted education entry found');
      return educationList.first.toString();
      
    } catch (e) {
      // Fallback for any parsing errors
      print('DEBUG: Error formatting education: $e');
      return 'Education data error';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate a color based on rating
    final ratingColor = rating >= 4.5 ? Colors.green.shade700 :
                       rating >= 4.0 ? Colors.green.shade600 :
                       rating >= 3.5 ? Colors.amber.shade700 :
                       rating >= 3.0 ? Colors.amber.shade600 :
                       rating >= 2.0 ? Colors.orange.shade700 : Colors.red.shade700;
                       
    // Format skills for display
    final List<String> skillsList = skills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with gradient background
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and education
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ratingColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          (rating >= 0) ? rating.toStringAsFixed(1) : '0.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),
              // Education section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Education',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      _formatEducation(),
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Skills section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  skillsList.isEmpty
                      ? Text(
                          'No skills listed',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: skillsList.take(5).map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.deepPurple.shade100),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700),
                            ),
                          )).toList()
                          + (skillsList.length > 5 
                              ? [Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${skillsList.length - 5} more',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                )]
                              : []),
                        ),
                ],
              ),
              const SizedBox(height: 8),
              // Status indicator if available
              if (status != null || isSelected == true) ...[  
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status badge
                    if (status != null || isSelected == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStatusColor().withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(), size: 14, color: _getStatusColor()),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(),
                              style: TextStyle(fontSize: 12, color: _getStatusColor()),
                            ),
                          ],
                        ),
                      ),
                    // View profile button
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.person_outline, size: 16),
                      label: const Text('View Profile'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ] else ...[  // Fixed: Changed [] to ...[] for proper spread operator syntax
                // View profile button only if no status
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('View Profile'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
