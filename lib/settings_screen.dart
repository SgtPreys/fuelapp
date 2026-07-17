import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuelapp/database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'l10n/app_localizations.dart';
import 'providers/language_provider.dart';

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
          Text(AppLocalizations.of(context)!.appinfo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.createdby),
            subtitle: Text("Henri R. Maertins"),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(AppLocalizations.of(context)!.testedby),
            subtitle: Text("Daniel Kaffenberger, David S. Zang, Max Gruner, Eric Harder, Rebecca Reinhart and others"),
          ),
          
          const SizedBox(height: 30),

          const Divider(),

          // --- DATABASE OPTIONS ---
          Text(AppLocalizations.of(context)!.databasemanagement, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.blue),
            title: Text(AppLocalizations.of(context)!.importdatabase),
            onTap: () async {
              
              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmimport),
                    content: Text(AppLocalizations.of(context)!.confirmimporttext),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
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
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.importcomplete),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pop();
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.importincomplete),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.import, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
              
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.green),
            title: Text(AppLocalizations.of(context)!.exportdatabase),
            onTap: () async {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              File file = await exportDatabaseToJson();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.databaseexported(file.path))));
            },
          ),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.deletedata),
            children: [
              ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.deletealldata),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Confirmation dialog before deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmdeletion),
                    content: Text(AppLocalizations.of(context)!.confirmdeletiontext),
                    actions: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          await DatabaseHelper.instance.clearAllData();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.databasecleared), backgroundColor: Colors.red));
                        },
                        child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.ev_station, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.deleteallfueldata),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Confirmation dialog before deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmdeletion),
                    content: Text(AppLocalizations.of(context)!.confirmdeletiontext),
                    actions: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          await DatabaseHelper.instance.clearAllDataFuelstops();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.databasecleared), backgroundColor: Colors.red));
                        },
                        child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.deleteallmaintenancedata),
            onTap: () {
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              // Confirmation dialog before deletion
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmdeletion),
                    content: Text(AppLocalizations.of(context)!.confirmdeletiontext),
                    actions: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.heavyImpact(); // <-- NEW HAPTIC BUMP
                          Navigator.of(context).pop();
                          await DatabaseHelper.instance.clearAllDataMaintenanceStops();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.databasecleared), backgroundColor: Colors.red));
                        },
                        child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
            ],),),
          
          const Divider(),
          Text(AppLocalizations.of(context)!.preferences, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          //const Padding(
          //  padding: EdgeInsets.all(16.0),
          //  //child: Text("PREFERENCES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          //),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.enabledarkmode),
            secondary: const Icon(Icons.dark_mode),
            value: isDarkMode,
            onChanged: (bool value) {
              // Tell the provider to flip the switch and save it!
              themeProvider.toggleTheme(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            // If you already added "settingsLanguage" to your app_en.arb, 
            // you can use AppLocalizations.of(context)!.settingsLanguage here!
            title: Text(AppLocalizations.of(context)!.languagesettings), 
            trailing: DropdownButton<String>(
              // We check the current locale to display the correct starting value
              value: Localizations.localeOf(context).languageCode,
              underline: const SizedBox(), // Removes the default messy line under the dropdown
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(AppLocalizations.of(context)!.english),
                ),
                DropdownMenuItem(
                  value: 'de',
                  child: Text(AppLocalizations.of(context)!.german),
                ),
              ],
              onChanged: (String? newValue) {
              if (newValue != null) {
                // Talk to the provider directly
                Provider.of<LanguageProvider>(context, listen: false)
                    .setLocale(Locale(newValue));
              }
              }
            ),
          ),
          const Divider(),
          Text(AppLocalizations.of(context)!.system, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          //const Padding(
          //  padding: EdgeInsets.all(16.0),
          //  child: Text("SYSTEM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          //),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            trailing: const Text("1.4.0"), // Read-only
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(AppLocalizations.of(context)!.sendfeedback),
            onTap: () { 
              HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
              _sendFeedback(); },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(AppLocalizations.of(context)!.senddonation),
            onTap: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.senddonationtext), backgroundColor: Colors.green));
            },

          ),
          
        ],
      ),
      
    );
  }
}