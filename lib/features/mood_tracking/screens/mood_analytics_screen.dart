import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class MoodAnalyticsScreen extends ConsumerWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mood Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Builder(
        builder: (context) {
          if (moodState.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: AppShimmer(width: double.infinity, height: 300, borderRadius: 24),
            );
          }
          if (moodState.error != null) {
            return Center(child: Text('Error: ${moodState.error}', style: const TextStyle(color: Colors.redAccent)));
          }
          
          final moods = moodState.moods;
          if (moods.length < 2) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Not enough data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Text('Log at least 2 moods to see your trends.', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }
          
          final sortedMoods = [...moods]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          List<FlSpot> spots = [];
          for (int i = 0; i < sortedMoods.length; i++) {
            spots.add(FlSpot(i.toDouble(), sortedMoods[i].moodScore.toDouble()));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Your Mood Trends', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('A timeline of your recent entries', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 32),
                Container(
                  height: 350,
                  padding: const EdgeInsets.only(right: 24, left: 12, top: 32, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final textStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
                              return LineTooltipItem('${touchedSpot.y.toInt()}/5', textStyle);
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true, 
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox.shrink();
                              return Text(value.toInt().toString(), style: TextStyle(color: Colors.grey[500], fontSize: 12));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < sortedMoods.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    DateFormat('MM/dd').format(sortedMoods[value.toInt()].timestamp), 
                                    style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w600)
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(color: Colors.grey[200], strokeWidth: 1);
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 1,
                      maxY: 5.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
