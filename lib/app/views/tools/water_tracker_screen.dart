import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/water_intake_log.dart';
import '../../services/water_tracker_service.dart';
import '../../widgets/water_body_tracker.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int waterGlasses = 0;
  int dailyGoal = 8;
  final WaterTrackerService _service = WaterTrackerService();
  List<DateTime> timestamps = [];
  bool _isLoading = true;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _startDailyResetTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editDailyGoal() {
    TextEditingController goalController = TextEditingController(
      text: dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Daily Goal'),
        content: TextField(
          controller: goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Glasses per day',
            hintText: 'Enter number of glasses',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(goalController.text);
              if (newGoal != null && newGoal > 0) {
                setState(() {
                  dailyGoal = newGoal;
                });
                _saveData();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _startDailyResetTimer() {
    // Check every minute if date has changed
    Future.delayed(const Duration(minutes: 1), () {
      if (!mounted) return;

      final now = DateTime.now();
      final currentDateOnly = DateTime(now.year, now.month, now.day);
      final lastDateOnly = DateTime(
        _currentDate.year,
        _currentDate.month,
        _currentDate.day,
      );

      if (!_isSameDay(currentDateOnly, lastDateOnly)) {
        // New day detected, reset the tracker
        setState(() {
          waterGlasses = 0;
          timestamps = [];
          _currentDate = now;
          _isLoading = false;
        });
      }

      _startDailyResetTimer(); // Continue checking
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _loadTodayData() async {
    setState(() => _isLoading = true);

    final todayLog = await _service.getTodayLog();
    if (todayLog != null) {
      setState(() {
        waterGlasses = todayLog.glassesConsumed;
        timestamps = todayLog.timestamps;
        _currentDate = todayLog.date;
      });
    } else {
      // No data for today, ensure it's reset
      setState(() {
        waterGlasses = 0;
        timestamps = [];
        _currentDate = DateTime.now();
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    final log = WaterIntakeLog(
      date: DateTime.now(),
      glassesConsumed: waterGlasses,
      dailyGoal: dailyGoal,
      timestamps: timestamps,
    );
    await _service.saveTodayLog(log);
  }

  void addGlass() async {
    setState(() {
      waterGlasses++;
      timestamps.add(DateTime.now());
    });
    await _saveData();

    if (waterGlasses >= dailyGoal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Goal Achieved! 🎉 Great job! You reached your daily water goal 💧',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void removeGlass() async {
    if (waterGlasses > 0) {
      setState(() {
        waterGlasses--;
        if (timestamps.isNotEmpty) {
          timestamps.removeLast();
        }
      });
      await _saveData();
    }
  }

  double getProgress() {
    return waterGlasses / dailyGoal;
  }

  int getProgressPercentage() {
    return ((waterGlasses / dailyGoal) * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[50],
        appBar: AppBar(
          title: const Text('Water Tracker'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : const Color(0xFF64FFDA),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Water Tracker'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : const Color(0xFF64FFDA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.toNamed('/water-tracker-history');
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Animated Water Body Tracker
          Container(
            height: 450,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]!
                      : Colors.blue[50]!,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]!
                      : Colors.cyan[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: WaterBodyTracker(
                waterLevel: dailyGoal > 0
                    ? (waterGlasses / dailyGoal).clamp(0.0, 1.0)
                    : 0.0,
                width: 200,
                height: 400,
                bodyColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]!
                    : Colors.grey[700]!,
                waterColorStart: const Color(0xFF00BCD4),
                waterColorEnd: const Color(0xFF4DD0E1),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: getProgress(),
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF4A90E2),
                      minHeight: 20,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$waterGlasses/$dailyGoal glasses and ${getProgressPercentage()}% of daily goal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton.icon(
                              onPressed: removeGlass,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.remove, size: 20),
                              label: const Text(
                                'Remove',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: addGlass,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text(
                                'Add Glass',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    InkWell(
                      onTap: _editDailyGoal,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Goal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$dailyGoal glasses (${(dailyGoal * 0.25).toStringAsFixed(1)} liters)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.edit, color: Colors.cyan[700], size: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
