import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class CalorieCalculatorScreen extends StatelessWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final user = controller.userProfile.value;

    // Auto-fill from profile
    final ageController = TextEditingController(
      text: user?.age?.toString() ?? '',
    );
    final weightController = TextEditingController(
      text: user?.weight?.toInt().toString() ?? '',
    );
    final heightController = TextEditingController(
      text: user?.height?.toInt().toString() ?? '',
    );
    final gender = (user?.gender?.toLowerCase() ?? 'male').obs;
    final activityLevel = 'moderate'.obs;
    final calorieResult = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.restaurant, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Calculate your daily calorie needs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: gender.value,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (value) => gender.value = value!,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: activityLevel.value,
                decoration: const InputDecoration(
                  labelText: 'Activity Level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_run),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'sedentary',
                    child: Text('Sedentary (little/no exercise)'),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text('Light (1-3 days/week)'),
                  ),
                  DropdownMenuItem(
                    value: 'moderate',
                    child: Text('Moderate (3-5 days/week)'),
                  ),
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('Active (6-7 days/week)'),
                  ),
                  DropdownMenuItem(
                    value: 'very_active',
                    child: Text('Very Active (twice per day)'),
                  ),
                ],
                onChanged: (value) => activityLevel.value = value!,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final age = double.tryParse(ageController.text);
                final weight = double.tryParse(weightController.text);
                final height = double.tryParse(heightController.text);

                if (age != null && weight != null && height != null) {
                  // Mifflin-St Jeor Equation
                  double bmr;
                  if (gender.value == 'male') {
                    bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
                  } else {
                    bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
                  }

                  // Activity multiplier
                  double multiplier;
                  switch (activityLevel.value) {
                    case 'sedentary':
                      multiplier = 1.2;
                      break;
                    case 'light':
                      multiplier = 1.375;
                      break;
                    case 'moderate':
                      multiplier = 1.55;
                      break;
                    case 'active':
                      multiplier = 1.725;
                      break;
                    case 'very_active':
                      multiplier = 1.9;
                      break;
                    default:
                      multiplier = 1.55;
                  }

                  final tdee = bmr * multiplier;
                  calorieResult.value = '${tdee.toInt()} kcal/day';
                } else {
                  Get.snackbar(
                    'Error',
                    'Please fill all fields correctly',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => calorieResult.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Daily Calorie Needs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            calorieResult.value,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'To lose weight: -500 kcal/day',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'To gain weight: +500 kcal/day',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
