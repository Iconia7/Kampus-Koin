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
    // 1. Initialize map for last 6 months
    final Map<int, double> monthlyTotals = {};
    final now = DateTime.now();
    
    // We strictly define the keys we expect (month integers) based on the time window
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i);
      monthlyTotals[monthDate.month] = 0.0; 
    }

    // 2. Filter and Sum Transactions
    for (var tx in transactions) {
      if (tx.status == 'completed' && 
          tx.transactionType == 'DEPOSIT' && 
          tx.transactionDate != null) {
        
        // Only include if within last ~180 days
        final diff = now.difference(tx.transactionDate!).inDays;
        if (diff < 185) { 
           final monthKey = tx.transactionDate!.month;
           // Only add if this month is in our window (handles edge cases)
           if (monthlyTotals.containsKey(monthKey)) {
             monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + (tx.amount ?? 0);
           }
        }
      }
    }

    // 3. Convert to FlSpots (x = index 0 to 5)
    List<FlSpot> spots = [];
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i);
      // X values: 0 (oldest) to 5 (current month)
      double xValue = (5 - i).toDouble(); 
      double yValue = monthlyTotals[monthDate.month] ?? 0.0;
      spots.add(FlSpot(xValue, yValue));
    }

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
    
    // Aesthetic headroom
    maxY = maxY == 0 ? 1000 : maxY * 1.25;

    return Container(
      height: 260, 
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Growth Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last 6 Months Deposits',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3, // ~3 horizontal lines
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[100],
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index > 5) return const SizedBox.shrink();
                        
                        final now = DateTime.now();
                        // 0 is oldest (5 months ago), 5 is now (0 months ago)
                        final date = DateTime(now.year, now.month - (5 - index));
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM').format(date),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E293B), // Dark slate
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          'KES ${NumberFormat.compact().format(touchedSpot.y)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: colorScheme.primary,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: colorScheme.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.2),
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