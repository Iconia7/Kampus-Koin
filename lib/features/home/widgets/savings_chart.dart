// lib/features/home/widgets/savings_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/transaction_model.dart';

class SavingsChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SavingsChart({super.key, required this.transactions});

  // Helper to process data
  List<FlSpot> _getChartData() {
    // 1. Initialize map for last 6 months (0.0 amount)
    final Map<int, double> monthlyTotals = {};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      // Use month index (1-12) as key
      monthlyTotals[month.month] = 0.0; 
    }

    // 2. Filter and Sum Transactions
    for (var tx in transactions) {
      if (tx.status == 'completed' && 
          tx.transactionType == 'DEPOSIT' && 
          tx.transactionDate != null) {
        
        // Only include if within last 6 months
        final diff = now.difference(tx.transactionDate!).inDays;
        if (diff < 180) { // Approx 6 months
           final monthKey = tx.transactionDate!.month;
           if (monthlyTotals.containsKey(monthKey)) {
             monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + (tx.amount ?? 0);
           }
        }
      }
    }

    // 3. Convert to FlSpots (x = index 0-5, y = amount)
    List<FlSpot> spots = [];
    int index = 0;
    // We iterate through the map we initialized to keep order
    monthlyTotals.forEach((key, value) {
      spots.add(FlSpot(index.toDouble(), value));
      index++;
    });

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getChartData();
    final colorScheme = Theme.of(context).colorScheme;

   double maxY = 0; 
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    
    // If total is 0, set a default so the chart doesn't crash
    // If total is > 0, add 20% headroom so the line doesn't hit the top edge
    maxY = maxY == 0 ? 100 : maxY * 1.2;

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Growth Analytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Icon(Icons.show_chart_rounded, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Show month names (e.g., "Nov")
                        final now = DateTime.now();
                        final monthIndex = (value.toInt());
                        // Calculate month back from current
                        final date = DateTime(now.year, now.month - (5 - monthIndex));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM').format(date),
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.3),
                          colorScheme.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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