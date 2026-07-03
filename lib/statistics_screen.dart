import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database/database_helper.dart';
import 'package:flutter/services.dart';

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
  List<FlSpot> _priceSpots = []; // NEW: Holds the Price per Liter data

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  List<Map<String, dynamic>> _carStats = [];

  Future<void> _loadStatistics() async {
    final fuelData = await DatabaseHelper.instance.getFuelAggregates();
    final maintCost = await DatabaseHelper.instance.getTotalMaintenanceCost();
    final chartRawData = await DatabaseHelper.instance.getFuelStopsForChart();

    // --- Process data for BOTH charts ---
    List<FlSpot> cSpots = [];
    List<FlSpot> pSpots = [];
    double xIndex = 0; 
    
    for (var row in chartRawData) {
      double l = (row['liters'] as num?)?.toDouble() ?? 0;
      double d = (row['distance'] as num?)?.toDouble() ?? 0;
      double p = (row['totalPrice'] as num?)?.toDouble() ?? 0;
      
      bool validEntry = false;

      // 1. Calculate Consumption (L/100km)
      if (l > 0 && d > 0) {
        cSpots.add(FlSpot(xIndex, (l / d) * 100));
        validEntry = true;
      }
      
      // 2. Calculate Price Per Liter (€/L)
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
      _priceSpots = pSpots; // Save the price data to state
      _isLoading = false;
      _carStats = _carStats;
    _isLoading = false;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalRunningCost = _totalFuelCost + _totalMaintenanceCost;
    
    double avgConsumption = 0.0;
    if (_totalDistance > 0 && _totalLiters > 0) {
      avgConsumption = (_totalLiters / _totalDistance) * 100;
    }

    double costPerKm = 0.0;
    if (_totalDistance > 0) {
      costPerKm = totalRunningCost / _totalDistance;
    }

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

          // --- EFFICIENCY METRICS ---
          const Text('Efficiency & Averages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard('Avg. Consumption', '${avgConsumption.toStringAsFixed(2)} L/100km', Icons.speed, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Cost per km', '€${costPerKm.toStringAsFixed(2)}', Icons.query_stats, Colors.purple)),
            ],
          ),

          const SizedBox(height: 30),

          // --- CHART 1: CONSUMPTION ---
          const Text('Consumption Trend (L/100km)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          _buildChartCard(_consumptionSpots, Colors.green),

          const SizedBox(height: 30),

          // --- CHART 2: PRICE PER LITER ---
          const Text('Price per Liter Trend (€/L)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          _buildChartCard(_priceSpots, Colors.blue), // We pass the blue color here!

          const SizedBox(height: 80), 

          const Text('Performance per Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          ..._carStats.map((car) => Card(
            child: ExpansionTile(
              title: Text(car['carName']),
              children: [
                _buildListTile('Total Fuel Consumed', '${(car['totalLiters'] ?? 0).toStringAsFixed(1)} L'),
                _buildListTile('Total Distance', '${(car['totalDistance'] ?? 0).toStringAsFixed(0)} km'),
                _buildListTile('Total Fuel Spent', '€${(car['totalFuelCost'] ?? 0).toStringAsFixed(2)}'),
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

  Widget _buildListTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      visualDensity: VisualDensity.compact,
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

  // --- UPDATED: REUSABLE CHART WIDGET ---
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
                  color: lineColor, // Uses the color we pass in
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}