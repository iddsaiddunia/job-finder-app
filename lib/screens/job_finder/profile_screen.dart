import 'package:flutter/material.dart';
import '../../services/fake_auth_service.dart';

class JobFinderProfileScreen extends StatefulWidget {
  const JobFinderProfileScreen({super.key});
  @override
  State<JobFinderProfileScreen> createState() => _JobFinderProfileScreenState();
}

class _JobFinderProfileScreenState extends State<JobFinderProfileScreen> {
  bool _isAvailable = true; // User availability toggle

  final _nameController = TextEditingController();
  String? _selectedEducationLevel;
  String? _selectedEducationType;
  final List<String> _educationLevels = [
    'Diploma', 'BSc', 'MSc', 'PhD', 'Other'
  ];
  final Map<String, List<String>> _educationTypes = {
    'Diploma': ['Diploma in IT', 'Diploma in Business', 'Other'],
    'BSc': ['Software Engineering', 'Computer Science', 'Information Systems', 'Other'],
    'MSc': ['Software Engineering', 'AI', 'Cybersecurity', 'Other'],
    'PhD': ['Computer Science', 'AI', 'Other'],
    'Other': ['Other']
  };
  List<String> _suggestedSkills = [];
  final List<String> _selectedSkills = [];
  final _manualSkillController = TextEditingController();
  final List<Map<String, String>> _experiences = [];

  // Experience controllers for adding new experience
  final _expTitleController = TextEditingController();
  final _expCompanyController = TextEditingController();
  final _expDurationController = TextEditingController();
  final _expDescController = TextEditingController();

  void _updateSuggestedSkills() {
    String? type = _selectedEducationType;
    if (type == 'Software Engineering' || type == 'Computer Science') {
      _suggestedSkills = ['Flutter', 'Dart', 'OOP', 'Git', 'Java', 'SQL'];
    } else if (type == 'AI') {
      _suggestedSkills = ['Python', 'Machine Learning', 'TensorFlow', 'Data Analysis'];
    } else if (type == 'Cybersecurity') {
      _suggestedSkills = ['Network Security', 'Penetration Testing', 'Linux', 'Python'];
    } else {
      _suggestedSkills = [];
    }
    setState(() {});
  }

  void _addManualSkill() {
    final skill = _manualSkillController.text.trim();
    if (skill.isNotEmpty && !_selectedSkills.contains(skill)) {
      setState(() {
        _selectedSkills.add(skill);
        _manualSkillController.clear();
      });
    }
  }

  void _addExperience() {
    if (_expTitleController.text.isNotEmpty && _expCompanyController.text.isNotEmpty) {
      setState(() {
        _experiences.add({
          'title': _expTitleController.text,
          'company': _expCompanyController.text,
          'duration': _expDurationController.text,
          'desc': _expDescController.text,
        });
        _expTitleController.clear();
        _expCompanyController.clear();
        _expDurationController.clear();
        _expDescController.clear();
      });
    }
  }

  void _removeExperience(int idx) {
    setState(() {
      _experiences.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isAvailable ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isAvailable ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  onChanged: (val) {
                    setState(() {
                      _isAvailable = val;
                    });
                  },
                ),
              ],
            ),
            Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 24),
            Text('Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedEducationLevel,
              items: _educationLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedEducationLevel = val;
                  _selectedEducationType = null;
                });
              },
              decoration: InputDecoration(labelText: 'Education Level', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEducationType,
              items: (_selectedEducationLevel != null ? (_educationTypes[_selectedEducationLevel] ?? []) : <String>[]).map<DropdownMenuItem<String>>((type) => DropdownMenuItem<String>(value: type, child: Text(type))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedEducationType = val;
                  _updateSuggestedSkills();
                });
              },
              decoration: InputDecoration(labelText: 'Education Type', border: OutlineInputBorder()),
            ),
            SizedBox(height: 24),
            Text('Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _suggestedSkills.map((skill) => FilterChip(
                label: Text(skill),
                selected: _selectedSkills.contains(skill),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _selectedSkills.map((skill) => Chip(
                label: Text(skill),
                onDeleted: () {
                  setState(() {
                    _selectedSkills.remove(skill);
                  });
                },
              )).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualSkillController,
                    decoration: InputDecoration(labelText: 'Add Skill', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addManualSkill,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            ..._experiences.asMap().entries.map((entry) => Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(entry.value['title'] ?? ''),
                subtitle: Text('${entry.value['company'] ?? ''} (${entry.value['duration'] ?? ''})\n${entry.value['desc'] ?? ''}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExperience(entry.key),
                ),
              ),
            )),
            SizedBox(height: 12),
            Text('Add Experience', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _expTitleController,
              decoration: InputDecoration(labelText: 'Job Title', border: OutlineInputBorder()),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _expCompanyController,
              decoration: InputDecoration(labelText: 'Company', border: OutlineInputBorder()),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _expDurationController,
              decoration: InputDecoration(labelText: 'Duration (e.g. 2021-2023)', border: OutlineInputBorder()),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _expDescController,
              decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: _addExperience,
              icon: Icon(Icons.add),
              label: Text('Add Experience'),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final email = ModalRoute.of(context)?.settings.arguments as String?;
                if (email != null) {
                  FakeAuthService().markProfileComplete(email);
                  Navigator.pushReplacementNamed(context, '/job_finder/home');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated!')),
                );
              },
              icon: Icon(Icons.save),
              label: Text('Save Profile'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ElevatedButton.icon(
          icon: Icon(Icons.logout),
          label: Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _logout(context),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FakeAuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/job_finder/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully!')),
      );
    }
  }
}
