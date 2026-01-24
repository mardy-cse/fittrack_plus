import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/calorie_goal.dart';
import '../../models/daily_calorie_log.dart';
import '../../services/calorie_goal_service.dart';

class CalorieGoalTrackingScreen extends StatefulWidget {
  final int dailyCalories;

  const CalorieGoalTrackingScreen({super.key, required this.dailyCalories});

  @override
  State<CalorieGoalTrackingScreen> createState() =>
      _CalorieGoalTrackingScreenState();
}

class _CalorieGoalTrackingScreenState extends State<CalorieGoalTrackingScreen> {
  final _service = Get.put(CalorieGoalService());
  final currentWeightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final timelineController = TextEditingController(text: '12');
  final dailyWeightController = TextEditingController();

  String selectedGoalType = 'lose';
  CalorieGoal? activeGoal;
  List<DailyCalorieLog> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    activeGoal = await _service.loadGoal();
    logs = await _service.loadLogs();

    if (activeGoal != null) {
      currentWeightController.text = activeGoal!.currentWeight.toStringAsFixed(
        1,
      );
      targetWeightController.text = activeGoal!.targetWeight.toStringAsFixed(1);
      timelineController.text = activeGoal!.timelineWeeks.toString();
      selectedGoalType = activeGoal!.goalType;
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveGoal() async {
    final currentWeight = double.tryParse(currentWeightController.text);
    final targetWeight = double.tryParse(targetWeightController.text);
    final timeline = int.tryParse(timelineController.text);

    if (currentWeight == null || targetWeight == null || timeline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (currentWeight == targetWeight && selectedGoalType != 'maintain') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current and target weight cannot be same'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final goal = CalorieGoal(
      startDate: DateTime.now(),
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      goalType: selectedGoalType,
      timelineWeeks: timeline,
      dailyCalorieTarget: widget.dailyCalories,
      targetDate: DateTime.now().add(Duration(days: timeline * 7)),
    );

    await _service.saveGoal(goal);

    // Save today's weight as a daily log entry for progress tracking
    final todayLog = DailyCalorieLog(
      date: DateTime.now(),
      weight: currentWeight,
      caloriesConsumed: 0,
      caloriesBurned: 0,
      notes: 'Goal ${activeGoal == null ? "created" : "updated"}',
    );
    await _service.saveDailyLog(todayLog);

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal saved successfully! ✓'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    currentWeightController.dispose();
    targetWeightController.dispose();
    timelineController.dispose();
    dailyWeightController.dispose();
    super.dispose();
  }

  Future<void> _updateDailyWeight() async {
    final weight = double.tryParse(dailyWeightController.text);

    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final todayLog = DailyCalorieLog(
      date: DateTime.now(),
      weight: weight,
      caloriesConsumed: 0,
      caloriesBurned: 0,
      notes: 'Daily weight update',
    );

    await _service.saveDailyLog(todayLog);
    await _loadData();
    dailyWeightController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight updated! ✓'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Goal Tracking'),
        backgroundColor: isDark ? Colors.black : const Color(0xFFFFA726),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activeGoal != null) ...[
              _buildProgressCard(),
              const SizedBox(height: 16),
              _buildWeightChart(),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildDailyWeightUpdate(),
              const SizedBox(height: 16),
            ],
            _buildGoalForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    if (activeGoal == null) return const SizedBox.shrink();

    final daysElapsed = DateTime.now().difference(activeGoal!.startDate).inDays;
    final totalDays = activeGoal!.timelineWeeks * 7;

    final weightToChange = activeGoal!.weightToChange.abs();
    final todayLog = logs.firstWhereOrNull((log) {
      final today = DateTime.now();
      return log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day;
    });

    final currentWeight = todayLog?.weight ?? activeGoal!.currentWeight;
    final weightChanged = (activeGoal!.currentWeight - currentWeight).abs();
    final weightProgress = weightToChange > 0
        ? (weightChanged / weightToChange * 100).clamp(0.0, 100.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: activeGoal!.isLosing
              ? [Colors.orange, Colors.deepOrange]
              : activeGoal!.isGaining
              ? [Colors.green, Colors.teal]
              : [Colors.blue, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeGoal!.isLosing
                        ? '🎯 Weight Loss Goal'
                        : activeGoal!.isGaining
                        ? '💪 Weight Gain Goal'
                        : '⚖️ Maintain Weight',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activeGoal!.currentWeight.toStringAsFixed(1)} → ${activeGoal!.targetWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${weightProgress.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: weightProgress / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem('⏱️ Days', '$daysElapsed / $totalDays'),
              _buildProgressItem(
                '⚖️ Weight Change',
                '${weightChanged.toStringAsFixed(1)} kg',
              ),
              _buildProgressItem(
                '🎯 Remaining',
                '${(weightToChange - weightChanged).toStringAsFixed(1)} kg',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart() {
    if (logs.isEmpty) return const SizedBox.shrink();

    final weightLogs = logs
        .where((log) => log.weight != null)
        .take(14)
        .toList()
        .reversed
        .toList();

    if (weightLogs.isEmpty) return const SizedBox.shrink();

    final weights = weightLogs.map((log) => log.weight!).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final padding = range > 0 ? range * 0.2 : 1.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Weight Progress (Last 14 Days)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: range > 0 ? range / 4 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[700]!, strokeWidth: 0.5);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
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
                      interval: weightLogs.length > 7 ? 2 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= weightLogs.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM d').format(weightLogs[index].date),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: range > 0 ? range / 4 : 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (weightLogs.length - 1).toDouble(),
                minY: minWeight - padding,
                maxY: maxWeight + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: weightLogs
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.weight!))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFFFFA726),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFFFFA726),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFFA726).withOpacity(0.2),
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

  Widget _buildQuickStats() {
    if (activeGoal == null) return const SizedBox.shrink();

    final daysRemaining = activeGoal!.targetDate != null
        ? activeGoal!.targetDate!.difference(DateTime.now()).inDays
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Target Calories',
            '${activeGoal!.dailyCalorieTarget}',
            'kcal/day',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Days Remaining',
            '$daysRemaining',
            'days',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeGoal == null ? 'Set Your Goal' : 'Update Goal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedGoalType,
            decoration: const InputDecoration(
              labelText: 'Goal Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            items: const [
              DropdownMenuItem(value: 'lose', child: Text('Lose Weight')),
              DropdownMenuItem(value: 'gain', child: Text('Gain Weight')),
              DropdownMenuItem(
                value: 'maintain',
                child: Text('Maintain Weight'),
              ),
            ],
            onChanged: (value) {
              setState(() => selectedGoalType = value!);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: currentWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Current Weight (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: targetWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Weight (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.track_changes),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: timelineController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Timeline (weeks)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.save),
              label: Text(
                activeGoal == null ? 'Set Goal' : 'Update Goal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyWeightUpdate() {
    if (activeGoal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50C878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.scale, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Update Today\'s Weight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dailyWeightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter weight (kg)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.monitor_weight,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _updateDailyWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text(
                  'Update',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
