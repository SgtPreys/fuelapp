import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/company.dart';

class CompanyForm extends StatefulWidget {
  const CompanyForm({super.key});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  // --- Save Logic ---
  Future<void> _saveCompany() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Company Name!')),
      );
      return;
    }

    final newCompany = Company(
      name: _nameController.text,
      location: _locationController.text,
      contactPerson: _contactController.text,
      email: _emailController.text,
      telephone: _phoneController.text,
      website: _websiteController.text,
      additionalInfo: _infoController.text,
    );

    await DatabaseHelper.instance.insertCompany(newCompany.toMap());

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('Add Company / Shop', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Company Name*', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location / Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telephone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: 'Additional Info / Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveCompany, // Calls our save function!
                child: const Text('Save Company'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}