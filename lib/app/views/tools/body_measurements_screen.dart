import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class BodyMeasurementsScreen extends StatelessWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get profile data for reference
    final controller = Get.find<HomeController>();
    final user = controller.userProfile.value;

    final measurements = {
      'Weight': TextEditingController(
        text: user?.weight?.toInt().toString() ?? '',
      ),
      'Chest': TextEditingController(),
      'Waist': TextEditingController(),
      'Hips': TextEditingController(),
      'Biceps': TextEditingController(),
      'Thighs': TextEditingController(),
      'Calves': TextEditingController(),
    };

    final icons = {
      'Weight': Icons.monitor_weight,
      'Chest': Icons.fitness_center,
      'Waist': Icons.straighten,
      'Hips': Icons.accessibility_new,
      'Biceps': Icons.sports_gymnastics,
      'Thighs': Icons.directions_walk,
      'Calves': Icons.sports_martial_arts,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.straighten, size: 80, color: Colors.purple),
            const SizedBox(height: 24),
            const Text(
              'Track your body progress',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ...measurements.keys.map((key) {
              final unit = key == 'Weight' ? 'kg' : 'cm';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: measurements[key],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '$key ($unit)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(icons[key], color: Colors.purple),
                    helperText: key == 'Weight' ? 'From your profile' : null,
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                bool hasData = false;
                for (var controller in measurements.values) {
                  if (controller.text.isNotEmpty) {
                    hasData = true;
                    break;
                  }
                }

                if (hasData) {
                  Get.snackbar(
                    'Saved! ✓',
                    'Measurements saved successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Please enter at least one measurement',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Measurements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.purple),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Measure at the same time each week for accurate tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
