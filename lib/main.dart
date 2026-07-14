import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // NEW: We imported the package!
import 'package:fuelapp/home_screen.dart';
import 'fuel_form.dart';
import 'maintenance_form.dart';
import 'manage_data_screen.dart';
import 'car_form.dart';
import 'station_form.dart';
import 'company_form.dart';
import 'statistics_screen.dart';
import 'package:flutter/services.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  // Add this line to ensure the engine is ready for the database!
  WidgetsFlutterBinding.ensureInitialized(); 
  //await NotificationService.instance.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const FuelApp(),
    ),
  );
}

class FuelApp extends StatefulWidget {
  const FuelApp({super.key});

  // 1. The magic function goes HERE, in the root app widget!
  static void setLocale(BuildContext context, Locale newLocale) {
    _FuelAppState? state = context.findAncestorStateOfType<_FuelAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<FuelApp> createState() => _FuelAppState();
}

class _FuelAppState extends State<FuelApp> {
  Locale? _locale;

  // 2. The setState function lives here where the state actually is
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'FuelApp',
      locale: _locale, // 3. Feeds the current locale to MaterialApp
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
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
        return const StatisticsScreen();
      case 2:
        return ManageDataScreen(key: _manageDataKey); // Your tabbed screen!
      case 3:
        return SettingsScreen(); // Your settings screen!
      default:
        return HomeScreen(key: _homeKey);
    }
  }

  // --- NEW: Helper function to change the FAB options based on screen ---
  List<SpeedDialChild> _getSpeedDialOptions(BuildContext context) {
    // 1. Define the two standard options we want everywhere
    final fuelOption = SpeedDialChild(
      child: const Icon(Icons.ev_station),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      label: 'Add Fuel Stop',
      onTap: () async {
        HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const FuelForm(),
        );
        if (result == true) {
          _homeKey.currentState?.refreshData();
          _manageDataKey.currentState?.refreshData();
          setState(() {});
        }
      },
    );

    final maintenanceOption = SpeedDialChild(
      child: const Icon(Icons.build),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      label: 'Add Maintenance',
      onTap: () async {
        HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const MaintenanceForm(),
        );
        if (result == true) {
          _homeKey.currentState?.refreshData();
          _manageDataKey.currentState?.refreshData();
          setState(() {});
        }
      },
    );

    // 2. If we are on the other tab than home we give all 5 options
    if (_selectedIndex == 1 & 2 & 3) {
      return [
        fuelOption,
        maintenanceOption,
        SpeedDialChild(
          child: const Icon(Icons.local_gas_station),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          label: 'Add Gas Station',
          onTap: () async {
            HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const StationForm(),
            );
            if (result == true) {
              _manageDataKey.currentState?.refreshData();
              setState(() {});
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.store),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          label: 'Add Company',
          onTap: () async {
            HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CompanyForm(),
            );
            if (result == true) {
              _manageDataKey.currentState?.refreshData();
              setState(() {});
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.directions_car),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          label: 'Add New Car',
          onTap: () async {
            HapticFeedback.lightImpact(); // <-- NEW HAPTIC BUMP
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CarForm(),
            );
            if (result == true) {
              _manageDataKey.currentState?.refreshData();
              setState(() {});
            }
          },
        ),
      ];
    }

    // 3. Otherwise (Home or Statistics), just return the standard 2
    return [
      fuelOption,
      maintenanceOption,
    ];
  }

// --- NEW: Helper widget for navigation icons with text ---
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.blue : Colors.grey;
    
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
        setState(() => _selectedIndex = index);
      },
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic App Bar Title
    List<String> titles = ['Home', 'Statistics', 'Manage Data', 'Settings & More'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex], style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28,color: Colors.blue),).animate().shimmer(duration: 1000.ms, color: Colors.orange),
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
        onOpen: (){
          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
        },
        onClose: (){
          HapticFeedback.mediumImpact(); // <-- NEW HAPTIC BUMP
        },
        tooltip: 'Add Data',
        elevation: 8.0,
        // The children now load dynamically from our helper function!
        children: _getSpeedDialOptions(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // --- UPDATED: The 4-Icon Balanced Navigation Bar ---
      // --- UPDATED: Navigation Bar with Labels ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left Side Group
            Row(
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                const SizedBox(width: 24), // Space between Home and Stats
                _buildNavItem(Icons.bar_chart, 'Stats', 1),
              ],
            ),

            const SizedBox(width: 48), // Space for the center FAB

            // Right Side Group
            Row(
              children: [
                _buildNavItem(Icons.category, 'Data', 2),
                const SizedBox(width: 24), // Space between Data and Settings
                _buildNavItem(Icons.settings, 'Settings', 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}