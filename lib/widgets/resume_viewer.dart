import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_constants.dart';

class ResumeViewer extends StatelessWidget {
  final String? resumeUrl;
  final String? linkedinUrl;
  final String? location;
  final bool? willingToRelocate;
  final int? salaryExpectation;

  const ResumeViewer({
    super.key,
    this.resumeUrl,
    this.linkedinUrl,
    this.location,
    this.willingToRelocate,
    this.salaryExpectation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Resume & Additional Info',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Resume download button
            if (resumeUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Construct the full URL to the resume
                    final fullUrl = '${ApiConstants.baseUrl}$resumeUrl';
                    final uri = Uri.parse(fullUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open resume. Please check the URL.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  label: const Text('View Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              
            // LinkedIn profile
            if (linkedinUrl != null && linkedinUrl!.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text('LinkedIn Profile'),
                subtitle: Text(
                  linkedinUrl!,
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onTap: () async {
                  final uri = Uri.parse(linkedinUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open LinkedIn profile.')),
                      );
                    }
                  }
                },
              ),
              
            // Location information
            if (location != null && location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text('Location: $location'),
                    if (willingToRelocate == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Chip(
                          label: Text('Willing to relocate'),
                          backgroundColor: Color(0xFFE3F2FD),
                          labelStyle: TextStyle(fontSize: 12),
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                  ],
                ),
              ),
              
            // Salary expectation
            if (salaryExpectation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Salary Expectation: \$${salaryExpectation.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
