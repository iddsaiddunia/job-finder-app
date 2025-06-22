import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class EmployerRegisterScreen extends StatefulWidget {
  const EmployerRegisterScreen({super.key});
  @override
  State<EmployerRegisterScreen> createState() => _EmployerRegisterScreenState();
}

class _EmployerRegisterScreenState extends State<EmployerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _validationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employer Registration')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Register as Employer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Company/Organization Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Enter company/organization name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _validationController,
                decoration: InputDecoration(labelText: 'Validation Info (e.g. Reg. No, Certificate)', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Enter validation info' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(child: CircularProgressIndicator()),
                    );
                    try {
                      await AuthService().registerRecruiter(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        companyName: _companyNameController.text.trim(),
                      );
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Employer Registered! Please log in.')),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                    }
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
