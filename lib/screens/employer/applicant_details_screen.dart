import 'package:flutter/material.dart';
import '../../widgets/applicant_profile_card.dart';
import '../../widgets/rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicantDetailsScreen extends StatefulWidget {
  final String applicantName;
  final String skills;
  final String education;
  final double rating;

  const ApplicantDetailsScreen({
    super.key,
    this.applicantName = 'Jane Doe',
    this.skills = 'Flutter, Django, PostgreSQL',
    this.education = 'BSc Computer Science',
    this.rating = 4.2,
  });

  @override
  State<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends State<ApplicantDetailsScreen> {

  double? _currentRating;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get arguments from Navigator if available
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final name = args != null && args['name'] != null ? args['name'] : widget.applicantName;
    final skills = args != null && args['skills'] != null ? args['skills'] : widget.skills;
    final education = args != null && args['education'] != null ? args['education'] : widget.education;
    final rating = args != null && args['rating'] != null ? (args['rating'] as num).toDouble() : widget.rating;
    final experience = args != null && args['experience'] != null ? (args['experience'] as List<dynamic>) : [];
    final email = args != null && args['email'] != null ? args['email'] : null;
    final phone = args != null && args['phone'] != null ? args['phone'] : null;
    final status = args != null && args['status'] != null ? args['status'] : 'Available';

    Color statusColor;
    switch (status) {
      case 'Busy':
        statusColor = Colors.orange;
        break;
      case 'Interviewing':
        statusColor = Colors.blue;
        break;
      case 'Available':
      default:
        statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ApplicantProfileCard(
              name: name,
              skills: skills,
              education: education,
              rating: rating,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                const SizedBox(width: 16),
                if (email != null) ...[
                  IconButton(
                    icon: Icon(Icons.email, color: Colors.blue),
                    tooltip: 'Send Email',
                    onPressed: () async {
                      final uri = Uri(scheme: 'mailto', path: email);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Could not open email client.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                ],
                if (phone != null) ...[
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    tooltip: 'Call',
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Could not start call.')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            if (experience.isNotEmpty) ...[
              const Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 8),
              ...experience.map((exp) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.work_outline, color: Colors.deepPurple),
                      title: Text(exp['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${exp['company'] ?? ''} • ${exp['years'] ?? ''} years'),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            Text('Education: $education', style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 10),
            const Text('Rate Applicant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            RatingBar(
              rating: _currentRating ?? widget.rating,
              readOnly: false,
              onRatingUpdate: (newRating) {
                setState(() {
                  _currentRating = newRating;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rated: $newRating')),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text('Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write feedback for the applicant...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Implement feedback submission logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted!')),
                );
                _feedbackController.clear();
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 28),
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Demo: mark as selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Applicant selected!')),
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Select Applicant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
