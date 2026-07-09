import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuelapp/database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

Future<File> exportDatabaseToJson() async {
  final db = await DatabaseHelper.instance.database;

  // 1. Fetch all data from your tables
  final List<Map<String, dynamic>> cars = await db.query('cars');
  final List<Map<String, dynamic>> fuelStops = await db.query('fuel_stops');
  final List<Map<String, dynamic>> maintenanceStops = await db.query('maintenance_stops');
  final List<Map<String, dynamic>> stations = await db.query('stations');
  final List<Map<String, dynamic>> companies = await db.query('companies');

  // 2. Structure the data as a Map
  final Map<String, dynamic> dataToExport = {
    'cars': cars,
    'fuel_stops': fuelStops,
    'maintenance_stops': maintenanceStops,
    'stations': stations,
    'companies': companies,
    'exported_at': DateTime.now().toIso8601String(),
  };

  // 3. Convert to JSON string
  final String jsonString = jsonEncode(dataToExport);

  // 4. Save to a local file
  try {
    final directory = Directory('/storage/emulated/0/Download');
    final file = File('${directory.path}/fuel_backup.json');
    return await file.writeAsString(jsonString);
  } catch (e) {
    print("Error saving backup: $e");
    rethrow;
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
    // 1. Get access to the provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // 2. Check if the current mode is dark
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- App Info Section ---
          const Text("App Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Created by"),
            subtitle: Text("Henri R. Maertins"),
          ),
          const ListTile(
            leading: Icon(Icons.people),
            title: Text("Tested by"),
            subtitle: Text("Daniel Kaffenberger, David S. Zang, Max Gruner, Eric Harder, Rebecca Reinhart and others"),
          ),
          
          const SizedBox(height: 30),

          const Divider(),

          // --- DATABASE OPTIONS ---
          const Text("Database Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.blue),
            title: const Text("Import Database"),
            onTap: () async {
              
              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("⚠️Confirm Import"),
                    content: const Text("Are you sure you want to import the database? This will overwrite existing data.\n\nMake sure you have a backup before proceeding. \n\nOnly import JSON files that were exported from this app!"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await DatabaseHelper.instance.importDatabaseFromJson();
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          await DatabaseHelper.instance.importDatabaseFromJson();
                          if (mounted) {
                            if (success) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Import complete! Refreshing...'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pop();
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to import. Invalid file format.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: const Text("Import", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
              
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.green),
            title: const Text("Export Database"),
            onTap: () async {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              File file = await exportDatabaseToJson();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Database exported to: ${file.path}")));
            },
          ),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete Data"),
            children: [
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
                    title: const Text("⚠️Confirm Deletion"),
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
                        onPressed: () async {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          await DatabaseHelper.instance.clearAllData();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Database cleared!"), backgroundColor: Colors.red));
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.ev_station, color: Colors.red),
            title: const Text("Delete All Fuel Data"),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Confirmation dialog before deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("⚠️Confirm Deletion"),
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
                        onPressed: () async {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          await DatabaseHelper.instance.clearAllDataFuelstops();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Database cleared!"), backgroundColor: Colors.red));
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.red),
            title: const Text("Delete All Maintenance Data"),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Confirmation dialog before deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("⚠️Confirm Deletion"),
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
                        onPressed: () async {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          await DatabaseHelper.instance.clearAllDataMaintenanceStops();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Database cleared!"), backgroundColor: Colors.red));
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
            ],),),
          
          const Divider(),
          const Text("Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          //const Padding(
          //  padding: EdgeInsets.all(16.0),
          //  //child: Text("PREFERENCES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          //),
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (bool value) {
              // Tell the provider to flip the switch and save it!
              themeProvider.toggleTheme(value);
            },
          ),
          const Divider(),
          const Text("System", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          //const Padding(
          //  padding: EdgeInsets.all(16.0),
          //  child: Text("SYSTEM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          //),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            trailing: const Text("1.1.3"), // Read-only
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