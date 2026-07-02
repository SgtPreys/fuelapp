import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/company.dart';

class CompanyForm extends StatefulWidget {
  final Company? existingCompany; // NEW: Accepts an existing company

  const CompanyForm({super.key, this.existingCompany});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // NEW: Pre-fill data if editing
    if (widget.existingCompany != null) {
      _nameController.text = widget.existingCompany!.name;
      _locationController.text = widget.existingCompany!.location ?? '';
      _contactController.text = widget.existingCompany!.contactPerson ?? '';
      _emailController.text = widget.existingCompany!.email ?? '';
      _phoneController.text = widget.existingCompany!.telephone ?? '';
      _websiteController.text = widget.existingCompany!.website ?? '';
      _infoController.text = widget.existingCompany!.additionalInfo ?? '';
    }
  }

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

  Future<void> _saveCompany() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Company Name!')),
      );
      return;
    }

    final companyData = Company(
      id: widget.existingCompany?.id, // Keep ID if editing
      name: _nameController.text,
      location: _locationController.text,
      contactPerson: _contactController.text,
      email: _emailController.text,
      telephone: _phoneController.text,
      website: _websiteController.text,
      additionalInfo: _infoController.text,
    );

    if (widget.existingCompany == null) {
      await DatabaseHelper.instance.insertCompany(companyData.toMap());
    } else {
      await DatabaseHelper.instance.updateCompany(companyData.toMap());
    }

    if (mounted) {
      Navigator.pop(context, true); // Pass 'true' back to trigger refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCompany != null;

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
            Center(
              child: Text(
                isEditing ? 'Edit Company / Shop' : 'Add Company / Shop', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
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
                onPressed: _saveCompany,
                child: Text(isEditing ? 'Update Company' : 'Save Company'),
              ),
            ),
            
            // --- NEW: DELETE BUTTON ---
            if (isEditing) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () async {
                    // Tell the database to delete this ID
                    await DatabaseHelper.instance.deleteCompany(widget.existingCompany!.id!);
                    if (mounted) {
                      Navigator.pop(context, true); // Close form and trigger refresh
                    }
                  },
                  child: const Text('Delete Company', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}