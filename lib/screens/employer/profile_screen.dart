import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder/services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/token_storage.dart';
import '../../widgets/loading_indicator.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});
  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  Map<String, dynamic> _profileData = {};
  File? _logoFile;
  String? _logoUrl;
  
  // Form controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _validationInfoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _companySizeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedIndustry;
  final List<String> _industries = [
    'Information Technology', 'Finance', 'Healthcare', 'Education', 'Construction',
    'Manufacturing', 'Retail', 'Agriculture', 'Transport', 'Hospitality',
    'Energy', 'Telecommunications', 'Media', 'Legal', 'Government', 'Other'
  ];

  final List<String> _countryCodes = ['+255', '+254', '+256', '+257'];
  String _selectedCountryCode = '+255';

  final List<String> _companySizes = [
    '1-10', '11-50', '51-200', '201-500', '501-1000', '1000+'
  ];
  String? _selectedCompanySize;

  final List<String> _tzRegions = [
    'Arusha', 'Dar es Salaam', 'Dodoma', 'Geita', 'Iringa', 'Kagera',
    'Katavi', 'Kigoma', 'Kilimanjaro', 'Lindi', 'Manyara', 'Mara',
    'Mbeya', 'Morogoro', 'Mtwara', 'Mwanza', 'Njombe', 'Pemba North',
    'Pemba South', 'Pwani', 'Rukwa', 'Ruvuma', 'Shinyanga', 'Simiyu',
    'Singida', 'Tabora', 'Tanga', 'Zanzibar North', 'Zanzibar South',
    'Zanzibar West'
  ];
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // Debug: Check if we have a valid token
      final loginData = await TokenStorage.getLoginData();
      print('Token exists: ${loginData['access'] != null}');
      print('User type: ${loginData['user_type']}');
      
      // Load profile data from API
      final profileData = await _userService.getRecruiterProfile();
      print('Loaded profile data: $profileData');
      
      setState(() {
        _profileData = profileData;
        _companyNameController.text = profileData['company_name'] ?? '';
        _descriptionController.text = profileData['company_description'] ?? '';
        _logoUrl = profileData['logo'];
        
        // Handle industry selection
        final industry = profileData['industry'] ?? '';
        if (_industries.contains(industry)) {
          _selectedIndustry = industry;
        } else if (industry.isNotEmpty) {
          _selectedIndustry = 'Other';
          _industryController.text = industry;
        }
        
        // Handle company size
        final companySize = profileData['company_size'] ?? '';
        if (_companySizes.contains(companySize)) {
          _selectedCompanySize = companySize;
        } else {
          _companySizeController.text = companySize;
        }
        
        // Handle phone with country code
        String phone = profileData['phone'] ?? '';
        String code = '+255';
        for (final c in _countryCodes) {
          if (phone.startsWith(c)) {
            code = c;
            phone = phone.substring(c.length).trim();
            break;
          }
        }
        _selectedCountryCode = code;
        _phoneController.text = phone;
        
        // Other fields
        _websiteController.text = profileData['website'] ?? '';
        _addressController.text = profileData['address'] ?? '';
        
        // Extract region from address if possible
        final address = profileData['address'] ?? '';
        for (final region in _tzRegions) {
          if (address.contains(region)) {
            _selectedRegion = region;
            break;
          }
        }
        
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: $e';
      });
      print('Error loading profile: $e');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _validationInfoController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _industryController.dispose();
    _companySizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    try {
      // Prepare the profile data
      final Map<String, dynamic> profileData = {
        'company_description': _descriptionController.text,
        'industry': _selectedIndustry == 'Other' ? _industryController.text : (_selectedIndustry ?? ''),
        'company_size': _selectedCompanySize ?? _companySizeController.text,
        'website': _websiteController.text,
        'phone': _selectedCountryCode + ' ' + _phoneController.text.trim(),
        'address': _selectedRegion != null ? 
          '${_addressController.text}, $_selectedRegion' : _addressController.text,
      };
      
      print('Updating profile with data: $profileData');
      
      // Call the API to update the profile
      final updatedProfile = await _userService.updateRecruiterProfile(profileData);
      
      // Update the local state with the response
      setState(() {
        _profileData = updatedProfile;
        _isSaving = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to update profile: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Refresh profile',
          ),
        ],
      ),
      body: _isLoading ? 
        const Center(child: LoadingIndicator()) : 
        _buildProfileForm(),
    );
  }
  
  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            
          // Company Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blueGrey.shade100,
                              backgroundImage: _logoFile != null ? 
                                FileImage(_logoFile!) : 
                                (_logoUrl != null ? NetworkImage(_logoUrl!) : null) as ImageProvider?,
                              child: (_logoFile == null && _logoUrl == null) ? 
                                Icon(Icons.business, size: 40, color: Colors.blueGrey) : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 16, color: Colors.white),
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
                            Text(
                              _companyNameController.text,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Email: ${_profileData['email'] ?? ''}',
                              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                            ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Text('Edit Company Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _validationInfoController,
              decoration: InputDecoration(labelText: 'Registration/Validation Info', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 90,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountryCode,
                    items: _countryCodes.map((code) => DropdownMenuItem(
                      value: code,
                      child: Text(code),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCountryCode = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Code',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _websiteController,
              decoration: InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
              // keyboardType: TextInputType.url,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    value: 'Tanzania',
                    items: [DropdownMenuItem(value: 'Tanzania', child: Text('Tanzania'))],
                    onChanged: null, // locked
                    decoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    items: _tzRegions.map((region) => DropdownMenuItem(
                      value: region,
                      child: Text(region),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedRegion = val;
                          _addressController.text = val; // Update address with selected region
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                      hintText: 'Select region',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Builder(
              builder: (context) {
                final List<String> industries = [
                  'Information Technology', 'Finance', 'Healthcare', 'Education', 'Construction',
                  'Manufacturing', 'Retail', 'Agriculture', 'Transport', 'Hospitality',
                  'Energy', 'Telecommunications', 'Media', 'Legal', 'Government', 'Other'
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedIndustry,
                      items: industries.map((ind) => DropdownMenuItem(
                        value: ind,
                        child: Text(ind),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedIndustry = val;
                          if (val != 'Other' && val != null) {
                            _industryController.text = val;
                          } else if (val == 'Other') {
                            _industryController.text = '';
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Industry/Field',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_selectedIndustry == 'Other') ...[
                      SizedBox(height: 10),
                      TextField(
                        controller: _industryController,
                        decoration: InputDecoration(
                          labelText: 'Enter Industry',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ]
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCompanySize,
              items: _companySizes.map((size) => DropdownMenuItem(
                value: size,
                child: Text(size),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCompanySize = val;
                    _companySizeController.text = val;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Company Size',
                border: OutlineInputBorder(),
                hintText: 'Select company size',
              ),
            ),
            // Allow custom company size if needed
            if (_selectedCompanySize == null && _companySizeController.text.isNotEmpty) ...[  
              SizedBox(height: 10),
              TextField(
                controller: _companySizeController,
                decoration: InputDecoration(
                  labelText: 'Custom Company Size',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 1-10, 11-50, 51-200',
                ),
              ),
            ],
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description/About', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: Icon(Icons.save),
              label: Text('Save Profile'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                await AuthService().logout();
                if (!mounted) return;
                // Only use context after confirming mounted
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
      ));
  }
}
