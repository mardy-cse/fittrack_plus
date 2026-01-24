import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/water_intake_log.dart';
import '../../services/water_tracker_service.dart';

class WaterTrackerHistoryScreen extends StatefulWidget {
  const WaterTrackerHistoryScreen({super.key});

  @override
  State<WaterTrackerHistoryScreen> createState() => _WaterTrackerHistoryScreenState();
}

class _WaterTrackerHistoryScreenState extends State<WaterTrackerHistoryScreen> {
  final WaterTrackerService _service = WaterTrackerService();
  List<WaterIntakeLog> _logs = [];
  bool _isLoading = true;
  String _selectedPeriod = '7days'; // 7days, 30days
  
  double _avgConsumption = 0;
  int _currentStreak = 0;
  int _totalGlasses = 0;
  double _goalAchievementRate = 0;
  WaterIntakeLog? _bestDay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final days = _selectedPeriod == '7days' ? 7 : 30;
    
    final logs = await _service.getLogsForLastDays(days);
    final avg = await _service.getAverageConsumption(days: days);
    final streak = await _service.getCurrentStreak();
    final total = await _service.getTotalGlasses(days: days);
    final rate = await _service.getGoalAchievementRate(days: days);
    final best = await _service.getBestDay(days: days);
    
    setState(() {
      _logs = logs;
      _avgConsumption = avg;
      _currentStreak = streak;
      _totalGlasses = total;
      _goalAchievementRate = rate;
      _bestDay = best;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Water Intake History'),
        backgroundColor: isDark ? Colors.black : const Color(0xFF64FFDA),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    _buildChart(),
                    const SizedBox(height: 24),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '7days', label: Text('7 Days')),
              ButtonSegment(value: '30days', label: Text('30 Days')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _selectedPeriod = selected.first;
              });
              _loadData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Average',
                '${_avgConsumption.toStringAsFixed(1)} glasses',
                Icons.water_drop,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Current Streak',
                '$_currentStreak days',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Consumed',
                '$_totalGlasses glasses',
                Icons.analytics,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Goal Rate',
                '${_goalAchievementRate.toStringAsFixed(0)}%',
                Icons.emoji_events,
                Colors.purple,
              ),
            ),
          ],
        ),
        if (_bestDay != null) ...[
          const SizedBox(height: 12),
          _buildStatCard(
            'Best Day',
            '${_bestDay!.glassesConsumed} glasses on ${DateFormat('MMM dd').format(_bestDay!.date)}',
            Icons.star,
            Colors.amber,
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_logs.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No data available'),
        ),
      );
    }

    // Sort logs by date (oldest first for chart)
    final sortedLogs = List<WaterIntakeLog>.from(_logs);
    sortedLogs.sort((a, b) => a.date.compareTo(b.date));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Water Intake',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < sortedLogs.length) {
                          final log = sortedLogs[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MM/dd').format(log.date),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedLogs.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.glassesConsumed.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4A90E2),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF4A90E2),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                    ),
                  ),
                  // Goal line
                  LineChartBarData(
                    spots: List.generate(
                      sortedLogs.length,
                      (index) => FlSpot(index.toDouble(), 8.0),
                    ),
                    isCurved: false,
                    color: Colors.green.withOpacity(0.5),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
                minY: 0,
                maxY: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No history available'),
        ),
      );
    }

    // Sort logs by date (newest first)
    final sortedLogs = List<WaterIntakeLog>.from(_logs);
    sortedLogs.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedLogs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              final isToday = _isToday(log.date);
              final percentage = (log.glassesConsumed / log.dailyGoal * 100).toInt();
              
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: log.isGoalAchieved
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      log.isGoalAchieved ? Icons.check_circle : Icons.water_drop,
                      color: log.isGoalAchieved ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                title: Text(
                  isToday ? 'Today' : DateFormat('EEEE, MMM dd').format(log.date),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '${log.glassesConsumed} / ${log.dailyGoal} glasses ($percentage%)',
                ),
                trailing: log.isGoalAchieved
                    ? const Icon(Icons.emoji_events, color: Colors.amber)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
