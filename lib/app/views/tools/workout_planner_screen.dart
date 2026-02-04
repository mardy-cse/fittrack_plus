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

  Future<void> _generateAIPlan() async {
    try {
      isLoading.value = true;

      // Show loading message
      Get.snackbar(
        'AI Generating...',
        'Creating personalized workout plan based on your profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4A90E2),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Generate AI plan
      final aiPlan = await _service.generateAIWorkoutPlan();

      if (aiPlan.isEmpty) {
        throw Exception('Failed to generate plan');
      }

      workoutPlan.value = aiPlan;

      // Save to database
      await _saveWorkoutPlan();

      Get.snackbar(
        'AI Plan Generated! 🤖',
        'Your personalized weekly workout plan is ready',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error generating AI plan: $e');
      Get.snackbar(
        'Error',
        'Failed to generate AI plan. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _generateAIPlan,
            tooltip: 'Generate AI Plan',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkoutPlan,
            tooltip: 'Save Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_month, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Plan Your Week',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap any day to add or edit workout',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                // AI Generate Button
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: isLoading.value ? null : _generateAIPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A90E2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    icon: isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4A90E2),
                              ),
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 24),
                    label: Text(
                      isLoading.value ? 'Generating...' : 'Generate AI Plan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.fitness_center,
                                      color: Color(0xFF4A90E2),
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
                                      autofocus: true,
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
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Quick suggestions: Upper Body, Lower Body, Full Body, Cardio, HIIT, Yoga, Rest',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  if (workoutPlan[day] != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                        _removeDayPlan(day).then((_) {
                                          Get.snackbar(
                                            'Removed',
                                            '$day is now a rest day',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.orange,
                                            colorText: Colors.white,
                                          );
                                        });
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
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (controller.text.trim().isEmpty) {
                                        Get.snackbar(
                                          'Empty Field',
                                          'Please enter a workout type',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      Navigator.of(dialogContext).pop();
                                      _updateDayPlan(
                                        day,
                                        controller.text.trim(),
                                      ).then((_) {
                                        Get.snackbar(
                                          'Saved to Database',
                                          '$day: ${controller.text.trim()}',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                        );
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A90E2),
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Save'),
                                  ),
                                ],
                              );
                            },
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
