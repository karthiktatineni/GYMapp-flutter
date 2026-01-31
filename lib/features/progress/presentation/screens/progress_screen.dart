import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Progress"), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConsistencyCard(),
            const SizedBox(height: 32),
            Text("Weight Lifted (kg)", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildLineChart(),
            const SizedBox(height: 32),
            Text("Body Weight (kg)", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildBarChart(),
            const SizedBox(height: 32),
            _buildStatsSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(value: 0.85, strokeWidth: 8, color: AppTheme.primaryGold, backgroundColor: Colors.black26),
              ),
              Text("85%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Consistency Score", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                const Text("You've been killing it! Keep up the momentum.", style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1000),
                FlSpot(1, 1200),
                FlSpot(2, 1100),
                FlSpot(3, 1500),
                FlSpot(4, 1800),
                FlSpot(5, 2200),
              ],
              isCurved: true,
              color: AppTheme.primaryGold,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryGold.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 75, color: AppTheme.primaryGold)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 74.5, color: AppTheme.primaryGold)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 74.2, color: AppTheme.primaryGold)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 73.8, color: AppTheme.primaryGold)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 73.5, color: AppTheme.primaryGold)]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        Expanded(child: _buildSummaryItem("Total Workouts", "42")),
        const SizedBox(width: 16),
        Expanded(child: _buildSummaryItem("Avg. Heart Rate", "145 bpm")),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
