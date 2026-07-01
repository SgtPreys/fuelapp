import 'package:flutter/material.dart';
import 'database/database_helper.dart'; // NEW: Import the database!

class ManageDataScreen extends StatefulWidget {
  const ManageDataScreen({super.key});

  @override
  State<ManageDataScreen> createState() => _ManageDataScreenState();
}

class _ManageDataScreenState extends State<ManageDataScreen> {
  // These lists will hold the data we get from the database
  List<Map<String, dynamic>> _cars = [];
  List<Map<String, dynamic>> _stations = [];
  List<Map<String, dynamic>> _companies = [];
  bool _isLoading = true; // Shows a loading spinner while fetching data

  // This runs automatically exactly once when the screen opens
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // --- NEW: The function that asks the database for all our items ---
  Future<void> _refreshData() async {
    final cars = await DatabaseHelper.instance.getAllCars();
    final stations = await DatabaseHelper.instance.getAllStations();
    final companies = await DatabaseHelper.instance.getAllCompanies();

    setState(() {
      _cars = cars;
      _stations = stations;
      _companies = companies;
      _isLoading = false; // Turn off the loading spinner
    });
  }

  @override
  Widget build(BuildContext context) {
    // If the database is still loading, show a little spinning circle
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Cars'),
              Tab(icon: Icon(Icons.local_gas_station), text: 'Stations'),
              Tab(icon: Icon(Icons.store), text: 'Companies'),
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
                          final car = _cars[index]; // Grab the specific car
                          return ListTile(
                            leading: const Icon(Icons.directions_car),
                            title: Text(car['carName']), // Use the real name!
                            subtitle: Text(car['manufacturer'] ?? 'Unknown Manufacturer'),
                            onTap: () {
                              // WE WILL ADD THE EDIT FUNCTION HERE NEXT!
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
                            onTap: () {
                              // WE WILL ADD THE EDIT FUNCTION HERE NEXT!
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
                            onTap: () {
                              // WE WILL ADD THE EDIT FUNCTION HERE NEXT!
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