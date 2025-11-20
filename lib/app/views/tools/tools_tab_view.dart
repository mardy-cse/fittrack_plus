import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your health metrics',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
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
                  Get.snackbar(
                    'Workout Timer',
                    'Coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
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
                  Get.snackbar(
                    'Water Tracker',
                    'Stay hydrated! Feature coming soon.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                'Calorie Calculator',
                'Calculate daily calorie needs',
                Icons.restaurant,
                Colors.orange,
                () {
                  Get.snackbar(
                    'Calorie Calculator',
                    'Coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                'Body Measurements',
                'Track your body progress',
                Icons.straighten,
                Colors.purple,
                () {
                  Get.snackbar(
                    'Body Measurements',
                    'Coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildToolCard(
                'Workout Planner',
                'Plan your weekly workouts',
                Icons.calendar_month,
                Colors.red,
                () {
                  Get.snackbar(
                    'Workout Planner',
                    'Coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
              Obx(() => bmiResult.value.isNotEmpty
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
                  : const SizedBox.shrink()),
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
                          final bmi = weight / (heightInMeters * heightInMeters);
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
}
