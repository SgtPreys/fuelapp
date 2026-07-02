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
    final cars = await DatabaseHelper.instance.getAllCars();
    final stations = await DatabaseHelper.instance.getAllStations();
    final companies = await DatabaseHelper.instance.getAllCompanies();
    final fuel = await DatabaseHelper.instance.getAllFuelStopsWithDetails(); // NEW
    final maintenance = await DatabaseHelper.instance.getAllMaintenanceStopsWithDetails(); // NEW

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
      length: 5, // INCREASED TO 5 TABS
      child: Column(
        children: [
          const TabBar(
            isScrollable: true, // Lets you swipe the tabs left/right so they aren't squished!
            tabAlignment: TabAlignment.start,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Cars'),
              Tab(icon: Icon(Icons.local_gas_station), text: 'Stations'),
              Tab(icon: Icon(Icons.store), text: 'Companies'),
              Tab(icon: Icon(Icons.ev_station), text: 'Fuel'),
              Tab(icon: Icon(Icons.build), text: 'Maintenance'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // --- TAB 1: CARS ---
                _cars.isEmpty
                    ? const Center(child: Text('No cars saved yet.'))
                    : ListView.builder(
                        itemCount: _cars.length,
                        itemBuilder: (context, index) {
                          final carMap = _cars[index];
                          return ListTile(
                            leading: const Icon(Icons.directions_car),
                            title: Text(carMap['carName']),
                            subtitle: Text(carMap['manufacturer'] ?? 'Unknown Manufacturer'),
                            onTap: () async {
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

                // --- TAB 2: STATIONS ---
                _stations.isEmpty
                    ? const Center(child: Text('No gas stations saved yet.'))
                    : ListView.builder(
                        itemCount: _stations.length,
                        itemBuilder: (context, index) {
                          final station = _stations[index];
                          return ListTile(
                            leading: const Icon(Icons.local_gas_station),
                            title: Text(station['name']),
                            subtitle: Text(station['type'] ?? 'Unknown Type'),
                            onTap: () async {
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

                // --- TAB 3: COMPANIES ---
                _companies.isEmpty
                    ? const Center(child: Text('No companies saved yet.'))
                    : ListView.builder(
                        itemCount: _companies.length,
                        itemBuilder: (context, index) {
                          final company = _companies[index];
                          return ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(company['name']),
                            subtitle: Text(company['contactPerson'] ?? 'No contact person'),
                            onTap: () async {
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

                // --- TAB 4: FUEL (NEW) ---
                _fuel.isEmpty
                    ? const Center(child: Text('No fuel stops saved yet.'))
                    : ListView.builder(
                        itemCount: _fuel.length,
                        itemBuilder: (context, index) {
                          final fuelStop = _fuel[index];
                          return ListTile(
                            leading: const Icon(Icons.ev_station, color: Colors.blue),
                            title: Text('${fuelStop['carName']} @ ${fuelStop['stationName']}'),
                            // NEW: Multi-line subtitle with calculations
                            subtitle: Builder(
                              builder: (context) {
                                final fuelObj = FuelStop.fromMap(fuelStop);
                                
                                String consumptionStr = fuelObj.consumption != null 
                                    ? '${fuelObj.consumption!.toStringAsFixed(2)} L/100km' 
                                    : '-';
                                    
                                String priceLStr = fuelObj.pricePerLiter != null 
                                    ? '${fuelObj.pricePerLiter!.toStringAsFixed(2)} €/L' 
                                    : '-';

                                return Text('Date: ${fuelStop['date']} • €${fuelStop['totalPrice'] ?? '0.00'}\n$consumptionStr • $priceLStr');
                              }
                            ),
                            isThreeLine: true, // Room for the extra text
                            onTap: () async {
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

                // --- TAB 5: MAINTENANCE (NEW) ---
                _maintenance.isEmpty
                    ? const Center(child: Text('No maintenance saved yet.'))
                    : ListView.builder(
                        itemCount: _maintenance.length,
                        itemBuilder: (context, index) {
                          final maintStop = _maintenance[index];
                          return ListTile(
                            leading: const Icon(Icons.build, color: Colors.orange),
                            title: Text('${maintStop['occurrence']}'),
                            subtitle: Text('${maintStop['carName']} @ ${maintStop['companyName']}\nDate: ${maintStop['date']}'),
                            isThreeLine: true,
                            trailing: Text(maintStop['totalPrice'] != null ? '€${maintStop['totalPrice']}' : ''),
                            onTap: () async {
                              // Rebuild the MaintenanceStop object to pass to the form
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}