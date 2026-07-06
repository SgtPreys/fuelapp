import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database/database_helper.dart';
import 'package:table_calendar/table_calendar.dart';

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
  List<FlSpot> _priceSpots = []; 

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
    final chartRawData = await DatabaseHelper.instance.getFuelStopsForChart();
    final carStats = await DatabaseHelper.instance.getStatsPerCar();
    final monthlyData = await DatabaseHelper.instance.getMonthlySpend();

    final db = await DatabaseHelper.instance.database;
    final allFuelStops = await db.query('fuel_stops', orderBy: 'date ASC');
    final allMaintStops = await db.query('maintenance_stops');

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
    
    double totalFuelMonthly = 0.0;
    double totalMaintMonthly = 0.0;
    
    for (var m in monthlyData) {
      totalFuelMonthly += (m['fuelSpend'] as num?)?.toDouble() ?? 0.0;
      totalMaintMonthly += (m['maintSpend'] as num?)?.toDouble() ?? 0.0;
    }
    
    double avgFuelMonthly = monthlyData.isNotEmpty ? totalFuelMonthly / monthlyData.length : 0.0;
    double avgMaintMonthly = monthlyData.isNotEmpty ? totalMaintMonthly / monthlyData.length : 0.0;
    double avgTotalMonthly = avgFuelMonthly + avgMaintMonthly;

    List<FlSpot> cSpots = [];
    List<FlSpot> pSpots = [];
    double xIndex = 0; 
    
    for (var row in chartRawData) {
      double l = (row['liters'] as num?)?.toDouble() ?? 0;
      double d = (row['distance'] as num?)?.toDouble() ?? 0;
      double p = (row['totalPrice'] as num?)?.toDouble() ?? 0;
      
      bool validEntry = false;
      if (l > 0 && d > 0) {
        cSpots.add(FlSpot(xIndex, (l / d) * 100));
        validEntry = true;
      }
      if (l > 0 && p > 0) {
        pSpots.add(FlSpot(xIndex, p / l));
        validEntry = true;
      }
      if (validEntry) xIndex++;
    }

    // ADD THIS TO FETCH CALENDAR EVENTS:
    

    Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};

    // Helper function to convert SQLite date strings into pure 'Year-Month-Day' DateTimes
    DateTime normalizeDate(String dateStr) {
      final parsed = DateTime.parse(dateStr);
      // table_calendar works best with UTC dates for matching
      return DateTime.utc(parsed.year, parsed.month, parsed.day); 
    }

    // Add Fuel Stops
    for (var f in allFuelStops) {
      if (f['date'] != null) {
        final date = normalizeDate(f['date'].toString());
        tempEvents.putIfAbsent(date, () => []);
        // Copy the map and add a 'type' flag so we know what kind of stop it is
        tempEvents[date]!.add({...f, 'type': 'Fuel'}); 
      }
    }
    
    // Add Maintenance Stops
    for (var m in allMaintStops) {
      if (m['date'] != null) {
        final date = normalizeDate(m['date'].toString());
        tempEvents.putIfAbsent(date, () => []);
        tempEvents[date]!.add({...m, 'type': 'Maintenance'});
      }
    }

    setState(() {
      _totalFuelCost = (fuelData['totalFuelCost'] as num?)?.toDouble() ?? 0.0;
      _totalDistance = (fuelData['totalDistance'] as num?)?.toDouble() ?? 0.0;
      _totalLiters = (fuelData['totalLiters'] as num?)?.toDouble() ?? 0.0;
      _totalMaintenanceCost = maintCost;
      _consumptionSpots = cSpots;
      _priceSpots = pSpots;
      _carStats = carStats;
      _monthlySpendList = monthlyData;
      _avgFuelMonthly = avgFuelMonthly;
      _avgMaintMonthly = avgMaintMonthly;
      _avgTotalMonthly = avgTotalMonthly;
      _carStats = carStats;
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
          const Text("Performance per Vehicle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          if (_carStats.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No car data available yet.')))
          else
            ..._carStats.map((car) {
              // 1. Grab the specific ID for this car
              int carId = car['id'] ?? car['carId'] ?? 0; // Fallback to 0 if neither is available

              return Card(
                child: ExpansionTile(
                  title: Text(car['carName'] ?? 'Unknown Car', style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    _buildListTile('Total Fuel Consumed', '${(car['totalLiters'] ?? 0).toStringAsFixed(1)} L'),
                    _buildListTile('Total Distance', '${(car['totalDistance'] ?? 0).toStringAsFixed(0)} km'),
                    _buildListTile('Total Fuel Spent', '€${(car['totalFuelCost'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Total Maint. Spent', '€${(car['totalMaintenanceCost'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Total Running Cost', '€${((car['totalFuelCost'] ?? 0) + (car['totalMaintenanceCost'] ?? 0)).toStringAsFixed(2)}'),
                    const Divider(),
                    _buildListTile('Avg. Price/L', '€${(car['avgPricePerLiter'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Avg. Cost/Stop', '€${(car['avgCostPerStop'] ?? 0).toStringAsFixed(2)}'),
                    _buildListTile('Avg. Liters/Stop', '${(car['avgLitersPerStop'] ?? 0).toStringAsFixed(1)} L'),
                    _buildListTile('Avg. Dist./Stop', '${(car['avgDistancePerStop'] ?? 0).toStringAsFixed(0)} km'),
                    _buildListTile('Avg. Consumption', '${(car['avgConsumption'] ?? 0).toStringAsFixed(2)} L/100km'),
                    const Divider(),
                    
                    // 2. Use carId instead of car here!
                    _buildMiniChart(
                      'Consumption (L/100km)', 
                      _carConsumptionSpots[carId] ?? [], 
                      Colors.blue
                    ),
                    _buildMiniChart(
                      'Price per Liter (€)', 
                      _carPriceSpots[carId] ?? [], 
                      Colors.green
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            }), // Replaced the => with {} and a return statement
          const SizedBox(height: 10),
          // --- HIGH LEVEL AGGREGATES ---
          const Text('Total Costs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Running Cost', '€${totalRunningCost.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.teal)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Total Distance', '${_totalDistance.toStringAsFixed(0)} km', Icons.add_road, Colors.indigo)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard('Fuel Costs', '€${_totalFuelCost.toStringAsFixed(2)}', Icons.ev_station, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Maintenance', '€${_totalMaintenanceCost.toStringAsFixed(2)}', Icons.build, Colors.orange)),
            ],
          ),

          const SizedBox(height: 30),

          // --- UPDATED: MONTHLY SPEND HORIZONTAL LIST ---
          const Text('Monthly Spend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          if (_monthlySpendList.isEmpty)
            const Text('No data yet.', style: TextStyle(color: Colors.grey))
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
                            Text(monthYear, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
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
          const Padding(
            padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Text('Expense Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
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
                        title: Text(isFuel ? 'Fuel Stop' : 'Maintenance'),
                        subtitle: Text(isFuel 
                            ? '${(event['liters'] ?? 0).toStringAsFixed(1)} L at ${(event['distance'] ?? 0).toStringAsFixed(0)} km\n${event['stationName'] ?? 'Station Unknown'}'
                            : '${event['title'] ?? 'Service'}\n${event['companyName'] ?? 'Company Unknown'}'),
                        trailing: Text(
                          '€${(event['totalPrice'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ] else if (_selectedDay != null) ...[
                     const Padding(
                       padding: EdgeInsets.all(16.0),
                       child: Text('No expenses recorded on this day.', style: TextStyle(color: Colors.grey)),
                     )
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

         // --- UPDATED: Efficiency Grid ---
          const Text('Efficiency & Averages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard('Avg. Consumption', '${avgConsumption.toStringAsFixed(2)} L/100km', Icons.speed, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Cost per km', '€${costPerKm.toStringAsFixed(2)}', Icons.query_stats, Colors.purple)),
            ],
          ),
          const SizedBox(height: 10),
          // New Split Average Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Avg. Monthly Fuel', '€${_avgFuelMonthly.toStringAsFixed(2)}', Icons.ev_station, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Avg. Monthly Maint.', '€${_avgMaintMonthly.toStringAsFixed(2)}', Icons.build, Colors.orange)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard('Avg. Total Monthly', '€${_avgTotalMonthly.toStringAsFixed(2)}', Icons.calendar_month, Colors.teal)),
              const SizedBox(width: 10),
              Expanded(child: Container()), 
            ],
          ),

          const SizedBox(height: 30),

          // --- CHARTS ---
          const Text('Consumption Trend (L/100km)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          _buildChartCard(_consumptionSpots, Colors.green),

          const SizedBox(height: 30),

          const Text('Price per Liter Trend (€/L)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          _buildChartCard(_priceSpots, Colors.blue),

          const SizedBox(height: 30),

          

          const SizedBox(height: 80), 
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
    );
  }

  Widget _buildChartCard(List<FlSpot> spots, Color lineColor) {
    if (spots.isEmpty || spots.length < 2) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('Not enough data to draw chart yet. Log at least two stops!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0, left: 10.0, top: 24.0, bottom: 10.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), 
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true, 
                  color: lineColor, 
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha: 0.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      visualDensity: VisualDensity.compact,
    );
  }
  Widget _buildMiniChart(String title, List<FlSpot> spots, Color color) {
    if (spots.isEmpty) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          SizedBox(
            height: 120, // Smaller height for the card
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false), // Hide axes for a clean look
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
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