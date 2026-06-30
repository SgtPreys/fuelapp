import 'package:flutter/material.dart';

class ManageDataScreen extends StatelessWidget {
  const ManageDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController automatically handles the swiping and tapping of tabs!
    return DefaultTabController(
      length: 3, // We have 3 tabs
      child: Column(
        children: [
          // The Tab Menu
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
          // The actual content of the tabs
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1 Content: Cars
                ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.directions_car),
                      title: Text('Daily Driver'),
                      subtitle: Text('Volkswagen Golf'),
                    ),
                    ListTile(
                      leading: Icon(Icons.directions_car),
                      title: Text('Weekend Car'),
                      subtitle: Text('Mazda MX-5'),
                    ),
                  ],
                ),
                // Tab 2 Content: Stations
                ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.local_gas_station),
                      title: Text('Shell'),
                      subtitle: Text('Main Street'),
                    ),
                  ],
                ),
                // Tab 3 Content: Companies
                ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.store),
                      title: Text('Local Mechanic'),
                      subtitle: Text('Maintenance & Repairs'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}