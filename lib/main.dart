import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // NEW: We imported the package!
import 'fuel_form.dart';

void main() {
  runApp(const FuelApp());
}

class FuelApp extends StatelessWidget {
  const FuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, 
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Notice we deleted the _showAddMenu function completely!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Analytics and Recent Activity will go here!'),
      ),
      // --- UPDATED: The Animated Speed Dial ---
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close, // The + turns into an X when opened
        heroTag: 'fuel-app-speed-dial',
        renderOverlay: false,
        spacing: 10,
        spaceBetweenChildren: 10,
        tooltip: 'Log Data',
        elevation: 8.0,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.local_gas_station),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Add Fuel Stop',
            onTap: () {
              showModalBottomSheet(
              context: context,
              isScrollControlled: true, // This allows the sheet to resize for the keyboard
              builder: (context) => const FuelForm(),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.build),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: 'Add Maintenance Stop',
            onTap: () {
              // We will navigate to the maintenance form here later
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
              tooltip: 'Home',
            ),
            const SizedBox(width: 48), 
            IconButton(
              icon: const Icon(Icons.directions_car),
              onPressed: () {},
              tooltip: 'Manage Vehicles & Data',
            ),
          ],
        ),
      ),
    );
  }
}