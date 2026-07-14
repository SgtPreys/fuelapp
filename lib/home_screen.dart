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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final fuel = await DatabaseHelper.instance.getRecentFuelStops();
    final maintenance = await DatabaseHelper.instance.getRecentMaintenanceStops();

    setState(() {
      _recentFuel = fuel;
      _recentMaintenance = maintenance;
      _isLoading = false;
    });
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
                    title: Text('${stop['carName']} at ${stop['stationName']}'),
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
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${stop['occurrence']}'),
                    subtitle: Text('${stop['carName']} at ${stop['companyName']}\nDate: ${stop['date']}'),
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