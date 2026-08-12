import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
//import 'package:simple_rich_text/simple_rich_text.dart';
import 'l10n/app_localizations.dart';

class ManageDataScreen extends StatefulWidget {
  const ManageDataScreen({super.key});

  @override
  ManageDataScreenState createState() => ManageDataScreenState();
}

class ManageDataScreenState extends State<ManageDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _cars = [];
  List<Map<String, dynamic>> _stations = [];
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _fuel = []; 
  List<Map<String, dynamic>> _maintenance = []; 

  List<Map<String, dynamic>> _displayedCars = [];
  List<Map<String, dynamic>> _displayedStations = [];
  List<Map<String, dynamic>> _displayedCompanies = [];
  List<Map<String, dynamic>> _displayedFuelStops = [];
  List<Map<String, dynamic>> _displayedMaintenance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final cars = await DatabaseHelper.instance.getAllCarsWithSpend();
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

      _displayedCars = List.from(_cars);
      _displayedStations = List.from(_stations);
      _displayedCompanies = List.from(_companies);
      _displayedFuelStops = List.from(_fuel);
      _displayedMaintenance = List.from(_maintenance);

      _runSearch(_searchQuery);
      _isLoading = false;
    });
  }

  void _runSearch(String query) {
    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        // If search is empty, display everything!
        _displayedCars = List.from(_cars);
        _displayedStations = List.from(_stations);
        _displayedCompanies = List.from(_companies);
        _displayedFuelStops = List.from(_fuel);
        _displayedMaintenance = List.from(_maintenance);
      } else {
        // Make query lowercase for case-insensitive searching
        final lowerQuery = query.toLowerCase();

        // Helper function to check if ANY value in a database row contains the text
        bool matchesSearch(Map<String, dynamic> row) {
          return row.values.any((value) => 
            value != null && value.toString().toLowerCase().contains(lowerQuery)
          );
        }

        // Filter all lists!
        _displayedCars = _cars.where(matchesSearch).toList();
        _displayedStations = _stations.where(matchesSearch).toList();
        _displayedCompanies = _companies.where(matchesSearch).toList();
        _displayedFuelStops = _fuel.where(matchesSearch).toList();
        _displayedMaintenance = _maintenance.where(matchesSearch).toList();
      }
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runSearch(value), // Triggers search on every keystroke
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searcheverything,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        _runSearch(''); // Clear search and show all
                      },
                    ) 
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            // --- NEW ORDER: Fuel, Maintenance, Stations, Companies, Cars ---
            tabs: [
              Tab(icon: Icon(Icons.ev_station, color: Colors.blue), text: AppLocalizations.of(context)!.fuel),
              Tab(icon: Icon(Icons.build, color: Colors.orange), text: AppLocalizations.of(context)!.maintenance),
              Tab(icon: Icon(Icons.local_gas_station, color: Colors.teal), text: AppLocalizations.of(context)!.stations),
              Tab(icon: Icon(Icons.store, color: Colors.purple), text: AppLocalizations.of(context)!.companies),
              Tab(icon: Icon(Icons.directions_car, color: Colors.indigo), text: AppLocalizations.of(context)!.cars),
            ],
          ),
          Expanded(
            child: TabBarView(
              // --- MATCHING NEW ORDER ---
              children: [
                // 1. FUEL
                _displayedFuelStops.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.nofuelstopsyet))
                    : ListView.builder(
                        itemCount: _displayedFuelStops.length,
                        itemBuilder: (context, index) {
                          
                          final fuelStop = _displayedFuelStops[index];
                          

                          final double totalPrice = (fuelStop['totalPrice'] as num?)?.toDouble() ?? 0.0;
                          final double distance = (fuelStop['distance'] as num?)?.toDouble() ?? 0.0;
                          double localCostPerKm = 0.0;
                          if (distance > 0) {
                            localCostPerKm = totalPrice / distance;
                          }

                          final fuelObj = FuelStop.fromMap(fuelStop);
                                String consumptionStr = fuelObj.consumption != null 
                                    ? '${fuelObj.consumption!.toStringAsFixed(2)} L/100km' 
                                    : '0.00 L/100km';
                                String priceLStr = fuelObj.pricePerLiter != null 
                                    ? '${fuelObj.pricePerLiter!.toStringAsFixed(2)} €/L' 
                                    : '0.00 €/L';
                                // return Dismissible(
                                //   // 1. UNIQUE KEY: Uses the ID of the fuel stop so Flutter doesn't get confused
                                //   key: ValueKey(fuelStop['id']),
                                  
                                //   // 2. SWIPE DIRECTION: Only allow swiping from right to left
                                //   direction: DismissDirection.endToStart,
                                  
                                //   // 3. BACKGROUND: The red trash can that reveals when swiping
                                //   background: Container(
                                //     color: Colors.red,
                                //     alignment: Alignment.centerRight,
                                //     padding: const EdgeInsets.only(right: 20.0),
                                //     child: const Icon(Icons.delete, color: Colors.white, size: 28),
                                //   ),
                                  
                                //   // 4. ACTION: What happens when the swipe is completed
                                //   onDismissed: (direction) async {
                                //     // Delete the record from your SQLite database
                                //     await DatabaseHelper.instance.deleteFuelStop(fuelStop['id']);
                                    
                                //     // Trigger a refresh so the lists update immediately
                                //     refreshData();
                                    
                                //     // Show a quick little confirmation banner at the bottom
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       const SnackBar(
                                //         content: Text('Fuel stop deleted'),
                                //         behavior: SnackBarBehavior.floating, // Makes it look clean and modern
                                //       ),
                                //     );
                                //   },
                                  
                                //   // 5. YOUR ORIGINAL UI: Your existing ListTile goes here untouched!
                                //   child: ListTile(
                                //     leading: const Icon(Icons.ev_station, color: Colors.blue),
                                //     title: Text('${fuelStop['carName']} at ${fuelStop['stationName'] ?? AppLocalizations.of(context)!.unknownstation}'),
                                //     subtitle: Builder(
                                //       builder: (context) {
                                //         return Text(
                                //           'Date: ${fuelStop['date']} ${fuelStop['distance'] != null ? '\nDistance: ${fuelStop['distance']} km' : ''} ${fuelStop['liters'] != null ? '• Liters: ${fuelStop['liters']}' : ''}\n$consumptionStr • $priceLStr• ${localCostPerKm.toStringAsFixed(2)} €/km'
                                //         );
                                //       }
                                //     ),
                                //     isThreeLine: true,
                                //     trailing: Text(
                                //       fuelStop['totalPrice'] != null ? '€${fuelStop['totalPrice']}\n$consumptionStr' : '',
                                //       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                                //     ),
                                //     onTap: () async {
                                //       HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
                                //       final selectedFuel = FuelStop.fromMap(fuelStop);
                                //       final result = await showModalBottomSheet(
                                //         context: context,
                                //         isScrollControlled: true,
                                //         builder: (context) => FuelForm(existingFuelStop: selectedFuel),
                                //       );
                                //       if (result == true) refreshData();
                                //     },
                                //   ),
                                // );
                          return ListTile(
                            leading: const Icon(Icons.ev_station, color: Colors.blue),
                            title: Text('${fuelStop['carName']} at ${fuelStop['stationName'] ?? AppLocalizations.of(context)!.unknownstation}'),
                            subtitle: Builder(
                              builder: (context) {
                                return Text(
                                  'Date: ${fuelStop['date']} ${fuelStop['distance'] != null ? '\nDistance: ${fuelStop['distance']} km' : ''} ${fuelStop['liters'] != null ? '• Liters: ${fuelStop['liters']}' : ''}\n$consumptionStr • $priceLStr• ${localCostPerKm.toStringAsFixed(2)} €/km'
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
                          // .animate(
                          //   effects: [
                          //     FadeEffect(duration: 250.ms, curve: Curves.easeOut),
                          //     SlideEffect(
                          //       begin: const Offset(0, 0.2), // Slide up slightly from the bottom
                          //       end: Offset.zero,
                          //       duration: 250.ms,
                          //       curve: Curves.easeOut,
                          //     ),
                          //   ],
                            
                          // );
                        },
                      ),

                // 2. MAINTENANCE
                _displayedMaintenance.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.nomaintenanceyet))
                    : ListView.builder(
                        itemCount: _displayedMaintenance.length,
                        itemBuilder: (context, index) {
                          final maintStop = _displayedMaintenance[index];
                          final String infoText = (maintStop['additionalInfo'] == null || maintStop['additionalInfo'].toString().trim().isEmpty) 
                                  ? AppLocalizations.of(context)!.noadditionalinfo 
                                  : maintStop['additionalInfo'].toString();
                          return ListTile(
                            leading: const Icon(Icons.build, color: Colors.orange),
                            title: Text('${maintStop['occurrence']}'),
                            subtitle: Text('${maintStop['carName']} at ${maintStop['companyName']}\n${infoText}\nDate: ${maintStop['date']}'),
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
                _displayedStations.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.nogasstations))
                    : ListView.builder(
                        itemCount: _displayedStations.length,
                        itemBuilder: (context, index) {
                          final station = _displayedStations[index];
                          final String displayLocation = (station['location'] != null && station['location'].toString().trim().isNotEmpty) 
                              ? station['location'] 
                              : AppLocalizations.of(context)!.unknownlocation;
                          final String infoText = (station['additionalInfo'] == null || station['additionalInfo'].toString().trim().isEmpty) 
                              ? AppLocalizations.of(context)!.noadditionalinfo 
                              : station['additionalInfo'].toString();
                          return ListTile(
                            leading: const Icon(Icons.local_gas_station, color: Colors.teal),
                            title: Text(station['name']),
                            subtitle: Text('$displayLocation\n${infoText}'),
                            isThreeLine: true,
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
                _displayedCompanies.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.nocompanyavailable))
                    : ListView.builder(
                        itemCount: _displayedCompanies.length,
                        itemBuilder: (context, index) {
                          final company = _displayedCompanies[index];
                          String displayLocation = (company['location'] != null && company['location'].toString().trim().isNotEmpty) 
                              ? company['location'] 
                              : AppLocalizations.of(context)!.unknownlocation;

                          String displayContact = (company['contactPerson'] != null && company['contactPerson'].toString().trim().isNotEmpty) 
                              ? company['contactPerson'] 
                              : AppLocalizations.of(context)!.unknowncontact;
                          
                          String displayTelephone = (company['telephone'] != null && company['telephone'].toString().trim().isNotEmpty) 
                              ? company['telephone'] 
                              : AppLocalizations.of(context)!.unknowntelephone;
                          String infoText = (company['additionalInfo'] == null || company['additionalInfo'].toString().trim().isEmpty) 
                              ? AppLocalizations.of(context)!.noadditionalinfo 
                              : company['additionalInfo'].toString();

                          return ListTile(
                            leading: const Icon(Icons.store, color: Colors.purple),
                            title: Text(company['name']),
                            subtitle: Text('$displayLocation\n$displayContact\n$displayTelephone\n${infoText}'),
                            isThreeLine: true,
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
                _displayedCars.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.nocarsavailable))
                    : ListView.builder(
                        itemCount: _displayedCars.length,
                        itemBuilder: (context, index) {
                          final carMap = _displayedCars[index];
                          String displayManufacturer = (carMap['manufacturer'] != null && carMap['manufacturer'].toString().trim().isNotEmpty) 
                              ? carMap['manufacturer'] 
                              : AppLocalizations.of(context)!.unknownmanufacturer;
                          return ListTile(
                            leading: const Icon(Icons.directions_car, color: Colors.indigo),
                            title: Text(carMap['carName']),
                            subtitle: Text(
                              '$displayManufacturer\n'
                              'Distance: ${carMap['totalDistance'] != null ? '${(carMap['totalDistance'] as num).toStringAsFixed(0)} km' : '0 km'} \n'
                              'Status: ${carMap['status'] ?? 'Unknown'}\n''${carMap['status'] != 'Sold' ? 'Next TÜV: ${carMap['nextTuev'] ?? 'Not set'}' : ''}'
                            ),
                            isThreeLine: true,
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