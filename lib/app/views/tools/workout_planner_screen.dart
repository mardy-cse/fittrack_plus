import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/workout_planner_service.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  final WorkoutPlannerService _service = Get.find<WorkoutPlannerService>();

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
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    try {
      isLoading.value = true;
      final plan = await _service.loadWorkoutPlan();
      workoutPlan.value = plan;
    } catch (e) {
      debugPrint('Error loading workout plan: $e');
      Get.snackbar(
        'Error',
        'Failed to load workout plan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveWorkoutPlan() async {
    try {
      isLoading.value = true;
      final success = await _service.saveWorkoutPlan(workoutPlan);
      if (success) {
        Get.snackbar(
          'Saved! ✓',
          'Workout plan saved to database',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Save failed');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save workout plan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateDayPlan(String day, String workout) async {
    workoutPlan[day] = workout;
    // Auto-save to database
    await _saveWorkoutPlan();
  }

  Future<void> _removeDayPlan(String day) async {
    workoutPlan.remove(day);
    // Auto-save to database
    await _saveWorkoutPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Workout Planner'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveWorkoutPlan),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            child: Column(
              children: [
                const Icon(Icons.calendar_month, size: 60, color: Colors.white),
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
                            ? const Color(0xFF4A90E2).withOpacity(0.2)
                            : null,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: workoutPlan[day] != null
                                ? const Color(0xFF4A90E2)
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
                                ? const Color(0xFF4A90E2)
                                : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          workoutPlan[day] != null
                              ? Icons.edit
                              : Icons.add_circle,
                          color: Colors.white,
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
                                    color: Colors.white,
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
                                    onPressed: () async {
                                      Get.back();
                                      await _removeDayPlan(day);
                                      Get.snackbar(
                                        'Removed',
                                        '$day is now a rest day',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.orange,
                                        colorText: Colors.white,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Remove',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (controller.text.isNotEmpty) {
                                      Get.back();
                                      await _updateDayPlan(
                                        day,
                                        controller.text,
                                      );
                                      Get.snackbar(
                                        'Saved to Database',
                                        '$day: ${controller.text}',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
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
