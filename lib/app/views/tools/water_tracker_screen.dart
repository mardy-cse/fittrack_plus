import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int waterGlasses = 0;
  final int dailyGoal = 8;

  void addGlass() {
    setState(() {
      waterGlasses++;
    });
    if (waterGlasses >= dailyGoal) {
      Get.snackbar(
        'Goal Achieved! 🎉',
        'Great job! You reached your daily water goal 💧',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void removeGlass() {
    if (waterGlasses > 0) {
      setState(() {
        waterGlasses--;
      });
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 120, color: Colors.white),
              const SizedBox(height: 32),
              Text(
                '$waterGlasses / $dailyGoal',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'glasses',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: getProgress(),
                backgroundColor: Colors.grey[300],
                color: const Color(0xFF4A90E2),
                minHeight: 20,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 16),
              Text(
                '${getProgressPercentage()}% of daily goal',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'remove_water_btn',
                    onPressed: removeGlass,
                    backgroundColor: const Color(0xFF4A90E2),
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const SizedBox(width: 32),
                  FloatingActionButton.extended(
                    heroTag: 'add_water_btn',
                    onPressed: addGlass,
                    backgroundColor: const Color(0xFF4A90E2),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Glass',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
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
                      '$dailyGoal glasses (2 liters)',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
