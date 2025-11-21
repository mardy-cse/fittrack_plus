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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Fitness Tools',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your health metrics',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                  _showBMICalculator(context);
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showBMICalculator(BuildContext context) {
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final RxString bmiResult = ''.obs;
    final RxString bmiCategory = ''.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BMI Calculator',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.height),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.monitor_weight),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => bmiResult.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your BMI',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bmiResult.value,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bmiCategory.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final height = double.tryParse(heightController.text);
                        final weight = double.tryParse(weightController.text);

                        if (height != null &&
                            weight != null &&
                            height > 0 &&
                            weight > 0) {
                          final heightInMeters = height / 100;
                          final bmi =
                              weight / (heightInMeters * heightInMeters);
                          bmiResult.value = bmi.toStringAsFixed(1);

                          if (bmi < 18.5) {
                            bmiCategory.value = 'Underweight';
                          } else if (bmi < 25) {
                            bmiCategory.value = 'Normal weight';
                          } else if (bmi < 30) {
                            bmiCategory.value = 'Overweight';
                          } else {
                            bmiCategory.value = 'Obese';
                          }
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please enter valid height and weight',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Calculate'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isRunning.value)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (isRunning.value) ...[
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
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      timer?.cancel();
                      Get.back();
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
