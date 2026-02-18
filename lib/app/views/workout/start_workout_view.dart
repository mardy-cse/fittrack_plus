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
        // Allow back navigation if workout is completed
        if (controller.isCompleted.value) {
          return true;
        }
        // Otherwise show quit confirmation
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
    return SingleChildScrollView(
      child: Column(
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
                color: controller.isResting.value
                    ? Colors.orange
                    : Colors.green,
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
                          'assets/animations/rest_time.jpg',
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

          const SizedBox(height: 24),

          // Timer Circle
          Obx(() => _buildTimerCircle(context)),

          const SizedBox(height: 24),

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
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            const Text(
              'Workout Complete! 🎉',
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
            const SizedBox(height: 16),
            Obx(
              () => _buildStatCard(
                'Exercises',
                '${controller.exercisesCompleted.value}/${controller.workout.exercises.length}',
                Icons.fitness_center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAnimationForExercise(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();

    // Core exercises - check these first
    if (lowerName.contains('bicycle') &&
        (lowerName.contains('crunch') || lowerName.contains('crunches'))) {
      return 'assets/animations/bicycle_crunches_real.gif';
    }
    if (lowerName.contains('russian') && lowerName.contains('twist')) {
      return 'assets/animations/russian_twists.gif';
    }
    if (lowerName.contains('leg') && lowerName.contains('raise')) {
      return 'assets/animations/leg_raises.gif';
    }
    if (lowerName.contains('mountain') && lowerName.contains('climber')) {
      return 'assets/animations/mountain_climbers_real.gif';
    }

    // Pilates exercises
    if (lowerName.contains('hundred')) {
      return 'assets/animations/pilates_hundred.gif';
    }
    if (lowerName.contains('roll') && lowerName.contains('up')) {
      return 'assets/animations/roll_up.gif';
    }
    if (lowerName.contains('single') &&
        lowerName.contains('leg') &&
        lowerName.contains('stretch')) {
      return 'assets/animations/single_leg_stretch.gif';
    }
    if (lowerName.contains('double') &&
        lowerName.contains('leg') &&
        lowerName.contains('stretch')) {
      return 'assets/animations/double_leg_stretch.gif';
    }
    if (lowerName.contains('spine') && lowerName.contains('stretch')) {
      return 'assets/animations/spine_stretch.gif';
    }

    // Stretching & Mobility exercises
    if (lowerName.contains('hamstring') && lowerName.contains('stretch')) {
      return 'assets/animations/hamstring_stretch.gif';
    }
    if (lowerName.contains('hip') &&
        lowerName.contains('flexor') &&
        lowerName.contains('stretch')) {
      return 'assets/animations/hip_flexor_stretch.gif';
    }
    if (lowerName.contains('shoulder') && lowerName.contains('stretch')) {
      return 'assets/animations/shoulder_stretch.gif';
    }
    if (lowerName.contains('cat') && lowerName.contains('cow')) {
      return 'assets/animations/cat_cow_stretch.gif';
    }
    if (lowerName.contains('child') && lowerName.contains('pose')) {
      return 'assets/animations/childs_pose.gif';
    }

    // Meditation exercises
    if (lowerName.contains('breathing') && lowerName.contains('exercise')) {
      return 'assets/animations/breathing_exercises.gif';
    }
    if (lowerName.contains('body') && lowerName.contains('scan')) {
      return 'assets/animations/body_scan.gif';
    }
    if (lowerName.contains('guided') && lowerName.contains('visualization')) {
      return 'assets/animations/guided_visualization.gif';
    }
    if (lowerName.contains('loving') && lowerName.contains('kindness')) {
      return 'assets/animations/loving_kindness_meditation.gif';
    }

    // Strength Training - Upper Body exercises
    if (lowerName.contains('push') && lowerName.contains('up')) {
      return 'assets/animations/pushups_real.gif';
    }
    if (lowerName.contains('dumbbell') && lowerName.contains('row')) {
      return 'assets/animations/dumbbell_rows.gif';
    }
    if (lowerName.contains('shoulder') && lowerName.contains('press')) {
      return 'assets/animations/shoulder_press.gif';
    }
    if (lowerName.contains('bicep') && lowerName.contains('curl')) {
      return 'assets/animations/bicep_curls_real.gif';
    }
    if (lowerName.contains('tricep') && lowerName.contains('dip')) {
      return 'assets/animations/tricep_dips.gif';
    }

    // Leg Day exercises - check these before generic matches
    if (lowerName.contains('squat') && !lowerName.contains('jump')) {
      return 'assets/images/exercises/squats.gif';
    }
    if (lowerName.contains('lunge')) {
      return 'assets/images/exercises/lunges.gif';
    }
    if (lowerName.contains('leg') && lowerName.contains('press')) {
      return 'assets/images/exercises/leg_press.gif';
    }
    if (lowerName.contains('hamstring') && lowerName.contains('curl')) {
      return 'assets/images/exercises/hamstring_curls.webp';
    }
    if (lowerName.contains('calf') && lowerName.contains('raise')) {
      return 'assets/images/exercises/calf_raises.webp';
    }

    // Boxing exercises
    if (lowerName.contains('jab') && lowerName.contains('cross')) {
      return 'assets/images/exercises/jab_cross_combo.webp';
    }
    if (lowerName.contains('hook') && lowerName.contains('punch')) {
      return 'assets/images/exercises/hook_punches.gif';
    }
    if (lowerName.contains('uppercut')) {
      return 'assets/images/exercises/uppercuts.gif';
    }
    if (lowerName.contains('speed') && lowerName.contains('bag')) {
      return 'assets/images/exercises/speed_bag.gif';
    }
    if (lowerName.contains('jump') && lowerName.contains('rope')) {
      return 'assets/images/exercises/jump_rope.gif';
    }

    // Yoga exercises
    if (lowerName.contains('sun salutation') ||
        lowerName.contains('surya namaskar')) {
      return 'assets/animations/sun_salutation.json';
    } else if (lowerName.contains('downward dog') ||
        lowerName.contains('down dog')) {
      return 'assets/animations/downward_dog.gif'; // ✅ GIF animation
    } else if (lowerName.contains('warrior')) {
      return 'assets/animations/warrior_pose.gif'; // ✅ Warrior Pose GIF
    } else if (lowerName.contains('tree pose')) {
      return 'assets/animations/tree_pose.gif'; // ✅ Tree Pose GIF
    } else if (lowerName.contains('savasana')) {
      return 'assets/animations/savasana_meditation.gif'; // ✅ Savasana GIF
    } else if (lowerName.contains('push') || lowerName.contains('push-up')) {
      return 'assets/animations/pushup_improved.json';
    } else if (lowerName.contains('squat') ||
        lowerName.contains('jump squat')) {
      return 'assets/animations/squat_improved.json';
    } else if (lowerName.contains('plank') || lowerName.contains('core')) {
      return 'assets/animations/plank.gif'; // ✅ Plank GIF
    } else if (lowerName.contains('run') ||
        lowerName.contains('jog') ||
        lowerName.contains('cardio')) {
      return 'assets/animations/running_improved.json';
    } else if (lowerName.contains('jump') || lowerName.contains('jack')) {
      return 'assets/animations/jumping_jacks.json';
    } else if (lowerName.contains('burpee')) {
      return 'assets/animations/burpees.json';
    } else if (lowerName.contains('mountain') &&
        lowerName.contains('climber')) {
      return 'assets/animations/plank.gif';
    } else if (lowerName.contains('lunge')) {
      return 'assets/animations/lunges.json';
    } else if (lowerName.contains('sit') &&
        (lowerName.contains('up') || lowerName.contains('ups'))) {
      return 'assets/animations/situps.json';
    } else if (lowerName.contains('crunch') ||
        lowerName.contains('ab') ||
        lowerName.contains('twist') ||
        lowerName.contains('raise')) {
      return 'assets/animations/plank.gif';
    } else if (lowerName.contains('bicep') || lowerName.contains('curl')) {
      return 'assets/animations/bicep_curls.json';
    } else if (lowerName.contains('dumbbell') || lowerName.contains('arm')) {
      return 'assets/animations/bicep_curls.json';
    } else {
      return 'assets/animations/squat_improved.json';
    }
  }

  Widget _buildAnimationWidget(String assetPath, bool shouldAnimate) {
    // Check if it's an image file (GIF, WebP, PNG, JPG)
    if (assetPath.toLowerCase().endsWith('.gif') ||
        assetPath.toLowerCase().endsWith('.webp') ||
        assetPath.toLowerCase().endsWith('.png') ||
        assetPath.toLowerCase().endsWith('.jpg') ||
        assetPath.toLowerCase().endsWith('.jpeg')) {
      return Image.asset(
        assetPath,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.fitness_center,
            size: 120,
            color: Colors.white.withOpacity(0.7),
          );
        },
      );
    }
    // Otherwise use Lottie animation
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
