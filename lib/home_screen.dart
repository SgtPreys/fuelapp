import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'database/database_helper.dart';
import 'models/fuel_stop.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // We remove the underscore so main.dart can trigger a refresh here too!
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _recentFuel = [];
  List<Map<String, dynamic>> _recentMaintenance = [];
  List<Map<String, dynamic>> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final fuel = await DatabaseHelper.instance.getRecentFuelStops();
    final maintenance = await DatabaseHelper.instance.getRecentMaintenanceStops();
    final loadedCars = await DatabaseHelper.instance.getAllCars();

    setState(() {
      _recentFuel = fuel;
      _recentMaintenance = maintenance;
      _cars = loadedCars;
      _isLoading = false;
    });
    _checkTuevAlerts(loadedCars);
  }
  void _checkTuevAlerts(List<Map<String, dynamic>> cars) {
    DateTime now = DateTime.now();

    for (var car in cars) {
      // 1. Skip cars that are sold or have no TÜV set
      if (car['status'] == 'Sold' || car['nextTuev'] == null || car['nextTuev'].toString().trim().isEmpty) {
        continue;
      }

      String tuevString = car['nextTuev']; // Example: "07/2027"

      try {
        List<String> parts = tuevString.split('/');
        if (parts.length == 2) {
          // NOTE: If your app saves it as yyyy/MM, swap these two lines!
          int month = int.parse(parts[0]); 
          int year = int.parse(parts[1]);

          // 2. Calculate the difference in months
          int monthsAway = ((year - now.year) * 12) + (month - now.month);

          // 3. Show Notification if it's 2 months away (or less)
          if (monthsAway <= 6 && monthsAway >= 0) {
            // Delaying the SnackBar slightly ensures the screen has finished building
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ Reminder: TÜV for ${car['carName']} is due in $monthsAway month(s)! ($tuevString)'),
                    backgroundColor: Colors.orange.shade800,
                    duration: const Duration(seconds: 10), // Stays on screen for 10 seconds
                    behavior: SnackBarBehavior.floating,
                    // margin: EdgeInsets.only(
                    //   bottom: MediaQuery.of(context).size.height - -20, // Pushes it to the top
                    //   // left: 15,
                    //   // right: 15,
                    // ), // Makes it look like a nice floating notification pill
                  ),
                );
              }
            });
          } else if (monthsAway < 0) {
            // Optional: Show a red alert if it's already expired!
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🚨 Alert: TÜV for ${car['carName']} is EXPIRED!'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    // margin: EdgeInsets.only(
                    //   bottom: MediaQuery.of(context).size.height - -20,
                    //   // left: 15,
                    //   // right: 15,
                    // ),
                  ),
                );
              }
            });
          }
        }
      } catch (e) {
        // If a date is formatted weirdly, it just skips that car instead of crashing
        print('Error parsing TÜV date for ${car['carName']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.dashboard, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 20),

          // --- RECENT FUEL LOGS ---
          Row(
            children: [
              Icon(Icons.ev_station, color: Colors.blue),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.recentfuelstop, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))
               // <-- NEW SHIMMER EFFECT
            ],
          ).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const Divider(),
          if (_recentFuel.isEmpty) 
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppLocalizations.of(context)!.nofuelstopsyet, style: TextStyle(color: Colors.grey)),
            )
          else 
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Lets the main screen handle scrolling
              itemCount: _recentFuel.length,
              itemBuilder: (context, index) {
                final stop = _recentFuel[index];

                final double totalPrice = (stop['totalPrice'] as num?)?.toDouble() ?? 0.0;
                final double distance = (stop['distance'] as num?)?.toDouble() ?? 0.0;
                double localCostPerKm = 0.0;
                if (distance > 0) {
                  localCostPerKm = totalPrice / distance;
                }

                final fuelObj = FuelStop.fromMap(stop); // Use our model!
                        String consumptionStr = fuelObj.consumption != null 
                            ? '${fuelObj.consumption!.toStringAsFixed(2)} L/100km' 
                            : '0.00 L/100km';
                            
                        String priceLStr = fuelObj.pricePerLiter != null 
                            ? '${fuelObj.pricePerLiter!.toStringAsFixed(2)} €/L' 
                            : '0.00 €/L';
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${stop['carName']} at ${stop['stationName'] ?? AppLocalizations.of(context)!.unknownstation}'),
                    // NEW: Multi-line subtitle using our calculations
                    subtitle: Builder(
                      builder: (context) {
                        return Text(
                          'Date: ${stop['date']} ${stop['distance'] != null ? '\nDistance: ${stop['distance']} km' : ''} ${stop['liters'] != null ? '• Liters: ${stop['liters']}' : ''}\n$consumptionStr • $priceLStr • ${localCostPerKm.toStringAsFixed(2)} €/km'
                        );
                      }
                    ),
                    isThreeLine: true, // Gives the text more room to breathe
                    trailing: Text(
                      stop['totalPrice'] != null ? '€${stop['totalPrice'].toStringAsFixed(2)}\n$consumptionStr' : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                    ).animate().shimmer(duration: 1000.ms, color: Colors.orange),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 30),

          // --- RECENT MAINTENANCE LOGS ---
          Row(
            children: [
              Icon(Icons.build, color: Colors.orange),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.recentmaintenancestop, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ).animate().shimmer(duration: 1000.ms, color: Colors.blue),
          const Divider(),
          if (_recentMaintenance.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(AppLocalizations.of(context)!.nomaintenanceyet, style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentMaintenance.length,
              itemBuilder: (context, index) {
                final stop = _recentMaintenance[index];
                final String infoText = (stop['additionalInfo'] == null || stop['additionalInfo'].toString().trim().isEmpty) 
                          ? AppLocalizations.of(context)!.noadditionalinfo 
                          : stop['additionalInfo'].toString();
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${stop['occurrence']}'),
                    subtitle: Text('${stop['carName']} at ${stop['companyName']}\n${infoText}\nDate: ${stop['date']}'),
                    isThreeLine: true,
                    trailing: Text(
                      stop['totalPrice'] != null ? '\n€${stop['totalPrice'].toStringAsFixed(2)}' : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                    ).animate().shimmer(duration: 1000.ms, color: Colors.blue),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80), // Extra space at the bottom for the FAB
        ],
      ),
    );
  }
}