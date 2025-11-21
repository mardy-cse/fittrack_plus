import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutPlannerScreen extends StatelessWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final workoutPlan = <String, String>{}.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Planner'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Get.snackbar(
                'Saved! ✓',
                'Workout plan saved successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.red.withOpacity(0.1),
            child: Column(
              children: [
                const Icon(Icons.calendar_month, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Plan Your Week',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap any day to add or edit workout',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = daysOfWeek[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Obx(
                    () => Card(
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        tileColor: workoutPlan[day] != null
                            ? Colors.red.withOpacity(0.1)
                            : null,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: workoutPlan[day] != null
                                ? Colors.red
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            workoutPlan[day] != null
                                ? Icons.fitness_center
                                : Icons.event_available,
                            color: workoutPlan[day] != null
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                        title: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          workoutPlan[day] ?? 'Rest day - Tap to add workout',
                          style: TextStyle(
                            color: workoutPlan[day] != null
                                ? Colors.red
                                : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          workoutPlan[day] != null
                              ? Icons.edit
                              : Icons.add_circle,
                          color: Colors.red,
                          size: 28,
                        ),
                        onTap: () {
                          final controller = TextEditingController(
                            text: workoutPlan[day] ?? '',
                          );
                          Get.dialog(
                            AlertDialog(
                              title: Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Plan for $day'),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Workout Type',
                                      hintText:
                                          'e.g., Upper Body, Cardio, Legs',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.edit),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Quick suggestions: Upper Body, Lower Body, Full Body, Cardio, HIIT, Yoga, Rest',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                if (workoutPlan[day] != null)
                                  TextButton.icon(
                                    onPressed: () {
                                      workoutPlan.remove(day);
                                      Get.back();
                                      Get.snackbar(
                                        'Removed',
                                        '$day is now a rest day',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (controller.text.isNotEmpty) {
                                      workoutPlan[day] = controller.text;
                                      Get.back();
                                      Get.snackbar(
                                        'Added',
                                        '$day: ${controller.text}',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
