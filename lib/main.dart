import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // NEW: We imported the package!
import 'package:fuelapp/home_screen.dart';
import 'fuel_form.dart';
import 'maintenance_form.dart';
import 'manage_data_screen.dart';
import 'car_form.dart';
import 'station_form.dart';
import 'company_form.dart';

void main() {
  // Add this line to ensure the engine is ready for the database!
  WidgetsFlutterBinding.ensureInitialized(); 
  
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
  // 0: Home, 1: Stats, 2: Manage Data, 3: Settings
  int _selectedIndex = 0;
  final GlobalKey<ManageDataScreenState> _manageDataKey = GlobalKey();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey();

  // --- NEW: Helper function to swap the screen content ---
  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(key: _homeKey);
      case 1:
        return const Center(child: Text('Detailed Statistics & Charts'));
      case 2:
        return ManageDataScreen(key: _manageDataKey); // Your tabbed screen!
      case 3:
        return const Center(child: Text('App Settings & Preferences'));
      default:
        return const Center(child: Text('Dashboard'));
    }
  }

  // --- NEW: Helper function to change the FAB options based on screen ---
  List<SpeedDialChild> _getSpeedDialOptions(BuildContext context) {
    if (_selectedIndex == 2) {
      // If we are on the Manage Data screen:
      return [
        SpeedDialChild(
          child: const Icon(Icons.directions_car),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          label: 'Add New Car',
          onTap: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CarForm(), 
            );
            // If we successfully added a car, force the screen to rebuild and fetch new data
            if (result == true) {
              _manageDataKey.currentState?.refreshData();
              setState(() {}); 
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.local_gas_station),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          label: 'Add New Station',
          onTap: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const StationForm(),
            );
            if (result == true) {
              _manageDataKey.currentState?.refreshData();
              setState(() {}); }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.store),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          label: 'Add New Company',
          onTap: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CompanyForm(),
            );
            if (result == true) {
              _manageDataKey.currentState?.refreshData();
              setState(() {}); }
          },
        ),
      ];
    } else {
      // Default: If we are on Home, Stats, or Settings:
      return [
        SpeedDialChild(
          child: const Icon(Icons.ev_station),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Add Fuel Stop',
          onTap: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const FuelForm(),
            );
            if (result == true){
              _homeKey.currentState?.refreshData();
              setState(() {});
            }
             
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.build),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'Add Maintenance',
          onTap: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const MaintenanceForm(),
            );
            if (result == true) {
              _homeKey.currentState?.refreshData();
              setState(() {});
            }
          },
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic App Bar Title
    List<String> titles = ['Dashboard', 'Statistics', 'Manage Data', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
      ),
      
      body: _getCurrentScreen(),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        heroTag: 'fuel-app-speed-dial',
        renderOverlay: false,
        spacing: 10,
        spaceBetweenChildren: 10,
        tooltip: 'Add Data',
        elevation: 8.0,
        // The children now load dynamically from our helper function!
        children: _getSpeedDialOptions(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // --- UPDATED: The 4-Icon Balanced Navigation Bar ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left Side
            IconButton(
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              icon: const Icon(Icons.home),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
              icon: const Icon(Icons.bar_chart),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            
            const SizedBox(width: 48), // Space for the center FAB
            
            // Right Side
            IconButton(
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
              icon: const Icon(Icons.category), // Using your new icon!
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            IconButton(
              color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
              icon: const Icon(Icons.settings),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}