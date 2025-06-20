import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customTitleController = TextEditingController();
  final _customSkillController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();

  final List<String> jobTitles = [
    'Software Engineer', 'Designer', 'Project Manager', 'Data Analyst', 'Mobile Developer', 'Other'
  ];
  final Map<String, List<String>> jobTitleSkills = {
    'Software Engineer': ['Flutter', 'Dart', 'Java', 'Git'],
    'Designer': ['Figma', 'Adobe XD', 'Photoshop'],
    'Project Manager': ['Agile', 'Scrum', 'Leadership'],
    'Data Analyst': ['SQL', 'Python', 'Excel'],
    'Mobile Developer': ['Flutter', 'Kotlin', 'Swift'],
  };
  final List<String> tanzaniaRegions = [
    'Arusha', 'Dar es Salaam', 'Dodoma', 'Geita', 'Iringa', 'Kagera', 'Katavi', 'Kigoma', 'Kilimanjaro',
    'Lindi', 'Manyara', 'Mara', 'Mbeya', 'Morogoro', 'Mtwara', 'Mwanza', 'Njombe', 'Pemba North',
    'Pemba South', 'Pwani', 'Rukwa', 'Ruvuma', 'Shinyanga', 'Simiyu', 'Singida', 'Tabora', 'Tanga',
    'Zanzibar North', 'Zanzibar South', 'Zanzibar West'
  ];

  String? selectedTitle;
  String? selectedRegion;
  String? jobType;
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedSkills = [];

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !selectedSkills.contains(skill)) {
      setState(() {
        selectedSkills.add(skill);
      });
    }
    _customSkillController.clear();
  }

  void _removeSkill(String skill) {
    setState(() {
      selectedSkills.remove(skill);
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post a Job')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              // Job Title Dropdown + Custom
              DropdownButtonFormField<String>(
                value: selectedTitle,
                items: jobTitles.map((title) => DropdownMenuItem(
                  value: title,
                  child: Text(title),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedTitle = val;
                    selectedSkills.clear();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                  helperText: 'Pick from the list or select "Other" to enter manually'
                ),
                validator: (value) => value == null || value.isEmpty ? 'Select job title' : null,
              ),
              if (selectedTitle == 'Other') ...[
                SizedBox(height: 10),
                TextFormField(
                  controller: _customTitleController,
                  decoration: InputDecoration(
                    labelText: 'Custom Job Title',
                    border: OutlineInputBorder(),
                    helperText: 'Enter job title if not in the list',
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Enter job title' : null,
                ),
              ],
              SizedBox(height: 14),
              // Skills
              if (selectedTitle != null && jobTitleSkills[selectedTitle!] != null) ...[
                Builder(
                  builder: (context) {
                    final availableSkills = jobTitleSkills[selectedTitle!]!
                        .where((s) => !selectedSkills.contains(s))
                        .toList();
                    return DropdownButtonFormField<String>(
                      key: ValueKey(availableSkills.join(',')),
                      value: null,
                      items: availableSkills
                          .map((skill) => DropdownMenuItem(
                                value: skill,
                                child: Text(skill),
                              ))
                          .toList(),
                      onChanged: availableSkills.isEmpty
                          ? null
                          : (val) {
                              if (val != null) {
                                _addSkill(val);
                              }
                            },
                      decoration: InputDecoration(
                        labelText: 'Add Skill',
                        border: OutlineInputBorder(),
                        helperText: availableSkills.isEmpty
                            ? 'All suggested skills added'
                            : 'Pick a skill or add your own',
                      ),
                      disabledHint: Text('No more skills to add'),
                    );
                  },
                ),
              ],
              TextFormField(
                controller: _customSkillController,
                decoration: InputDecoration(
                  labelText: 'Add Skill Manually',
                  border: OutlineInputBorder(),
                  helperText: 'Type a skill and press enter',
                ),
                onFieldSubmitted: _addSkill,
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: selectedSkills
                    .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                        ))
                    .toList(),
              ),
              SizedBox(height: 14),
              // Location
              DropdownButtonFormField<String>(
                value: selectedRegion,
                items: tanzaniaRegions.map((region) => DropdownMenuItem(
                  value: region,
                  child: Text(region),
                )).toList(),
                onChanged: (val) => setState(() => selectedRegion = val),
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  helperText: 'Pick a region in Tanzania',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Select location' : null,
              ),
              SizedBox(height: 14),
              // Job Type
              Text('Job Type', style: TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Short Term',
                      groupValue: jobType,
                      title: Text('Short Term'),
                      onChanged: (val) => setState(() => jobType = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Contract',
                      groupValue: jobType,
                      title: Text('Contract'),
                      onChanged: (val) => setState(() => jobType = val),
                    ),
                  ),
                ],
              ),
              if (jobType == 'Short Term') ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(isStart: true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(startDate == null
                              ? 'Pick start date'
                              : '${startDate!.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(isStart: false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(endDate == null
                              ? 'Pick end date'
                              : '${endDate!.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
              ],
              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  labelText: 'Salary',
                  border: OutlineInputBorder(),
                  helperText: 'e.g., 1,000,000 TZS/month',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter salary' : null,
              ),
              SizedBox(height: 14),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Job Description',
                  border: OutlineInputBorder(),
                  helperText: 'Describe the job role and responsibilities',
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Enter job description' : null,
              ),
              SizedBox(height: 14),
              // Requirements
              TextFormField(
                controller: _requirementsController,
                decoration: InputDecoration(
                  labelText: 'Requirements',
                  border: OutlineInputBorder(),
                  helperText: 'List any requirements or qualifications',
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Enter requirements' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Replace with API call to save/post job
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Job posted!')),
                    );
                  }
                },
                icon: Icon(Icons.send),
                label: Text('Post Job'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
