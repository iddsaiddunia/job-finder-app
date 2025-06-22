import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/token_storage.dart';

class JobFinderProfileScreen extends StatefulWidget {
  const JobFinderProfileScreen({super.key});

  @override
  State<JobFinderProfileScreen> createState() => _JobFinderProfileScreenState();
}

class _JobFinderProfileScreenState extends State<JobFinderProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  bool isLoading = false;
  bool _isAvailable = true;
  
  // Profile data
  String name = '';
  String email = '';
  String phone = '';
  String linkedin = '';
  String location = '';
  int? salaryExpectation;
  bool willingToRelocate = false;
  String? profilePictureUrl;
  String? resumeUrl;
  
  final ImagePicker _imagePicker = ImagePicker();
  
  // Reactive lists using ValueNotifier
  late ValueNotifier<List<Map<String, String>>> educations;
  late ValueNotifier<List<String>> skills;
  late ValueNotifier<List<Map<String, String>>> experiences;

  // Education levels and types
  final Map<String, List<String>> _educationTypes = {
    'No Education': ['None'],
    'Ordinary Levels': ['O-Level', 'Secondary School'],
    'Certificate': ['Professional Certificate', 'Technical Certificate', 'Online Certificate'],
    'Diploma': ['Higher Diploma', 'Ordinary Diploma', 'Advanced Diploma'],
    'Degree': ['Bachelor of Science', 'Bachelor of Arts', 'Bachelor of Engineering', 'Bachelor of Technology'],
    'Masters': ['Master of Science', 'Master of Arts', 'Master of Business Administration', 'Master of Engineering'],
    'PhD': ['Doctor of Philosophy', 'Doctor of Science', 'Doctor of Engineering'],
  };

  final List<String> _educationLevels = ['No Education', 'Ordinary Levels', 'Certificate', 'Diploma', 'Degree', 'Masters', 'PhD'];
  
  // Education fields across different disciplines
  final List<String> _educationFields = [
    'None',
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Business Administration',
    'Finance',
    'Accounting',
    'Marketing',
    'Human Resources',
    'Medicine',
    'Nursing',
    'Pharmacy',
    'Agriculture',
    'Environmental Science',
    'Biology',
    'Chemistry',
    'Physics',
    'Mathematics',
    'Statistics',
    'Economics',
    'Law',
    'Education',
    'Psychology',
    'Sociology',
    'Political Science',
    'History',
    'Geography',
    'Languages',
    'Arts',
    'Architecture',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    educations = ValueNotifier([]);
    skills = ValueNotifier([]);
    experiences = ValueNotifier([]);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    
    try {
      // Debug: Check if we have a valid token
      final loginData = await TokenStorage.getLoginData();
      print('Token exists: ${loginData['access'] != null}');
      print('User type: ${loginData['user_type']}');
      
      final profileData = await _userService.getUserProfile();
      
      setState(() {
        name = profileData['full_name'] ?? '';
        email = profileData['email'] ?? '';
        phone = profileData['phone'] ?? '';
        linkedin = profileData['linkedin'] ?? '';
        location = profileData['location'] ?? '';
        salaryExpectation = profileData['salary_expectation'];
        willingToRelocate = profileData['willing_to_relocate'] ?? false;
        profilePictureUrl = profileData['profile_picture'];
        resumeUrl = profileData['resume'];
        _isAvailable = profileData['is_available'] ?? false;
        
        // Parse skills
        if (profileData['skills'] != null) {
          skills.value = List<String>.from(profileData['skills']);
        }
        
        // Parse education
        if (profileData['education'] != null) {
          educations.value = (profileData['education'] as List)
              .map((e) {
                Map<String, String> eduMap = Map<String, String>.from(e);
                // Add field key if missing (for ML model compatibility)
                if (!eduMap.containsKey('field') && eduMap.containsKey('type')) {
                  eduMap['field'] = eduMap['type'] ?? ''; // Handle null case with empty string fallback
                }
                return eduMap;
              })
              .toList();
        }
        
        // Parse experience
        if (profileData['experience'] != null) {
          experiences.value = (profileData['experience'] as List)
              .map((e) => Map<String, String>.from(e))
              .toList();
        }
        
        isLoading = false;
      });
    } catch (e) {
      print('Profile loading error: $e');
      setState(() => isLoading = false);
      
      if (mounted) {
        // Check if it's an authentication error
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          // Navigate to login screen
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      final profileData = <String, dynamic>{
        // Include all writable fields with proper data type handling
        'full_name': name.trim(),
        'phone': phone.trim(),
        'linkedin': linkedin.trim(),
        'location': location.trim(),
        'willing_to_relocate': willingToRelocate,
        'education': educations.value,
        'skills': skills.value,
        'experience': experiences.value,
        'is_available': _isAvailable,
      };
      
      // Only include salary_expectation if it's not null
      if (salaryExpectation != null) {
        profileData['salary_expectation'] = salaryExpectation;
      }
      
      // Debug: Print the data being sent
      print('Sending profile data: $profileData');
      
      await _userService.updateUserProfile(profileData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Profile update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAvailability() async {
    try {
      final result = await _userService.toggleAvailability();
      setState(() {
        _isAvailable = result['is_available'] ?? _isAvailable;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAvailable ? 'You are now available for opportunities' : 'You are now unavailable'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling availability: ${e.toString()}')),
        );
      }
    }
  }

  void _logout() async {
    try {
      final success = await _authService.logout();
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showAddEducationSheet(BuildContext context, {Map<String, String>? edu, int? idx}) {
    String selectedLevel = edu?['level'] ?? _educationLevels.first;
    String selectedType = edu?['type'] ?? '';
    String selectedField = edu?['field'] ?? 'None';
    String institution = edu?['institution'] ?? '';
    String year = edu?['year'] ?? '';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                edu != null ? 'Edit Education' : 'Add Education',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: const InputDecoration(labelText: 'Education Level'),
                items: _educationLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                onChanged: isSaving ? null : (value) {
                  setModalState(() {
                    selectedLevel = value!;
                    selectedType = '';
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_educationTypes[selectedLevel] != null)
                DropdownButtonFormField<String>(
                  value: selectedType.isEmpty ? null : selectedType,
                  decoration: const InputDecoration(labelText: 'Education Type'),
                  items: _educationTypes[selectedLevel]!.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: isSaving ? null : (value) => setModalState(() => selectedType = value ?? ''),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedField,
                decoration: const InputDecoration(labelText: 'Field of Study'),
                items: _educationFields.map((field) => DropdownMenuItem(value: field, child: Text(field))).toList(),
                onChanged: isSaving ? null : (value) => setModalState(() => selectedField = value ?? 'None'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: institution),
                decoration: const InputDecoration(labelText: 'Institution'),
                enabled: !isSaving,
                onChanged: (value) => institution = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: year),
                decoration: const InputDecoration(labelText: 'Year'),
                enabled: !isSaving,
                onChanged: (value) => year = value,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (institution.trim().isEmpty || year.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields')),
                        );
                        return;
                      }
                      
                      setModalState(() => isSaving = true);
                      
                      try {
                        final newEdu = {
                          'level': selectedLevel,
                          'type': selectedType,
                          'field': selectedField, // Dedicated field for ML model compatibility
                          'institution': institution.trim(),
                          'year': year.trim(),
                        };
                        
                        final updated = [...educations.value];
                        if (idx != null) {
                          updated[idx] = newEdu;
                        } else {
                          updated.add(newEdu);
                        }
                        educations.value = updated;
                        
                        await _updateProfile();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving education: ${e.toString()}')),
                        );
                      } finally {
                        setModalState(() => isSaving = false);
                      }
                    },
                    child: isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    String newSkill = '';
    bool isSaving = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Skill'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Skill'),
            enabled: !isSaving,
            onChanged: (value) => newSkill = value,
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (newSkill.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a skill')),
                  );
                  return;
                }
                  
                setDialogState(() => isSaving = true);
                  
                try {
                  final updated = [...skills.value, newSkill.trim()];
                  skills.value = updated;
                  await _updateProfile();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving skill: ${e.toString()}')),
                  );
                } finally {
                  setDialogState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOrEditExperienceSheet(BuildContext context, {Map<String, String>? exp, int? idx}) {
    String title = exp?['title'] ?? '';
    String company = exp?['company'] ?? '';
    String duration = exp?['duration'] ?? '';
    String description = exp?['desc'] ?? '';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exp != null ? 'Edit Experience' : 'Add Experience',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: title),
                decoration: const InputDecoration(labelText: 'Job Title'),
                enabled: !isSaving,
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: company),
                decoration: const InputDecoration(labelText: 'Company'),
                enabled: !isSaving,
                onChanged: (value) => company = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: duration),
                decoration: const InputDecoration(labelText: 'Duration (e.g., Jan 2020 - Dec 2022)'),
                enabled: !isSaving,
                onChanged: (value) => duration = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: description),
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                enabled: !isSaving,
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (title.trim().isEmpty || company.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in title and company')),
                        );
                        return;
                      }
                      
                      setModalState(() => isSaving = true);
                      
                      try {
                        final newExp = {
                          'title': title.trim(),
                          'company': company.trim(),
                          'duration': duration.trim(),
                          'desc': description.trim(),
                        };
                        
                        final updated = [...experiences.value];
                        if (idx != null) {
                          updated[idx] = newExp;
                        } else {
                          updated.add(newExp);
                        }
                        experiences.value = updated;
                        
                        await _updateProfile();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving experience: ${e.toString()}')),
                        );
                      } finally {
                        setModalState(() => isSaving = false);
                      }
                    },
                    child: isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    String tempName = name;
    String tempPhone = phone;
    String tempLinkedin = linkedin;
    String tempLocation = location;
    int? tempSalaryExpectation = salaryExpectation;
    bool tempWillingToRelocate = willingToRelocate;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: tempName),
                decoration: const InputDecoration(labelText: 'Full Name'),
                enabled: !isSaving,
                onChanged: (value) => tempName = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: email),
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false, // Email cannot be changed
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: tempPhone),
                decoration: const InputDecoration(labelText: 'Phone'),
                enabled: !isSaving,
                onChanged: (value) => tempPhone = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: tempLinkedin),
                decoration: const InputDecoration(labelText: 'LinkedIn'),
                enabled: !isSaving,
                onChanged: (value) => tempLinkedin = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: tempLocation),
                decoration: const InputDecoration(labelText: 'Location'),
                enabled: !isSaving,
                onChanged: (value) => tempLocation = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: tempSalaryExpectation?.toString() ?? ''),
                decoration: const InputDecoration(labelText: 'Salary Expectation'),
                enabled: !isSaving,
                onChanged: (value) => tempSalaryExpectation = int.tryParse(value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Willing to Relocate'),
                  const SizedBox(width: 10),
                  Switch(
                    value: tempWillingToRelocate,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    onChanged: isSaving ? null : (val) => setModalState(() => tempWillingToRelocate = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      setModalState(() => isSaving = true);
                      
                      try {
                        setState(() {
                          name = tempName.trim();
                          phone = tempPhone.trim();
                          linkedin = tempLinkedin.trim();
                          location = tempLocation.trim();
                          salaryExpectation = tempSalaryExpectation;
                          willingToRelocate = tempWillingToRelocate;
                        });
                        
                        await _updateProfile();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
                        );
                      } finally {
                        setModalState(() => isSaving = false);
                      }
                    },
                    child: isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => isLoading = true);
        
        final result = await _userService.uploadProfilePicture(File(image.path));
        
        if (mounted) {
          setState(() {
            profilePictureUrl = result['profile_picture'];
            isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading profile picture: $e')),
        );
      }
    }
  }

  Future<void> _uploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      
      if (result != null) {
        setState(() => isLoading = true);
        
        final uploadResult = await _userService.uploadResume(File(result.files.single.path!));
        
        if (mounted) {
          setState(() {
            resumeUrl = uploadResult['resume'];
            isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resume uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading resume: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              children: [
                // Availability toggle at the top
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
                    const SizedBox(width: 10),
                    Switch(
                      value: _isAvailable,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: (val) {
                        setState(() {
                          _isAvailable = val;
                        });
                        _toggleAvailability();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _uploadProfilePicture,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Colors.deepPurple[50],
                                    backgroundImage: profilePictureUrl != null && profilePictureUrl!.isNotEmpty 
                                        ? NetworkImage(profilePictureUrl!) 
                                        : null,
                                    child: profilePictureUrl == null || profilePictureUrl!.isEmpty ? Text(
                                      name.isNotEmpty 
                                        ? name.split(' ')
                                            .where((e) => e.isNotEmpty)
                                            .take(2)
                                            .map((e) => e[0].toUpperCase())
                                            .join()
                                        : 'U',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ) : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                        onPressed: () => _showEditProfile(context),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.school, size: 18, color: Colors.deepPurple),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          educations.value.isNotEmpty 
                                              ? educations.value.map((e) => "${e['level']} - ${e['institution']}").join(', ')
                                              : 'No education added',
                                          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1.2),
                        const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.email, size: 18, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 18, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(phone, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.link, size: 18, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(linkedin, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_pin, size: 18, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(location, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1.2),
                        
                        // Education Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Education', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.deepPurple),
                              onPressed: () => _showAddEducationSheet(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<List<Map<String, String>>>(
                          valueListenable: educations,
                          builder: (context, eduList, _) => eduList.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('No education details added yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                )
                              : Column(
                                  children: eduList.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final edu = entry.value;
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(edu['level']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                  if (edu['type']!.isNotEmpty) Text(edu['type']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                  if (edu['institution']!.isNotEmpty) Text(edu['institution']!, style: const TextStyle(fontSize: 13)),
                                                  if (edu['year']!.isNotEmpty) Text(edu['year']!, style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit, color: Colors.deepPurple, size: 18),
                                                  onPressed: () => _showAddEducationSheet(context, edu: edu, idx: idx),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    final updated = [...eduList]..removeAt(idx);
                                                    educations.value = updated;
                                                    await _updateProfile();
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Skills Section
                Text('Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<String>>(
                  valueListenable: skills,
                  builder: (context, skillList, _) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...skillList.map((skill) => Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () async {
                          setState(() {
                            isLoading = true;
                          });
                          final updated = [...skillList]..remove(skill);
                          skills.value = updated;
                          await _updateProfile();
                          setState(() {
                            isLoading = false;
                          });
                        },
                      )),
                      ActionChip(
                        label: const Text('+ Add Skill'),
                        onPressed: () => _showAddSkillDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Experience Section
                Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<Map<String, String>>>(
                  valueListenable: experiences,
                  builder: (context, expList, _) => Column(
                    children: [
                      ...expList.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final exp = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(exp['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text(exp['company']!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(exp['duration']!, style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                                      const SizedBox(height: 6),
                                      Text(exp['desc']!, style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.deepPurple, size: 20),
                                      tooltip: 'Edit',
                                      onPressed: () => _showAddOrEditExperienceSheet(context, exp: exp, idx: idx),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        final updated = [...expList]..removeAt(idx);
                                        experiences.value = updated;
                                        await _updateProfile();
                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      OutlinedButton.icon(
                        onPressed: () => _showAddOrEditExperienceSheet(context),
                        icon: const Icon(Icons.add, color: Colors.deepPurple),
                        label: const Text('Add Experience', style: TextStyle(color: Colors.deepPurple)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurple),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Picture Upload
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profile Picture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _uploadProfilePicture,
                      child: const Text('Upload Profile Picture'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Resume Upload
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Resume', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _uploadResume,
                      child: const Text('Upload Resume'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Logout Button
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: _logout,
                  ),
                ),
              ],
            ),
    );
  }
}