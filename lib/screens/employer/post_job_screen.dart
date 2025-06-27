import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/token_storage.dart';
import '../../services/job_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _locationController = TextEditingController();
  final _benefitController = TextEditingController();
  final _recruitingSizeController = TextEditingController(text: '1');
  final _customSkillController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _educationRequirements = [];
  List<String> _benefits = [];
  String _jobType = 'FULL_TIME';
  String _experienceLevel = 'ENTRY';
  bool _isRemote = false;
  DateTime? _applicationDeadline;
  String _nextStep = 'INTERVIEW';
  List<String> _selectedSkills = [];
  
  // Education level and field variables
  String _selectedEducationLevel = 'BACHELOR';
  String? _selectedField;
  
  // Education levels
  final List<Map<String, String>> educationLevels = [
    {'value': 'NONE', 'label': 'No Education Required'},
    {'value': 'PRIMARY', 'label': 'Primary School'},
    {'value': 'SECONDARY', 'label': 'Secondary School'},
    {'value': 'CERTIFICATE', 'label': 'Certificate'},
    {'value': 'DIPLOMA', 'label': 'Diploma'},
    {'value': 'BACHELOR', 'label': 'Bachelor\'s Degree'},
    {'value': 'MASTER', 'label': 'Master\'s Degree'},
    {'value': 'PHD', 'label': 'PhD/Doctorate'},
  ];
  
  // Fields by education level
  final Map<String, List<String>> fieldsByLevel = {
    'NONE': ['Not Applicable'],
    'PRIMARY': ['General Education'],
    'SECONDARY': ['General Education', 'Science', 'Arts', 'Commerce'],
    'CERTIFICATE': [
      'Information Technology', 'Business', 'Healthcare', 'Education',
      'Engineering', 'Hospitality', 'Agriculture', 'Other'
    ],
    'DIPLOMA': [
      'Information Technology', 'Business Administration', 'Accounting',
      'Healthcare', 'Education', 'Engineering', 'Hospitality Management',
      'Agriculture', 'Media Studies', 'Other'
    ],
    'BACHELOR': [
      'Computer Science', 'Information Technology', 'Business Administration',
      'Accounting', 'Finance', 'Marketing', 'Human Resources', 'Engineering',
      'Medicine', 'Nursing', 'Education', 'Law', 'Agriculture',
      'Environmental Science', 'Social Sciences', 'Arts', 'Other'
    ],
    'MASTER': [
      'Computer Science', 'Information Technology', 'Business Administration (MBA)',
      'Finance', 'Marketing', 'Human Resources', 'Engineering', 'Medicine',
      'Public Health', 'Education', 'Law', 'Environmental Science',
      'International Relations', 'Other'
    ],
    'PHD': [
      'Computer Science', 'Information Technology', 'Business', 'Engineering',
      'Medicine', 'Education', 'Law', 'Sciences', 'Humanities', 'Other'
    ],
  };
  
  // Methods for handling education requirements
  void _addEducationRequirement() {
    if (_selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a field of study')),
      );
      return;
    }
    
    final educationRequirement = {
      'level': _selectedEducationLevel,
      'field': _selectedField,
    };
    
    setState(() {
      _educationRequirements.add(educationRequirement);
      // Reset field selection but keep the level
      _selectedField = null;
    });
  }
  
  void _removeEducationRequirement(int index) {
    setState(() {
      _educationRequirements.removeAt(index);
    });
  }
  
  // Get available fields based on selected education level
  List<String> get _availableFields {
    return fieldsByLevel[_selectedEducationLevel] ?? [];
  }
  
  // Constants from backend model
  final List<Map<String, String>> jobTypes = [
    {'value': 'FULL_TIME', 'label': 'Full-time'},
    {'value': 'PART_TIME', 'label': 'Part-time'},
    {'value': 'CONTRACT', 'label': 'Contract'},
    {'value': 'INTERNSHIP', 'label': 'Internship'},
    {'value': 'TEMPORARY', 'label': 'Temporary'},
  ];
  
  final List<Map<String, String>> experienceLevels = [
    {'value': 'ENTRY', 'label': 'Entry Level'},
    {'value': 'MID', 'label': 'Mid Level'},
    {'value': 'SENIOR', 'label': 'Senior'},
  ];
  
  final List<Map<String, String>> nextStepOptions = [
    {'value': 'INTERVIEW', 'label': 'Interview'},
    {'value': 'DIRECT_HIRE', 'label': 'Direct Hire'},
  ];
  
  // Job titles and skills mapping
  final Map<String, List<String>> jobTitleSkills = {
    'Software Developer': ['JavaScript', 'Python', 'Java', 'React', 'Node.js', 'SQL'],
    'Data Analyst': ['SQL', 'Excel', 'Python', 'R', 'Tableau', 'Power BI'],
    'Project Manager': ['Agile', 'Scrum', 'JIRA', 'MS Project', 'Risk Management'],
    'Marketing Specialist': ['SEO', 'Content Marketing', 'Social Media', 'Google Analytics'],
    'Customer Service': ['Communication', 'Problem Solving', 'CRM Software'],
    'Accountant': ['QuickBooks', 'Excel', 'Financial Reporting', 'Tax Preparation'],
    'Other': [],
  };
  String _selectedTitle = 'Software Developer';
  
  // Location data
  final List<String> tanzaniaRegions = [
    'Arusha', 'Dar es Salaam', 'Dodoma', 'Geita', 'Iringa', 'Kagera', 'Katavi',
    'Kigoma', 'Kilimanjaro', 'Lindi', 'Manyara', 'Mara', 'Mbeya', 'Morogoro',
    'Mtwara', 'Mwanza', 'Njombe', 'Pemba North', 'Pemba South', 'Pwani',
    'Rukwa', 'Ruvuma', 'Shinyanga', 'Simiyu', 'Singida', 'Tabora', 'Tanga',
    'Zanzibar Central/South', 'Zanzibar North', 'Zanzibar Urban/West'
  ];
  String? _selectedRegion = 'Dar es Salaam';

  @override
  void initState() {
    super.initState();
    _selectedSkills = List.from(jobTitleSkills[_selectedTitle] ?? []);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _locationController.dispose();
    _benefitController.dispose();
    _recruitingSizeController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }
  

  
  void _addBenefit() {
    final benefit = _benefitController.text.trim();
    if (benefit.isNotEmpty && !_benefits.contains(benefit)) {
      setState(() {
        _benefits.add(benefit);
        _benefitController.clear();
      });
    }
  }
  
  void _removeBenefit(String benefit) {
    setState(() {
      _benefits.remove(benefit);
    });
  }
  
  void _addSkill() {
    final skill = _customSkillController.text.trim();
    if (skill.isNotEmpty && !_selectedSkills.contains(skill)) {
      setState(() {
        _selectedSkills.add(skill);
        _customSkillController.clear();
      });
    }
  }
  
  void _removeSkill(String skill) {
    setState(() {
      _selectedSkills.remove(skill);
    });
  }
  
  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _applicationDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _applicationDeadline) {
      setState(() {
        _applicationDeadline = picked;
      });
    }
  }
  
  // Post job to backend
  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_educationRequirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one education requirement')),
      );
      return;
    }
    
    if (_applicationDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an application deadline')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get user data to retrieve company information
      final loginData = await TokenStorage.getLoginData();
      final userType = loginData['user_type'];
      
      // // Debug user type
      // print('User type from token: $userType');
      // print('All login data: $loginData');
      
      final salaryMin = int.tryParse(_salaryMinController.text.replaceAll(',', '')) ?? 0;
      final salaryMax = int.tryParse(_salaryMaxController.text.replaceAll(',', '')) ?? 0;
      final recruitingSize = int.tryParse(_recruitingSizeController.text) ?? 1;
      
      // Process education requirements for the backend
      List<Map<String, dynamic>> formattedRequirements = [];
      
      // Add education requirements with level and field
      for (Map<String, dynamic> eduReq in _educationRequirements) {
        formattedRequirements.add({
          'type': 'education',
          'level': eduReq['level'],
          'field': eduReq['field']
        });
      }
      
      // Format job data to match the updated backend serializer
      final jobData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'requirements': formattedRequirements, // Updated to use structured requirements
        'salary_min': salaryMin,
        'salary_max': salaryMax,
        'job_type': _jobType,
        'location': _locationController.text.isEmpty ? _selectedRegion : _locationController.text,
        'is_remote': _isRemote,
        'application_deadline': DateFormat('yyyy-MM-dd').format(_applicationDeadline!),
        'experience_level': _experienceLevel,
        'benefits': _benefits,
        'recruiting_size': recruitingSize,
        'next_step': _nextStep,
        'skills': _selectedSkills,
      };
      
      // Use the JobService to create the job
      final jobService = JobService();
      final result = await jobService.createJob(jobData);
      
      // Log the response for debugging
      print('Job creation response: $result');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );
        
        // Navigate back to the employer home screen
        Navigator.of(context).pushReplacementNamed('/employer/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error posting job: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a New Job Posting',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fill in the details below to create your job posting',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Job Title and Type
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Job Title
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Job Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              value: _selectedTitle,
                              items: jobTitleSkills.keys.map((String title) {
                                return DropdownMenuItem<String>(
                                  value: title,
                                  child: Text(title),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedTitle = newValue;
                                    _selectedSkills = List.from(jobTitleSkills[newValue] ?? []);
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Job Title',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                                hintText: 'e.g., Senior Software Developer',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a job title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Job Type
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Job Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business_center),
                              ),
                              value: _jobType,
                              items: jobTypes.map((Map<String, String> type) {
                                return DropdownMenuItem<String>(
                                  value: type['value'],
                                  child: Text(type['label']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _jobType = newValue;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Experience Level
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Experience Level',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.trending_up),
                              ),
                              value: _experienceLevel,
                              items: experienceLevels.map((Map<String, String> level) {
                                return DropdownMenuItem<String>(
                                  value: level['value'],
                                  child: Text(level['label']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _experienceLevel = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                                hintText: 'Describe the job role, responsibilities, and any other relevant details',
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a job description';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Skills
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Required Skills',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _customSkillController,
                                    decoration: const InputDecoration(
                                      labelText: 'Add Skill',
                                      border: OutlineInputBorder(),
                                      hintText: 'e.g., Python, Project Management',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _addSkill,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedSkills.map((skill) {
                                return Chip(
                                  label: Text(skill),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => _removeSkill(skill),
                                  backgroundColor: Colors.deepPurple.shade100,
                                                                    deleteIconColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Education Requirements
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Education Requirements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Education Level Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Education Level',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.school),
                              ),
                              value: _selectedEducationLevel,
                              items: educationLevels.map((Map<String, String> level) {
                                return DropdownMenuItem<String>(
                                  value: level['value'],
                                  child: Text(level['label']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedEducationLevel = newValue;
                                    _selectedField = null; // Reset field when level changes
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Field Dropdown
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Field of Study',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.book),
                              ),
                              value: _selectedField,
                              hint: const Text('Select a field of study'),
                              items: _availableFields.map((String field) {
                                return DropdownMenuItem<String>(
                                  value: field,
                                  child: Text(field),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedField = newValue;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Add Education Requirement Button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _addEducationRequirement,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Education Requirement'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Display added education requirements
                            if (_educationRequirements.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(_educationRequirements.length, (index) {
                                    final req = _educationRequirements[index];
                                    final levelLabel = educationLevels
                                        .firstWhere((level) => level['value'] == req['level'])
                                        ['label']!;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.school, size: 16, color: Colors.deepPurple),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '$levelLabel in ${req['field']}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle, size: 20, color: Colors.red),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _removeEducationRequirement(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    

                    
                    // Benefits
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Benefits (Optional)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _benefitController,
                                    decoration: const InputDecoration(
                                      labelText: 'Add Benefit',
                                      border: OutlineInputBorder(),
                                      hintText: 'e.g., Health insurance',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _addBenefit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_benefits.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _benefits.map((benefit) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.amber),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(benefit)),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle, size: 20, color: Colors.red),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _removeBenefit(benefit),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Salary Range
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Salary Range',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _salaryMinController,
                                    decoration: const InputDecoration(
                                      labelText: 'Minimum (TZS)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _salaryMaxController,
                                    decoration: const InputDecoration(
                                      labelText: 'Maximum (TZS)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final min = int.tryParse(_salaryMinController.text.replaceAll(',', '')) ?? 0;
                                      final max = int.tryParse(value.replaceAll(',', '')) ?? 0;
                                      if (max <= min) {
                                        return 'Must be > min';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _recruitingSizeController,
                              decoration: const InputDecoration(
                                labelText: 'Number of Positions',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.people),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final size = int.tryParse(value);
                                if (size == null || size < 1) {
                                  return 'Must be at least 1';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Region',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              value: _selectedRegion,
                              items: tanzaniaRegions.map((String region) {
                                return DropdownMenuItem<String>(
                                  value: region,
                                  child: Text(region),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRegion = newValue;
                                  _locationController.text = newValue ?? '';
                                });
                              },
                              validator: (value) {
                                if ((value == null || value.isEmpty) && _locationController.text.isEmpty) {
                                  return 'Please select a region';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Specific Location (Optional)',
                                hintText: 'e.g., Office address, area name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pin_drop),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Remote Work Available'),
                              value: _isRemote,
                              onChanged: (bool value) {
                                setState(() {
                                  _isRemote = value;
                                });
                              },
                              secondary: const Icon(Icons.home_work),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Application Deadline
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Application Deadline',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _selectDeadline,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Application Deadline',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _applicationDeadline == null
                                      ? 'Select a deadline'
                                      : DateFormat('MMMM dd, yyyy').format(_applicationDeadline!),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Next Step',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.next_plan),
                              ),
                              value: _nextStep,
                              items: nextStepOptions.map((Map<String, String> option) {
                                return DropdownMenuItem<String>(
                                  value: option['value'],
                                  child: Text(option['label']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _nextStep = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _postJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('POST JOB'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}