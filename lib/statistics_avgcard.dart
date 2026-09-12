import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'l10n/app_localizations.dart'; 

class StatisticsAvgCard extends StatelessWidget {
  final String selectedPeriod;
  final double avgFuelSpend;
  final double avgMaintSpend;
  final double avgCarSpend;
  final double avgCarIncome;
  final double totalAvgSpend;
  
  // New usage & efficiency metrics
  final double avgDistance;
  final double avgLiters;
  final double avgConsumption;
  final double avgPricePerLiter;
  final double avgLitersPerEuro;
  final double avgCostPerKm;

  const StatisticsAvgCard({
    super.key, 
    required this.selectedPeriod, 
    required this.avgFuelSpend, 
    required this.avgMaintSpend, 
    required this.avgCarSpend, 
    required this.avgCarIncome,
    required this.totalAvgSpend,
    required this.avgDistance,
    required this.avgLiters,
    required this.avgConsumption,
    required this.avgPricePerLiter,
    required this.avgLitersPerEuro,
    required this.avgCostPerKm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20, 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Data for $selectedPeriod', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ).animate().shimmer(duration: 1000.ms, color: Colors.orange),
          ),
          const SizedBox(height: 24),

          // --- ROW 1: Financials ---
          Row(
            children: [
              Expanded(child: _buildGridItem(Icons.local_gas_station, AppLocalizations.of(context)!.fuel ?? 'Fuel', '€${avgFuelSpend.toStringAsFixed(2)}', Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildGridItem(Icons.build, AppLocalizations.of(context)!.maintenance ?? 'Maint.', '€${avgMaintSpend.toStringAsFixed(2)}', Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),

          

          // --- ROW 2: Usage ---
          Row(
            children: [
              Expanded(child: _buildGridItem(Icons.water_drop, AppLocalizations.of(context)!.consumed, '${avgLiters.toStringAsFixed(1)} L', Colors.lightBlue)),
              const SizedBox(width: 16),
              Expanded(child: _buildGridItem(Icons.route, AppLocalizations.of(context)!.distance, '${avgDistance.toStringAsFixed(0)} km', Colors.indigo)),
              
              
            ],
          ),
          const SizedBox(height: 16),

          // --- ROW 3: Efficiency ---
          Row(
            children: [
              Expanded(child: _buildGridItem(Icons.local_drink, AppLocalizations.of(context)!.priceperliter, '€${avgPricePerLiter.toStringAsFixed(2)}/L', Colors.lightBlue)),
              //Expanded(child: _buildGridItem(Icons.local_drink, AppLocalizations.of(context)!.fuelvalue, '${avgLitersPerEuro.toStringAsFixed(2)} L/€', Colors.lightBlue)),
              const SizedBox(width: 16),
              Expanded(child: _buildGridItem(Icons.speed, AppLocalizations.of(context)!.efficiency, '${avgConsumption.toStringAsFixed(2)} L/100', Colors.green)),
              //const SizedBox(width: 8),
              
              
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // --- ROW 2: Vehicle Capital (Purchases & Sales) ---
          Row(
            children: [
              Expanded(child: _buildGridItem(Icons.directions_car, AppLocalizations.of(context)!.carspend ?? 'Car Spend', '€${avgCarSpend.toStringAsFixed(2)}', Colors.pink)),
              const SizedBox(width: 16),
              Expanded(child: _buildGridItem(Icons.payments, AppLocalizations.of(context)!.carincome ?? 'Car Income', '€${avgCarIncome.toStringAsFixed(2)}', Colors.lightGreen)),
            ],
          ),
          const SizedBox(height: 12),

          const Divider(),
          const SizedBox(height: 12),

          // --- ROW 4: Totals & Value ---
          Row(
            children: [
              Expanded(child: _buildGridItem(Icons.functions, AppLocalizations.of(context)!.totalcosts ?? 'Total', '€${totalAvgSpend.toStringAsFixed(2)}', Colors.redAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildGridItem(Icons.euro, AppLocalizations.of(context)!.costperkm ?? 'Cost per km', '€${avgCostPerKm.toStringAsFixed(2)}', Colors.brown)),
              
              
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Updated helper widget for a compact, vertical grid-style layout
  Widget _buildGridItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}