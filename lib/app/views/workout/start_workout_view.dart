import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
        const SizedBox(height: 24),

        // Exercise Animation Card
        Obx(() {
          if (!controller.isResting.value) {
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withOpacity(0.2),
                      Colors.blue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Lottie Animation with error handling
                      Center(
                        child: _buildAnimationWidget(
                          _getAnimationForExercise(
                            controller.currentExerciseName,
                          ),
                          !controller.isPaused.value,
                        ),
                      ),
                      // Form tip overlay
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Follow the form',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          // Rest time card
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.red.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Center(
                      child: _buildAnimationWidget(
                        'assets/animations/plank.json',
                        true,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Take a breath',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

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

  IconData _getExerciseIcon(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();

    if (lowerName.contains('plank') ||
        lowerName.contains('core') ||
        lowerName.contains('ab')) {
      return Icons.accessibility_new;
    } else if (lowerName.contains('push') ||
        lowerName.contains('chest') ||
        lowerName.contains('press')) {
      return Icons.fitness_center;
    } else if (lowerName.contains('squat') ||
        lowerName.contains('leg') ||
        lowerName.contains('lunge')) {
      return Icons.airline_seat_legroom_normal;
    } else if (lowerName.contains('run') ||
        lowerName.contains('cardio') ||
        lowerName.contains('jog')) {
      return Icons.directions_run;
    } else if (lowerName.contains('jump') ||
        lowerName.contains('jack') ||
        lowerName.contains('burpee')) {
      return Icons.sports_gymnastics;
    } else if (lowerName.contains('rest')) {
      return Icons.self_improvement;
    } else {
      return Icons.fitness_center;
    }
  }

  String _getAnimationForExercise(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();

    if (lowerName.contains('plank') ||
        lowerName.contains('core') ||
        lowerName.contains('ab')) {
      return 'assets/animations/plank.json';
    } else if (lowerName.contains('push') ||
        lowerName.contains('chest') ||
        lowerName.contains('press')) {
      return 'assets/animations/pushup_improved.json';
    } else if (lowerName.contains('squat') ||
        lowerName.contains('leg') ||
        lowerName.contains('lunge')) {
      return 'assets/animations/squat_improved.json';
    } else if (lowerName.contains('run') ||
        lowerName.contains('cardio') ||
        lowerName.contains('jog')) {
      return 'assets/animations/running_improved.json';
    } else if (lowerName.contains('jump') ||
        lowerName.contains('jack') ||
        lowerName.contains('burpee')) {
      return 'assets/animations/jumping_jacks.lottie';
    } else {
      return 'assets/animations/squat_improved.json';
    }
  }

  Widget _buildAnimationWidget(String assetPath, bool shouldAnimate) {
    return Lottie.asset(
      assetPath,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      repeat: true,
      animate: shouldAnimate,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if animation fails
        return Icon(
          Icons.fitness_center,
          size: 120,
          color: Colors.white.withOpacity(0.7),
        );
      },
    );
  }
}
