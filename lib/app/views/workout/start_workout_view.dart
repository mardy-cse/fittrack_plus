import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/start_workout_controller.dart';

class StartWorkoutView extends GetView<StartWorkoutController> {
  const StartWorkoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.quitWorkout();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Obx(() {
            if (controller.isCompleted.value) {
              return _buildCompletedView();
            }
            return _buildWorkoutView(context);
          }),
        ),
      ),
    );
  }

  Widget _buildWorkoutView(BuildContext context) {
    return Column(
      children: [
        // Top Bar with Quit Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: controller.quitWorkout,
              ),
              Text(
                controller.workout.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // For symmetry
            ],
          ),
        ),

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Obx(
            () => LinearProgressIndicator(
              value: controller.progressPercentage,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Current Exercise / Rest Indicator
        Obx(
          () => Text(
            controller.isResting.value ? 'REST TIME' : 'EXERCISE',
            style: TextStyle(
              color: controller.isResting.value ? Colors.orange : Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Exercise Name
        Obx(
          () => Text(
            controller.currentExerciseName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(),

        // Timer Circle
        Obx(() => _buildTimerCircle(context)),

        const Spacer(),

        // Stats Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => _buildStatCard(
                  'Time',
                  controller.formatDuration(controller.totalSeconds.value),
                  Icons.timer,
                ),
              ),
              Obx(
                () => _buildStatCard(
                  'Exercises',
                  '${controller.exercisesCompleted.value}/${controller.workout.exercises.length}',
                  Icons.fitness_center,
                ),
              ),
              Obx(
                () => _buildStatCard(
                  'Calories',
                  '${controller.caloriesBurned.value}',
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Control Buttons
        Obx(() => _buildControlButtons()),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTimerCircle(BuildContext context) {
    final seconds = controller.isResting.value
        ? controller.restSeconds.value
        : controller.currentExerciseSeconds.value;
    final totalDuration = controller.isResting.value
        ? controller.restDuration
        : controller.exerciseDuration;
    final progress = seconds / totalDuration;

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.isResting.value ? Colors.orange : Colors.green,
              ),
            ),
          ),
          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seconds.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'seconds',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip Button
        if (!controller.isPaused.value)
          ElevatedButton(
            onPressed: controller.skipExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: const Icon(Icons.skip_next, size: 32),
          ),

        const SizedBox(width: 32),

        // Play/Pause Button
        ElevatedButton(
          onPressed: controller.isPaused.value
              ? controller.resumeWorkout
              : controller.pauseWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(
            controller.isPaused.value ? Icons.play_arrow : Icons.pause,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Text(
            'Workout Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Obx(
            () => _buildStatCard(
              'Duration',
              controller.formatDuration(controller.totalSeconds.value),
              Icons.timer,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildStatCard(
              'Calories',
              '${controller.caloriesBurned.value} kcal',
              Icons.local_fire_department,
            ),
          ),
        ],
      ),
    );
  }
}
