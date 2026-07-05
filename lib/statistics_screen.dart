import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database/database_helper.dart';

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
    
    // --- UPDATED: Calculate Averages Split by Category ---
    final monthlyData = await DatabaseHelper.instance.getMonthlySpend();
    
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
          const Text('Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // --- HIGH LEVEL AGGREGATES ---
          const Text('Total Costs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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
          const Text('Monthly Spend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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

         // --- UPDATED: Efficiency Grid ---
          const Text('Efficiency & Averages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
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
          const Text('Consumption Trend (L/100km)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          _buildChartCard(_consumptionSpots, Colors.green),

          const SizedBox(height: 30),

          const Text('Price per Liter Trend (€/L)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          _buildChartCard(_priceSpots, Colors.blue),

          const SizedBox(height: 30),

          // --- PER-CAR STATISTICS ---
          const Text('Performance per Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          if (_carStats.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No car data available yet.')))
          else
            ..._carStats.map((car) => Card(
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
                ],
              ),
            )),

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
}