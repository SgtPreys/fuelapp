import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'car_form.dart';
import 'models/car.dart';
import 'station_form.dart';
import 'models/station.dart';
import 'company_form.dart';
import 'models/company.dart';
import 'fuel_form.dart'; // NEW
import 'models/fuel_stop.dart'; // NEW
import 'maintenance_form.dart'; // NEW
import 'models/maintenance_stop.dart'; // NEW
import 'package:flutter/services.dart';
import 'package:simple_rich_text/simple_rich_text.dart';

class ManageDataScreen extends StatefulWidget {
  const ManageDataScreen({super.key});

  @override
  ManageDataScreenState createState() => ManageDataScreenState();
}

class ManageDataScreenState extends State<ManageDataScreen> {
  List<Map<String, dynamic>> _cars = [];
  List<Map<String, dynamic>> _stations = [];
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _fuel = []; // NEW
  List<Map<String, dynamic>> _maintenance = []; // NEW
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final cars = await DatabaseHelper.instance.getAllCarsWithSpend();
    
    // --- UPDATED THESE TWO LINES ---
    final stations = await DatabaseHelper.instance.getAllStationsWithSpend(); 
    final companies = await DatabaseHelper.instance.getAllCompaniesWithSpend(); 
    
    final fuel = await DatabaseHelper.instance.getAllFuelStopsWithDetails(); 
    final maintenance = await DatabaseHelper.instance.getAllMaintenanceStopsWithDetails(); 

    setState(() {
      _cars = cars;
      _stations = stations;
      _companies = companies;
      _fuel = fuel;
      _maintenance = maintenance;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            // --- NEW ORDER: Fuel, Maintenance, Stations, Companies, Cars ---
            tabs: [
              Tab(icon: Icon(Icons.ev_station, color: Colors.blue), text: 'Fuel'),
              Tab(icon: Icon(Icons.build, color: Colors.orange), text: 'Maintenance'),
              Tab(icon: Icon(Icons.local_gas_station, color: Colors.teal), text: 'Stations'),
              Tab(icon: Icon(Icons.store, color: Colors.purple), text: 'Companies'),
              Tab(icon: Icon(Icons.directions_car, color: Colors.indigo), text: 'Cars'),
            ],
          ),
          Expanded(
            child: TabBarView(
              // --- MATCHING NEW ORDER ---
              children: [
                // 1. FUEL
                _fuel.isEmpty
                    ? const Center(child: Text('No fuel stops saved yet.'))
                    : ListView.builder(
                        itemCount: _fuel.length,
                        itemBuilder: (context, index) {
                          final fuelStop = _fuel[index];
                          final fuelObj = FuelStop.fromMap(fuelStop);
                                String consumptionStr = fuelObj.consumption != null 
                                    ? '${fuelObj.consumption!.toStringAsFixed(2)} L/100km' 
                                    : '-';
                                String priceLStr = fuelObj.pricePerLiter != null 
                                    ? '${fuelObj.pricePerLiter!.toStringAsFixed(2)} €/L' 
                                    : '-';
                          return ListTile(
                            leading: const Icon(Icons.ev_station, color: Colors.blue),
                            title: Text('${fuelStop['carName']} at ${fuelStop['stationName']}'),
                            subtitle: Builder(
                              builder: (context) {
                                return Text(
                                  'Date: ${fuelStop['date']} ${fuelStop['distance'] != null ? '\nDistance: ${fuelStop['distance']} km' : ''} ${fuelStop['liters'] != null ? '• Liters: ${fuelStop['liters']}' : ''}\n$consumptionStr • $priceLStr'
                                );
                              }
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              fuelStop['totalPrice'] != null ? '€${fuelStop['totalPrice']}\n$consumptionStr' : '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                              final selectedFuel = FuelStop.fromMap(fuelStop);
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => FuelForm(existingFuelStop: selectedFuel),
                              );
                              if (result == true) refreshData();
                            },
                          );
                        },
                      ),

                // 2. MAINTENANCE
                _maintenance.isEmpty
                    ? const Center(child: Text('No maintenance saved yet.'))
                    : ListView.builder(
                        itemCount: _maintenance.length,
                        itemBuilder: (context, index) {
                          final maintStop = _maintenance[index];
                          return ListTile(
                            leading: const Icon(Icons.build, color: Colors.orange),
                            title: Text('${maintStop['occurrence']}'),
                            subtitle: Text('${maintStop['carName']} at ${maintStop['companyName']}\nDate: ${maintStop['date']}'),
                            isThreeLine: true,
                            trailing: Text(maintStop['totalPrice'] != null ? '€${maintStop['totalPrice']}' : '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                              final selectedMaint = MaintenanceStop.fromMap(maintStop);
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => MaintenanceForm(existingMaintenanceStop: selectedMaint),
                              );
                              if (result == true) refreshData();
                            },
                          );
                        },
                      ),

                // 3. STATIONS
                _stations.isEmpty
                    ? const Center(child: Text('No gas stations saved yet.'))
                    : ListView.builder(
                        itemCount: _stations.length,
                        itemBuilder: (context, index) {
                          final station = _stations[index];
                          return ListTile(
                            leading: const Icon(Icons.local_gas_station, color: Colors.teal),
                            title: Text(station['name']),
                            subtitle: Text(station['location'] ?? 'Unknown Location'),
                            trailing: Text('Total Spent:\n${station['totalSpent'] != null ? '€${(station['totalSpent'] as num).toStringAsFixed(2)}' : '€0.00'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15),
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                              final selectedStation = Station.fromMap(station);
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => StationForm(existingStation: selectedStation),
                              );
                              if (result == true) refreshData();
                            },
                          );
                        },
                      ),

                // 4. COMPANIES
                _companies.isEmpty
                    ? const Center(child: Text('No companies saved yet.'))
                    : ListView.builder(
                        itemCount: _companies.length,
                        itemBuilder: (context, index) {
                          final company = _companies[index];
                          return ListTile(
                            leading: const Icon(Icons.store, color: Colors.purple),
                            title: Text(company['name']),
                            subtitle: Text('${company['location'] ?? 'Unknown location'}\n${company['contactPerson'] ?? 'Unknown contact person'}\n${company['telephone'] ?? 'Unknown phone number'}'),
                            trailing: Text('Total Spent:\n${company['totalSpent'] != null ? '€${(company['totalSpent'] as num).toStringAsFixed(2)}' : '€0.00'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 15),
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                              final selectedCompany = Company.fromMap(company);
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => CompanyForm(existingCompany: selectedCompany),
                              );
                              if (result == true) refreshData();
                            },
                          );
                        },
                      ),

                // 5. CARS
                _cars.isEmpty
                    ? const Center(child: Text('No cars saved yet.'))
                    : ListView.builder(
                        itemCount: _cars.length,
                        itemBuilder: (context, index) {
                          final carMap = _cars[index];
                          return ListTile(
                            leading: const Icon(Icons.directions_car, color: Colors.indigo),
                            title: Text(carMap['carName']),
                            subtitle: Text(
                              '${carMap['manufacturer'] ?? 'Unknown Manufacturer'} \n'
                              'Distance: ${carMap['totalDistance'] != null ? '${(carMap['totalDistance'] as num).toStringAsFixed(0)} km' : '0 km'} \n'
                              'Status: ${carMap['status'] ?? 'Unknown'}'
                            ),
                            trailing: Text('Total Spent:\n${carMap['totalSpent'] != null ? '€${(carMap['totalSpent'] as num).toStringAsFixed(2)}' : '€0.00'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 15),
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                              final selectedCar = Car.fromMap(carMap);
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => CarForm(existingCar: selectedCar),
                              );
                              if (result == true) refreshData();
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // Make sure you keep the very final closing bracket of the class!