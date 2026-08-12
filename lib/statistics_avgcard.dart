import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:fluttertoast/fluttertoast.dart'; // For showing toast messages
import 'l10n/app_localizations.dart'; // For localization support
import 'package:intl/intl.dart'; // For date formatting
import 'database/database_helper.dart';

class StatisticsAvgCard extends StatefulWidget {

  final String selectedPeriod;
  final double avgFuelSpend;
  final double avgMaintSpend;
  final double totalAvgSpend;
  // If you need to pass your calculated averages into this card, 
  // you can add them here later (e.g., final double avgFuelSpend;)
  const StatisticsAvgCard({
    super.key, 
    required this.selectedPeriod, 
    required this.avgFuelSpend, 
    required this.avgMaintSpend, 
    required this.totalAvgSpend});

  @override
  State<StatisticsAvgCard> createState() => _StatisticsAvgCardState();
}

class _StatisticsAvgCardState extends State<StatisticsAvgCard> {
  
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _monthlySpendList = [];
  double _avgFuelMonthly = 0.0;
  double _avgMaintMonthly = 0.0;
  double _avgTotalMonthly = 0.0;
  List<Map<String, dynamic>> _yearlySpend = [];
  double _avgFuelYearly = 0.0;
  double _avgMaintYearly = 0.0;
  double _avgTotalYearly = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch monthly and yearly statistics from the database
    _monthlySpendList = await DatabaseHelper.instance.getMonthlySpend();
    _yearlySpend = await DatabaseHelper.instance.getYearlySpend();

    // Calculate averages for monthly statistics
    if (_monthlySpendList.isNotEmpty) {
      double totalFuel = 0.0;
      double totalMaint = 0.0;
      for (var monthData in _monthlySpendList) {
        totalFuel += monthData['fuel'] ?? 0.0;
        totalMaint += monthData['maintenance'] ?? 0.0;
      }
      _avgFuelMonthly = totalFuel / _monthlySpendList.length;
      _avgMaintMonthly = totalMaint / _monthlySpendList.length;
      _avgTotalMonthly = _avgFuelMonthly + _avgMaintMonthly;
    }

    // Calculate averages for yearly statistics
    if (_yearlySpend.isNotEmpty) {
      double totalFuelYearly = 0.0;
      double totalMaintYearly = 0.0;
      for (var yearData in _yearlySpend) {
        totalFuelYearly += yearData['fuel'] ?? 0.0;
        totalMaintYearly += yearData['maintenance'] ?? 0.0;
      }
      _avgFuelYearly = totalFuelYearly / _yearlySpend.length;
      _avgMaintYearly = totalMaintYearly / _yearlySpend.length;
      _avgTotalYearly = _avgFuelYearly + _avgMaintYearly;
    }

    setState(() {
      _isLoading = false;
    });
  }
 

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Adds padding around the edges, and respects the bottom safe area (like the iPhone home bar)
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20, 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Crucial for bottom sheets so they don't take up the whole screen
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'Data for ${widget.selectedPeriod.toString()}', // Display the selected period
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // --- YOUR AVERAGE STATS GO HERE ---
          // This is placeholder text. You will replace this with your actual variables later!
          _buildStatRow(Icons.local_gas_station, AppLocalizations.of(context)!.fuel, '€${widget.avgFuelSpend.toStringAsFixed(2)}', Colors.blue),
          const SizedBox(height: 12),
          _buildStatRow(Icons.build, AppLocalizations.of(context)!.maintenance, '€${widget.avgMaintSpend.toStringAsFixed(2)}', Colors.orange),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildStatRow(Icons.functions, AppLocalizations.of(context)!.totalcosts, '€${widget.totalAvgSpend.toStringAsFixed(2)}', Colors.teal),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // A tiny helper widget to make your stats look clean and uniform
  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}