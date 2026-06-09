import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../../meditation/providers/meditation_provider.dart';
import '../../mood_tracking/screens/mood_entry_screen.dart';
import '../../meditation/screens/meditation_home_screen.dart';
import '../../../shared/widgets/mindease_drawer.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF6A1B9A);
    const accentColor = Color(0xFF009688);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Wellness Analytics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          bottom: TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: 'Mood Trends', icon: Icon(Icons.mood_rounded)),
              Tab(text: 'Meditation', icon: Icon(Icons.spa_rounded)),
            ],
          ),
        ),
        drawer: const MindEaseDrawer(),
        body: TabBarView(
          children: [
            _buildMoodTab(context, ref, primaryColor),
            _buildMeditationTab(context, ref, accentColor, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTab(BuildContext context, WidgetRef ref, Color primaryColor) {
    final moodState = ref.watch(moodProvider);
    final moods = moodState.moods;

    if (moods.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart_rounded, size: 88, color: Colors.grey[300]),
              const SizedBox(height: 20),
              const Text(
                'More Data Needed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Log your mood at least twice to see beautiful trend lines and analytics.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodEntryScreen()),
                  );
                },
                icon: const Icon(Icons.add_reaction_rounded),
                label: const Text('Log Your Mood Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedMoods = [...moods]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedMoods.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedMoods[i].moodScore.toDouble()));
    }

    final scores = moods.map((e) => e.moodScore).toList();
    final highest = scores.reduce(math.max);
    final lowest = scores.reduce(math.min);
    final average = scores.reduce((a, b) => a + b) / scores.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood History Chart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Timeline of your emotional states',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),

          // Line Chart Container
          Container(
            height: 280,
            padding: const EdgeInsets.only(right: 24, left: 12, top: 24, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          'Score: ${touchedSpot.y.toInt()}/5',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4.5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: primaryColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.25),
                          primaryColor.withValues(alpha: 0.0),
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
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value < 1 || value > 5) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedMoods.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('M/d').format(sortedMoods[index].timestamp),
                              style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600),
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
                    return FlLine(color: Colors.grey[150] ?? Colors.grey[200]!, strokeWidth: 0.8);
                  },
                ),
                borderData: FlBorderData(show: false),
                minY: 1,
                maxY: 5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats Rows
          const Text(
            'Mood Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Average Mood',
                  average.toStringAsFixed(1),
                  _getMoodLabel(average.round()),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Highest Mood',
                  '$highest/5',
                  _getMoodLabel(highest),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Lowest Mood',
                  '$lowest/5',
                  _getMoodLabel(lowest),
                  Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Wellness Insights Card
          _buildInsightsCard(average, primaryColor),
        ],
      ),
    );
  }

  Widget _buildMeditationTab(BuildContext context, WidgetRef ref, Color accentColor, Color primaryColor) {
    final meditationState = ref.watch(meditationProgressProvider);
    final totalMinutes = meditationState.totalMinutes;
    const dailyGoal = 20;
    final progressRatio = (totalMinutes / dailyGoal).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Goal Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Consistency builds mindfulness',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),

          // Circular Ring Goal Indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progressRatio,
                        strokeWidth: 14,
                        color: accentColor,
                        backgroundColor: accentColor.withValues(alpha: 0.1),
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalMinutes',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: accentColor, height: 1.1),
                            ),
                            Text(
                              '/ $dailyGoal min',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  progressRatio >= 1.0 
                      ? 'Daily goal achieved! Sensational!' 
                      : 'You are ${(progressRatio * 100).toInt()}% of the way to your goal!',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Meditation Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.teal, size: 28),
                      const SizedBox(height: 12),
                      Text('$totalMinutes Min', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Mindful Time', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                      const SizedBox(height: 12),
                      Text(
                        totalMinutes > 0 ? '${(totalMinutes / 5).ceil()}' : '0',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text('Sessions Logged', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeditationHomeScreen()),
              );
            },
            icon: const Icon(Icons.self_improvement_rounded),
            label: const Text('Start Meditation Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(double avgMood, Color primaryColor) {
    String insightText;
    IconData icon;
    Color iconColor;

    if (avgMood < 3.0) {
      insightText = 'We noticed your recent mood scores have been lower. A short 3 or 5-minute breathing session (under the Meditation tab) can help calm the nervous system and clear stress.';
      icon = Icons.spa_rounded;
      iconColor = Colors.teal;
    } else if (avgMood >= 4.0) {
      insightText = 'Incredible! You have been holding a highly positive emotional state. Maintaining your daily logging and meditation routines will help anchor this positive baseline.';
      icon = Icons.insights_rounded;
      iconColor = Colors.green;
    } else {
      insightText = 'You are maintaining a balanced emotional baseline. Incorporating a short breathing exercise twice a day is a great way to boost focus and mental clarity.';
      icon = Icons.self_improvement_rounded;
      iconColor = primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mindfulness Insight',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  insightText,
                  style: TextStyle(fontSize: 13.5, color: Colors.grey[700], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(int score) {
    switch (score) {
      case 1:
        return 'Awful 😢';
      case 2:
        return 'Bad 😟';
      case 3:
        return 'Okay 😐';
      case 4:
        return 'Good 🙂';
      case 5:
        return 'Great 😁';
      default:
        return 'N/A';
    }
  }
}
