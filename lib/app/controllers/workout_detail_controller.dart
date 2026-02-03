import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../views/workout/workout_detail_view.dart';

class WorkoutDetailController extends GetxController {
  final WorkoutService _workoutService = Get.find<WorkoutService>();

  // Observable variables
  final Rx<Workout?> workout = Rx<Workout?>(null);
  final RxList<Workout> relatedWorkouts = <Workout>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get workout from arguments
    final args = Get.arguments;
    if (args is Workout) {
      workout.value = args;
      loadRelatedWorkouts();
    }
  }

  // Load related workouts
  Future<void> loadRelatedWorkouts() async {
    if (workout.value == null) return;

    try {
      isLoading.value = true;

      // Get workouts with same level or category
      final allWorkouts = await _workoutService.getAllWorkouts();

      relatedWorkouts.value = allWorkouts
          .where(
            (w) =>
                w.id != workout.value!.id &&
                (w.level == workout.value!.level ||
                    w.category == workout.value!.category),
          )
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Error loading related workouts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start workout
  void startWorkout() {
    if (workout.value != null) {
      Get.toNamed('/start-workout', arguments: workout.value);
    }
  }

  // Navigate to related workout
  void openRelatedWorkout(Workout relatedWorkout) {
    // Navigate to new workout detail
    Get.off(() => const WorkoutDetailView(), arguments: relatedWorkout);
  }
}
