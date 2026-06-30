import 'package:flutter/material.dart';

class CompanyForm extends StatefulWidget {
  const CompanyForm({super.key});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
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

            // 1. Company Name
            const TextField(
              decoration: InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // 2. Location
            const TextField(
              decoration: InputDecoration(labelText: 'Location / Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // 3. Contact Person
            const TextField(
              decoration: InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),

            // 4. Email 
            const TextField(
              decoration: InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // 5. Telephone 
            const TextField(
              decoration: InputDecoration(labelText: 'Telephone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            // 6. Website 
            const TextField(
              decoration: InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 10),

            // 7. NEW: Additional Information / Notes
            const TextField(
              decoration: InputDecoration(labelText: 'Additional Info / Notes', border: OutlineInputBorder()),
              maxLines: 3, // Makes it a taller text box
            ),
            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // We'll add the saving logic here later!
                  Navigator.pop(context);
                },
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