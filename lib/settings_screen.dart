import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

void _sendFeedback() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'maertinshenri@gmail.com', // Replace with your email
    query: encodeQueryParameters(<String, String>{
      'subject': 'Feedback Fuel Expense Tracker',
      'body': 'Hi, I have the following feedback for your app:\n\n',
    }),
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(emailLaunchUri);
  } else {
    // Handle error (e.g., show a Snackbar)
    print('Could not launch email');
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controller to make the version editable
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- VERSION SECTION ---
          const Text("App Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Created by"),
            subtitle: Text("Henri R. Maertins"),
          ),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Tested by"),
            subtitle: Text("Daniel Kaffenberger"),
          ),
          const SizedBox(height: 30),

          const Divider(),

          // --- DATABASE OPTIONS ---
          const Text("Database Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.blue),
            title: const Text("Import Database"),
            onTap: () {
              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
              // Placeholder for future logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Import feature coming soon!")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.green),
            title: const Text("Export Database"),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Placeholder for future logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Export feature coming soon!")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Delete All Data"),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Confirmation dialog before deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Deletion"),
                    content: const Text("Are you sure you want to delete all data? This action cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          // Placeholder for future logic
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Database cleared!")));
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("PREFERENCES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            title: const Text("Dark Mode"),
            trailing: const Text("Coming soon"),
            onTap: () { /* Open selection dialog */ },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("SYSTEM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            trailing: const Text("1.1.0"), // Read-only
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Send Feedback"),
            onTap: () { 
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              _sendFeedback(); },
          ),
        ],
      ),
      
    );
  }
}