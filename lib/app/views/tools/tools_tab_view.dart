import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import 'water_tracker_screen.dart';
import 'calorie_calculator_screen.dart';
import 'body_measurements_screen.dart';
import 'workout_planner_screen.dart';

class ToolsTabView extends GetView<HomeController> {
  const ToolsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness Tools',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track your health metrics',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Tools Grid
            _buildToolCard(
              'Workout Timer',
              'Set intervals for exercises',
              Icons.timer,
              Colors.blue,
              () {
                _showWorkoutTimer(context);
              },
            ),

            const SizedBox(height: 16),

            _buildToolCard(
              'BMI Calculator',
              'Calculate your body mass index',
              Icons.calculate,
              Colors.green,
              () {
                Get.toNamed('/bmi');
              },
            ),

            const SizedBox(height: 16),

            _buildToolCard(
              'Water Tracker',
              'Monitor daily water intake',
              Icons.water_drop,
              Colors.cyan,
              () {
                Get.to(() => const WaterTrackerScreen());
              },
            ),

            const SizedBox(height: 16),

            _buildToolCard(
              'Calorie Calculator',
              'Calculate daily calorie needs',
              Icons.restaurant,
              Colors.orange,
              () {
                Get.to(() => const CalorieCalculatorScreen());
              },
            ),

            const SizedBox(height: 16),

            _buildToolCard(
              'Body Measurements',
              'Track your body progress',
              Icons.straighten,
              Colors.purple,
              () {
                Get.to(() => const BodyMeasurementsScreen());
              },
            ),

            const SizedBox(height: 16),

            _buildToolCard(
              'Workout Planner',
              'Plan your weekly workouts',
              Icons.calendar_month,
              Colors.red,
              () {
                Get.to(() => const WorkoutPlannerScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWorkoutTimer(BuildContext context) {
    final workSeconds = 30.obs;
    final restSeconds = 10.obs;
    final rounds = 5.obs;
    final isRunning = false.obs;
    final isPaused = false.obs;
    final currentRound = 1.obs;
    final currentPhase = 'work'.obs; // 'work' or 'rest'
    final timeRemaining = 30.obs;

    Timer? timer;

    void startTimer() {
      if (isRunning.value) return;

      isRunning.value = true;
      isPaused.value = false;
      currentPhase.value = 'work';
      timeRemaining.value = workSeconds.value;

      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (isPaused.value) return;

        if (timeRemaining.value > 0) {
          timeRemaining.value--;
        } else {
          // Switch phase
          if (currentPhase.value == 'work') {
            if (currentRound.value < rounds.value) {
              currentPhase.value = 'rest';
              timeRemaining.value = restSeconds.value;
            } else {
              // Workout complete
              t.cancel();
              isRunning.value = false;
              Get.snackbar(
                'Workout Complete!',
                'Great job! You completed ${rounds.value} rounds.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          } else {
            currentPhase.value = 'work';
            currentRound.value++;
            timeRemaining.value = workSeconds.value;
          }
        }
      });
    }

    void pauseTimer() {
      isPaused.value = !isPaused.value;
    }

    void stopTimer() {
      timer?.cancel();
      isRunning.value = false;
      isPaused.value = false;
      currentRound.value = 1;
      currentPhase.value = 'work';
      timeRemaining.value = workSeconds.value;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        title: const Text('Workout Timer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Settings (only show when not running)
              Obx(
                () => !isRunning.value
                    ? Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('Work Time (sec):')),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                    text: workSeconds.value.toString(),
                                  ),
                                  onChanged: (value) {
                                    workSeconds.value =
                                        int.tryParse(value) ?? 30;
                                    timeRemaining.value = workSeconds.value;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(child: Text('Rest Time (sec):')),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                    text: restSeconds.value.toString(),
                                  ),
                                  onChanged: (value) {
                                    restSeconds.value =
                                        int.tryParse(value) ?? 10;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(child: Text('Rounds:')),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                    text: rounds.value.toString(),
                                  ),
                                  onChanged: (value) {
                                    rounds.value = int.tryParse(value) ?? 5;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox(),
              ),

              // Timer Display
              Obx(
                () => Column(
                  children: [
                    // Phase indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: currentPhase.value == 'work'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentPhase.value == 'work' ? 'WORK' : 'REST',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Timer
                    Text(
                      '${(timeRemaining.value ~/ 60).toString().padLeft(2, '0')}:${(timeRemaining.value % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Round counter
                    Text(
                      'Round ${currentRound.value} / ${rounds.value}',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isRunning.value)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (isRunning.value) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pauseTimer,
                          icon: Icon(
                            isPaused.value ? Icons.play_arrow : Icons.pause,
                          ),
                          label: Text(isPaused.value ? 'Resume' : 'Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: stopTimer,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
