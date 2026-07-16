import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'database/database_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;
import 'l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}
  
  
class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  
  double _totalFuelCost = 0.0;
  double _totalMaintenanceCost = 0.0;
  double _totalDistance = 0.0;
  double _totalLiters = 0.0;
  
  List<FlSpot> _consumptionSpots = []; 
  List<String> _consumptionDates = [];
  List<FlSpot> _priceSpots = []; 
  List<String> _priceDates = [];

  Map<int, List<FlSpot>> _carConsumptionSpots = {};
  Map<int, List<FlSpot>> _carPriceSpots = {};



  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _calendarEvents = {};

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Convert the day being checked to our UTC format
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _calendarEvents[normalizedDay] ?? [];
  }

  List<Map<String, dynamic>> _carStats = [];
  Map<int, double> _carTotalDistance = {};
  Map<int, double> _carTotalCost = {};
    
  List<Map<String, dynamic>> _monthlySpendList = [];
  double _avgFuelMonthly = 0.0;
  double _avgMaintMonthly = 0.0;
  double _avgTotalMonthly = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final fuelData = await DatabaseHelper.instance.getFuelAggregates();
    final maintCost = await DatabaseHelper.instance.getTotalMaintenanceCost();
    // We will use allFuelStops directly for the chart so we don't need chartRawData anymore
    final carStats = await DatabaseHelper.instance.getStatsPerCar();
    final monthlyData = await DatabaseHelper.instance.getMonthlySpend();

    final db = await DatabaseHelper.instance.database;
    
    // Fetching Data with Names for the Calendar
    final allFuelStops = await db.rawQuery('''
      SELECT f.*, s.name as stationName 
      FROM fuel_stops f 
      LEFT JOIN stations s ON f.stationId = s.id
      ORDER BY f.date ASC
    ''');
    
    final allMaintStops = await db.rawQuery('''
      SELECT m.*, c.name as companyName 
      FROM maintenance_stops m 
      LEFT JOIN companies c ON m.companyId = c.id
      ORDER BY m.date ASC
    ''');

    // 1. --- PER-CAR CHARTS LOGIC ---
    Map<int, List<FlSpot>> tempCarCSpots = {};
    Map<int, List<FlSpot>> tempCarPSpots = {};
    Map<int, double> xIndexes = {};

    for (var row in allFuelStops) {
      int carId = row['carId'] as int;
      double l = (row['liters'] as num?)?.toDouble() ?? 0;
      double d = (row['distance'] as num?)?.toDouble() ?? 0;
      double p = (row['totalPrice'] as num?)?.toDouble() ?? 0;

      tempCarCSpots.putIfAbsent(carId, () => []);
      tempCarPSpots.putIfAbsent(carId, () => []);
      xIndexes.putIfAbsent(carId, () => 0.0);

      bool validEntry = false;
      if (l > 0 && d > 0) {
        tempCarCSpots[carId]!.add(FlSpot(xIndexes[carId]!, (l / d) * 100));
        validEntry = true;
      }
      if (l > 0 && p > 0) {
        tempCarPSpots[carId]!.add(FlSpot(xIndexes[carId]!, p / l));
        validEntry = true;
      }
      if (validEntry) {
        xIndexes[carId] = xIndexes[carId]! + 1;
      }
    }
    

    // 2. --- GLOBAL CHARTS & DATES LOGIC ---
    List<FlSpot> cSpots = [];
    List<FlSpot> pSpots = [];
    List<String> tempConsumptionDates = [];
    List<String> tempPriceDates = [];
    double globalXIndex = 0; 
    
    for (var row in allFuelStops) {
      double l = (row['liters'] as num?)?.toDouble() ?? 0;
      double d = (row['distance'] as num?)?.toDouble() ?? 0;
      double p = (row['totalPrice'] as num?)?.toDouble() ?? 0;
      
      // Extract and format the date for the X-Axis (e.g., "12.04" or "05.11")
      String formattedDate = "";
      if (row['date'] != null) {
        DateTime date = DateTime.parse(row['date'].toString());
        formattedDate = "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year.toString().padLeft(2, '0')}";
      }

      bool validGlobalEntry = false;
      if (l > 0 && d > 0) {
        cSpots.add(FlSpot(globalXIndex, (l / d) * 100));
        tempConsumptionDates.add(formattedDate);
        validGlobalEntry = true;
      }
      if (l > 0 && p > 0) {
        pSpots.add(FlSpot(globalXIndex, p / l));
        tempPriceDates.add(formattedDate);
        validGlobalEntry = true;
      }
      if (validGlobalEntry) {
        globalXIndex++;
      }
    }

    // 3. --- MONTHLY AVERAGES LOGIC ---
    double totalFuelMonthly = 0.0;
    double totalMaintMonthly = 0.0;
    
    for (var m in monthlyData) {
      totalFuelMonthly += (m['fuelSpend'] as num?)?.toDouble() ?? 0.0;
      totalMaintMonthly += (m['maintSpend'] as num?)?.toDouble() ?? 0.0;
    }
    
    double avgFuelMonthly = monthlyData.isNotEmpty ? totalFuelMonthly / monthlyData.length : 0.0;
    double avgMaintMonthly = monthlyData.isNotEmpty ? totalMaintMonthly / monthlyData.length : 0.0;
    double avgTotalMonthly = avgFuelMonthly + avgMaintMonthly;

    // 4. --- CALENDAR EVENTS LOGIC ---
    Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

    DateTime normalizeDate(String dateStr) {
      final parsed = DateTime.parse(dateStr);
      return DateTime.utc(parsed.year, parsed.month, parsed.day); 
    }

    for (var f in allFuelStops) {
      if (f['date'] != null) {
        final date = normalizeDate(f['date'].toString());
        tempEvents.putIfAbsent(date, () => []);
        tempEvents[date]!.add({...f, 'type': 'Fuel'}); 
      }
    }
    
    for (var m in allMaintStops) {
      if (m['date'] != null) {
        final date = normalizeDate(m['date'].toString());
        tempEvents.putIfAbsent(date, () => []);
        tempEvents[date]!.add({...m, 'type': 'Maintenance'});
      }
    }

    // 5. --- UPDATE THE UI STATE ---
    setState(() {
      _totalFuelCost = (fuelData['totalFuelCost'] as num?)?.toDouble() ?? 0.0;
      _totalDistance = (fuelData['totalDistance'] as num?)?.toDouble() ?? 0.0;
      _totalLiters = (fuelData['totalLiters'] as num?)?.toDouble() ?? 0.0;
      _totalMaintenanceCost = maintCost;
      
      _consumptionSpots = cSpots;
      _priceSpots = pSpots;
      
      // Save our safely extracted dates!
      _consumptionDates = tempConsumptionDates;
      _priceDates = tempPriceDates;
      
      _carStats = carStats;
      _monthlySpendList = monthlyData;
      _avgFuelMonthly = avgFuelMonthly;
      _avgMaintMonthly = avgMaintMonthly;
      _avgTotalMonthly = avgTotalMonthly;
      
      _carConsumptionSpots = tempCarCSpots;
      _carPriceSpots = tempCarPSpots;
      
      _calendarEvents = tempEvents;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalRunningCost = _totalFuelCost + _totalMaintenanceCost;
    double avgConsumption = _totalDistance > 0 && _totalLiters > 0 ? (_totalLiters / _totalDistance) * 100 : 0.0;
    double costPerKm = _totalDistance > 0 ? totalRunningCost / _totalDistance : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),


          // --- PER-CAR STATISTICS ---
          Text(AppLocalizations.of(context)!.performancepervehicle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          if (_carStats.isEmpty)
            Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text(AppLocalizations.of(context)!.nocarsavailable)))
          else
            ..._carStats.map((car) {
              // 1. Grab the specific ID for this car
              int carId = car['id'] ?? car['carId'] ?? 0; // Fallback to 0 if neither is available
              
              return Card(
                child: ExpansionTile(
                  title: Text(car['carName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    _buildListTile('Total Fuel Consumed', '${(car['totalLiters'] ?? 0).toStringAsFixed(1)} L'),
                    _buildListTile('Total Distance', '${(car['totalDistance'] ?? 0).toStringAsFixed(0)} km'),
                    _buildListTile('Total Fuel Spent', '€${(car['totalFuelCost'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Total Maint. Spent', '€${(car['totalMaintenanceCost'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Total Running Cost', '€${((car['totalFuelCost'] ?? 0) + (car['totalMaintenanceCost'] ?? 0)).toStringAsFixed(2)}'),
                    const Divider(),
                    
                    // ADD THIS NEW LINE:
                    Builder(builder: (context) {
                      double totalCost = (car['totalFuelCost'] ?? 0) + (car['totalMaintenanceCost'] ?? 0);
                      double totalDist = (car['totalDistance'] ?? 0);
                      double costPerKm = totalDist > 0 ? (totalCost / totalDist) : 0.0;
                      
                      return _buildListTile('Cost per KM', '€${costPerKm.toStringAsFixed(2)} / km');
                    }),

                    const Divider(),
                    _buildListTile('Avg. Price/L', '€${(car['avgPricePerLiter'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Avg. Cost/Stop', '€${(car['avgCostPerStop'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Avg. Liters/Stop', '${(car['avgLitersPerStop'] ?? 0).toStringAsFixed(1)} L'),
                    _buildListTile('Avg. Dist./Stop', '${(car['avgDistancePerStop'] ?? 0).toStringAsFixed(0)} km'),
                    _buildListTile('Avg. Consumption', '${(car['avgConsumption'] ?? 0).toStringAsFixed(2)} L/100km'),
                    const Divider(),
                    
                    // 2. Use carId instead of car here!
                    _buildMiniChart(
                      AppLocalizations.of(context)!.chartconsumption, 
                      _carConsumptionSpots[carId] ?? [], 
                      _consumptionDates,
                      Colors.blue
                    ),
                    _buildMiniChart(
                      AppLocalizations.of(context)!.chartpriceperliter, 
                      _carPriceSpots[carId] ?? [], 
                      _consumptionDates,
                      Colors.green
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }), // Replaced the => with {} and a return statement
          const SizedBox(height: 30),
          // --- HIGH LEVEL AGGREGATES ---
          Text(AppLocalizations.of(context)!.totalcosts, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.totalrunningcost, '€${totalRunningCost.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.teal)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.totaldistance, '${_totalDistance.toStringAsFixed(0)} km', Icons.add_road, Colors.indigo)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.fuelcosts, '€${_totalFuelCost.toStringAsFixed(2)}', Icons.ev_station, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.maintenance, '€${_totalMaintenanceCost.toStringAsFixed(2)}', Icons.build, Colors.orange)),
            ],
          ),

          const SizedBox(height: 30),
          // --- UPDATED: Efficiency Grid ---
          Text(AppLocalizations.of(context)!.efficiencyandaverages, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgconsumption, '${avgConsumption.toStringAsFixed(2)} L/100km', Icons.speed, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.costperkm, '€${costPerKm.toStringAsFixed(2)}', Icons.query_stats, Colors.purple)),
            ],
          ),
          const SizedBox(height: 30),
                    // New Split Average Cards
        
          // --- UPDATED: MONTHLY SPEND HORIZONTAL LIST ---
          Text(AppLocalizations.of(context)!.monthlyspend, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgmonthlyfuel, '€${_avgFuelMonthly.toStringAsFixed(2)}', Icons.ev_station, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgmonthlymaint, '€${_avgMaintMonthly.toStringAsFixed(2)}', Icons.build, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgmonthlytotal, '€${_avgTotalMonthly.toStringAsFixed(2)}', Icons.calendar_month, Colors.teal)),
            ],
          ),
          if (_monthlySpendList.isEmpty)
            Text(AppLocalizations.of(context)!.nodatayet, style: TextStyle(color: Colors.grey))
          else
            SizedBox(
              height: 130, // Increased height to fit three lines
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _monthlySpendList.length,
                itemBuilder: (context, index) {
                  final item = _monthlySpendList[index];
                  final monthYear = item['monthYear'] ?? 'Unknown';
                  final fuel = (item['fuelSpend'] as num?)?.toDouble() ?? 0.0;
                  final maint = (item['maintSpend'] as num?)?.toDouble() ?? 0.0;
                  final total = (item['totalSpend'] as num?)?.toDouble() ?? 0.0;
                  
                  return SizedBox(
                    width: 160, // Made it slightly wider
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(monthYear, style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            // New Breakdown Rows
                            Text('Fuel: €${fuel.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.blue)),
                            const SizedBox(height: 2),
                            Text('Maint: €${maint.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.orange)),
                            const Divider(height: 8),
                            Text('Total: €${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 30),
          //Yearly Spend area STILL NEEDS YEARLY DATA!!!!!!!!!!!!!!!!!
          Text(AppLocalizations.of(context)!.yearlyspend, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgyearlyfuel, '€${_avgFuelMonthly.toStringAsFixed(2)}', Icons.ev_station, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgyearlymaint, '€${_avgMaintMonthly.toStringAsFixed(2)}', Icons.build, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(AppLocalizations.of(context)!.avgyearlytotal, '€${_avgTotalMonthly.toStringAsFixed(2)}', Icons.calendar_today, Colors.teal)),
            ],
          ), 

          //NEEDS TO BE SWTICHTED TO YEARLY !!!!!!!!!!!!!!!!
          if (_monthlySpendList.isEmpty)
            Text(AppLocalizations.of(context)!.nodatayet, style: TextStyle(color: Colors.grey))
          else
            SizedBox(
              height: 130, // Increased height to fit three lines
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _monthlySpendList.length,
                itemBuilder: (context, index) {
                  final item = _monthlySpendList[index];
                  final monthYear = item['monthYear'] ?? 'Unknown';
                  final fuel = (item['fuelSpend'] as num?)?.toDouble() ?? 0.0;
                  final maint = (item['maintSpend'] as num?)?.toDouble() ?? 0.0;
                  final total = (item['totalSpend'] as num?)?.toDouble() ?? 0.0;
                  
                  return SizedBox(
                    width: 160, // Made it slightly wider
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(monthYear, style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            // New Breakdown Rows
                            Text('Fuel: €${fuel.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.blue)),
                            const SizedBox(height: 2),
                            Text('Maint: €${maint.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Colors.orange)),
                            const Divider(height: 8),
                            Text('Total: €${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 30),

          // --- NEW CALENDAR SECTION ---
          Padding(
            padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Text(AppLocalizations.of(context)!.expensecalender, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1), // Earliest possible date
                    lastDay: DateTime.utc(2050, 12, 31), // Latest possible date
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay, // This puts the dots under the days
                    startingDayOfWeek: StartingDayOfWeek.monday, // Optional: Starts week on Monday
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false, // Hides the "2 weeks" / "month" toggle button
                      titleCentered: true,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay; // update focused day as well
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox(); // No events, no dots

                        // Check the list of events for this specific day
                        bool hasFuel = events.any((event) => (event as Map)['type'] == 'Fuel');
                        bool hasMaint = events.any((event) => (event as Map)['type'] == 'Maintenance');

                        // Draw a row of colored dots at the bottom of the date cell
                        return Positioned(
                          bottom: 4, // Push it slightly up from the absolute bottom
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasFuel)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                                ),
                              if (hasMaint)
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    // ---------------------------------------------
                  ),
                  
                  // --- LIST OF EVENTS FOR SELECTED DAY ---
                  if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty) ...[
                    const Divider(),
                    ..._getEventsForDay(_selectedDay!).map((event) {
                      bool isFuel = event['type'] == 'Fuel';
                      return ListTile(
                        leading: Icon(
                          isFuel ? Icons.local_gas_station : Icons.build,
                          color: isFuel ? Colors.blue : Colors.orange,
                        ),
                        title: Text(isFuel ? AppLocalizations.of(context)!.fuelstop : AppLocalizations.of(context)!.maintenance),
                        subtitle: Text(isFuel 
                            ? 'Liters: ${(event['liters'] ?? 0).toStringAsFixed(1)} Distance: ${(event['distance'] ?? 0).toStringAsFixed(0)} km\nat ${event['stationName'] ?? 'Station Unknown'}'
                            : '${event['occurrence'] ?? 'Other'}\nat ${event['companyName'] ?? 'Company Unknown'}'),
                        trailing: Text(
                          '€${(event['totalPrice'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ] else if (_selectedDay != null) ...[
                     Padding(
                       padding: EdgeInsets.all(16.0),
                       child: Text(AppLocalizations.of(context)!.noexpensesonthisday, style: TextStyle(color: Colors.grey)),
                     )
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

         

          // --- CHARTS ---
          Text(AppLocalizations.of(context)!.chartconsumption, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          _buildChartCard(_consumptionSpots, _consumptionDates, Colors.blue),

          const SizedBox(height: 30),

          Text(AppLocalizations.of(context)!.chartpriceperliter, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          _buildChartCard(_priceSpots, _priceDates, Colors.green),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ); // <-- NEW ANIMATION
  }

  Widget _buildChartCard(List<FlSpot> spots, List<String> bottomLabels, Color lineColor) {
  if (spots.isEmpty || spots.length < 2) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.notenoughdatatodrawchart,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
  // DYNAMIC INTERVAL: 
  // We divide the total spots by 5. 
  // This forces the chart to show a maximum of ~5 date labels evenly spaced,
  // whether you have 10 data points or 200!
  double labelInterval = spots.length > 20 ? (spots.length / 5).ceilToDouble() : 1.0;

  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0, bottom: 8.0),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // This is the new bottom axis logic:
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: labelInterval,
                  reservedSize: 42, // Gives the text room to breathe 
                  getTitlesWidget: (value, meta) {
                    final int index = value.toInt();
                    // Grab the date string that matches the spot's X index 
                    if (index >= 0 && index < bottomLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0), // Adds the offset/space
                        child: Transform.rotate(
                          angle: -math.pi / 4, // -45 degrees
                          child: Text(
                            bottomLabels[index],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: lineColor,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: lineColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }

  Widget _buildListTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      visualDensity: VisualDensity.compact,
    );
  }
  Widget _buildMiniChart(String title, List<FlSpot> spots, List<String> bottomLabels, Color color) {
  if (spots.isEmpty || spots.length < 2) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.notenoughdatatodrawchart,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // DYNAMIC INTERVAL: 
  // We divide the total spots by 5. 
  // This forces the chart to show a maximum of ~5 date labels evenly spaced,
  // whether you have 10 data points or 200!
  double labelInterval = spots.length > 20 ? (spots.length / 5).ceilToDouble() : 1.0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 20),
        SizedBox(
          height: 140, // Increased slightly from 120 to fit the dates
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                
                // --- The New Bottom Axis ---
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36, 
                    interval: labelInterval, // This is the magic property!
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      
                      if (index >= 0 && index < bottomLabels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5, // Slight angle to fit better
                            child: Text(
                              bottomLabels[index],
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ), 
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: color,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false), // Set this to false if 200 dots look too messy
                  belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}