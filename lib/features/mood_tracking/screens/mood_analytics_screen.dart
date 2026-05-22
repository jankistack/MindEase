import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';

class MoodAnalyticsScreen extends ConsumerWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Analytics')),
      body: Builder(
        builder: (context) {
          if (moodState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (moodState.error != null) {
            return Center(child: Text('Error: ${moodState.error}'));
          }
          
          final moods = moodState.moods;
          if (moods.length < 2) {
            return const Center(child: Text('Not enough data for chart. Log more moods!'));
          }
          
          final sortedMoods = [...moods]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          List<FlSpot> spots = [];
          for (int i = 0; i < sortedMoods.length; i++) {
            spots.add(FlSpot(i.toDouble(), sortedMoods[i].moodScore.toDouble()));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Your Mood Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < sortedMoods.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(DateFormat('MM/dd').format(sortedMoods[value.toInt()].timestamp), style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: 6,
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
