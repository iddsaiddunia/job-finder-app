import 'package:flutter/material.dart';

class JobFinderRegisterScreen extends StatefulWidget {
  const JobFinderRegisterScreen({super.key});

  @override
  State<JobFinderRegisterScreen> createState() => _JobFinderRegisterScreenState();
}

class _JobFinderRegisterScreenState extends State<JobFinderRegisterScreen> {
  int _step = 0;
  final _basicFormKey = GlobalKey<FormState>();
  final _proFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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

  void _nextStep() {
    if (_step == 0 && _basicFormKey.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  void _register() {
    if (_proFormKey.currentState!.validate()) {
      // Simulate registration success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Complete!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C3AED), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1, size: 64, color: Color(0xFF7C3AED)),
                    const SizedBox(height: 16),
                    Text(
                      'Job RS Registration',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4B006E)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepIndicator(0, 'Basic'),
                        Container(width: 32, height: 2, color: Colors.grey[300]),
                        _stepIndicator(1, 'Professional'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: _step == 0 ? _buildBasicForm() : _buildProfessionalForm(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(int step, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: _step == step ? Color(0xFF7C3AED) : Colors.grey[300],
          child: Text('${step + 1}', style: TextStyle(color: _step == step ? Colors.white : Colors.black)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: _step == step ? FontWeight.bold : FontWeight.normal, color: _step == step ? Color(0xFF7C3AED) : Colors.black54)),
      ],
    );
  }

  Widget _buildBasicForm() {
    return Form(
      key: _basicFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              elevation: 3,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalForm() {
    return Form(
      key: _proFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              elevation: 3,
            ),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
