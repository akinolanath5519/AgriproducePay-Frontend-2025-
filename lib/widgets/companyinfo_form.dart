import 'package:agriproduce/state_management/companyInfo_provider.dart';
import 'package:agriproduce/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/screens/dashboard.dart';
import 'package:agriproduce/data_models/companyInfo.dart';

class CompanyInfoForm extends ConsumerStatefulWidget {
  const CompanyInfoForm({super.key});

  @override
  _CompanyInfoFormState createState() => _CompanyInfoFormState();
}

class _CompanyInfoFormState extends ConsumerState<CompanyInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final companyInfo = CompanyInfo(
        id: '', // ID will be generated after saving
        name: _companyNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      // Save company info using provider
      await ref
          .read(companyInfoNotifierProvider.notifier)
          .createCompanyInfo(ref, companyInfo);

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company information saved successfully!'),
          backgroundColor: Colors.black,
        ),
      );

      // Redirect to Admin Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard(isAdmin: true)),
      );
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save company information: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the company name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the phone number.';
                  }
                  if (!RegExp(r'^\d{10,15}$').hasMatch(value.trim())) {
                    return 'Please enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the email address.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      onPressed: _submitForm,
                      text: 'Submit',
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(30),
                      elevation: 15,
                      shadowColor: Colors.black.withOpacity(0.5),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
