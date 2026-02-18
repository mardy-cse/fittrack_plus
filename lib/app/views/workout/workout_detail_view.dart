import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/workout_detail_controller.dart';

class WorkoutDetailView extends GetView<WorkoutDetailController> {
  const WorkoutDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        final workout = controller.workout.value;
        if (workout == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // Hero Image Header with App Bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: isDark ? Colors.black : Colors.white,
              foregroundColor: isDark ? Colors.white : Colors.black,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final isCollapsed =
                      top <=
                      kToolbarHeight + MediaQuery.of(context).padding.top + 20;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isCollapsed ? 1.0 : 0.0,
                      child: Text(
                        workout.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(
                      left: 16,
                      bottom: 16,
                      right: 16,
                    ),
                    background: Hero(
                      tag: 'workout-${workout.id}',
                      child: workout.imageUrl.isNotEmpty
                          ? Image(
                              image: workout.imageUrl.startsWith('http')
                                  ? NetworkImage(workout.imageUrl)
                                  : AssetImage(workout.imageUrl)
                                        as ImageProvider,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.fitness_center,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Badges
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildBadge(
                              workout.level,
                              _getLevelColor(workout.level),
                              Icons.signal_cellular_alt,
                            ),
                            _buildBadge(
                              '${workout.duration} min',
                              Colors.blue,
                              Icons.timer,
                            ),
                            _buildBadge(
                              '${workout.calories} cal',
                              Colors.orange,
                              Icons.local_fire_department,
                            ),
                            _buildBadge(
                              workout.category,
                              Colors.purple,
                              Icons.category,
                            ),
                            if (workout.isPremium)
                              _buildBadge('Premium', Colors.amber, Icons.star),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workout.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Exercise Demonstration
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to Perform',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF4A90E2).withOpacity(0.05),
                                  const Color(0xFF50C878).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  // Lottie Animation with error handling
                                  Center(
                                    child: _buildAnimationWidget(
                                      workout.animationAsset.isNotEmpty
                                          ? workout.animationAsset
                                          : _getAnimationForCategory(
                                              workout.category,
                                            ),
                                    ),
                                  ),
                                  // Instruction overlay
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getExerciseInstruction(
                                          workout.category,
                                        ),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Play indicator
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A90E2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        '💡 Tap exercises below for details',
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Exercises List
                  if (workout.exercises.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Exercises',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...workout.exercises.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildExerciseItem(
                                context,
                                entry.key,
                                entry.value,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Tags
                  if (workout.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: workout.tags.map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                                backgroundColor: isDark
                                    ? const Color(0xFF1C1C1E)
                                    : const Color(0xFF4A90E2).withOpacity(0.1),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : const Color(
                                          0xFF4A90E2,
                                        ).withOpacity(0.3),
                                  width: 1,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Related Workouts
                  Obx(() {
                    if (controller.relatedWorkouts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Related Workouts',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: controller.relatedWorkouts.length,
                            itemBuilder: (context, index) {
                              final relatedWorkout =
                                  controller.relatedWorkouts[index];
                              return _buildRelatedWorkoutCard(
                                context,
                                relatedWorkout,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      }),

      // Start Workout Button
      bottomNavigationBar: Obx(() {
        final workout = controller.workout.value;
        if (workout == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: controller.startWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Start Workout',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedWorkoutCard(BuildContext context, workout) {
    return GestureDetector(
      onTap: () => controller.openRelatedWorkout(workout),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'workout-${workout.id}',
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                  image: workout.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: workout.imageUrl.startsWith('http')
                              ? NetworkImage(workout.imageUrl)
                              : AssetImage(workout.imageUrl) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: workout.imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              workout.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${workout.duration} min',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getExerciseInstruction(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
        return 'Get your heart pumping with cardio exercises';
      case 'strength':
        return 'Build muscle with strength training';
      case 'yoga':
        return 'Improve flexibility and mindfulness';
      case 'core':
        return 'Strengthen your core muscles';
      case 'flexibility':
        return 'Increase your range of motion';
      case 'hiit':
        return 'High intensity interval training';
      default:
        return 'Follow the exercises below';
    }
  }

  String _getAnimationForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
      case 'hiit':
        return 'assets/animations/burpees.json';
      case 'strength':
        return 'assets/animations/bicep_curls.json';
      case 'yoga':
      case 'flexibility':
      case 'pilates':
        return 'assets/animations/plank.json';
      case 'core':
      case 'abs':
        return 'assets/animations/situps.json';
      default:
        return 'assets/animations/squat_improved.json';
    }
  }

  Widget _buildAnimationWidget(String assetPath) {
    try {
      // Check if it's a GIF file
      if (assetPath.toLowerCase().endsWith('.gif')) {
        return Image.asset(
          assetPath,
          width: 280,
          height: 280,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        );
      }
      // Otherwise use Lottie animation
      return Lottie.asset(
        assetPath,
        width: 280,
        height: 280,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon();
        },
      );
    } catch (e) {
      return _buildFallbackIcon();
    }
  }

  Widget _buildFallbackIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.fitness_center, size: 100, color: const Color(0xFF4A90E2)),
        const SizedBox(height: 16),
        const Text(
          'Ready to workout!',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4A90E2),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Get animation for specific exercise name
  String _getAnimationForExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();

    // Yoga exercises
    if (name.contains('sun salutation') || name.contains('surya namaskar')) {
      return 'assets/animations/sun_salutation.json'; // ✅ Yogasana animation
    } else if (name.contains('downward dog') ||
        name.contains('down dog') ||
        name.contains('adho mukha')) {
      return 'assets/animations/downward_dog.gif'; // ✅ GIF animation
    } else if (name.contains('warrior') || name.contains('virabhadrasana')) {
      return 'assets/animations/lunges.json'; // Warrior pose similar to lunge stance
    } else if (name.contains('tree pose') || name.contains('vrksasana')) {
      return 'assets/animations/plank.json'; // TODO: Add tree pose animation
    } else if (name.contains('savasana') || name.contains('corpse pose')) {
      return 'assets/animations/plank.json'; // TODO: Add savasana animation
    } else if (name.contains('push') ||
        name.contains('push-up') ||
        name.contains('chest') ||
        name.contains('press')) {
      return 'assets/animations/pushup_improved.json';
    } else if (name.contains('squat') || name.contains('jump squat')) {
      return 'assets/animations/squat_improved.json';
    } else if (name.contains('plank')) {
      return 'assets/animations/plank.json';
    } else if (name.contains('run') || name.contains('jog')) {
      return 'assets/animations/running_improved.json';
    } else if (name.contains('jump') &&
        (name.contains('jack') || name.contains('rope'))) {
      return 'assets/animations/jumping_jacks.json';
    } else if (name.contains('burpee')) {
      return 'assets/animations/burpees.json';
    } else if (name.contains('mountain') && name.contains('climber')) {
      return 'assets/animations/mountain_climbers.json';
    } else if (name.contains('lunge')) {
      return 'assets/animations/lunges.json';
    } else if (name.contains('sit') &&
        (name.contains('up') || name.contains('ups'))) {
      return 'assets/animations/situps.json';
    } else if (name.contains('crunch') ||
        name.contains('twist') ||
        name.contains('leg raise')) {
      return 'assets/animations/situps.json';
    } else if (name.contains('bicep') ||
        name.contains('curl') ||
        name.contains('dumbbell') ||
        name.contains('tricep') ||
        name.contains('row')) {
      return 'assets/animations/bicep_curls.json';
    } else if (name.contains('high knee')) {
      return 'assets/animations/running_improved.json';
    } else {
      // Default to category-based animation
      final workout = controller.workout.value;
      if (workout != null) {
        return _getAnimationForCategory(workout.category);
      }
      return 'assets/animations/squat_improved.json';
    }
  }

  // Build expandable exercise item
  Widget _buildExerciseItem(
    BuildContext context,
    int index,
    String exerciseName,
  ) {
    final RxBool isExpanded = false.obs;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            InkWell(
              onTap: () => isExpanded.value = !isExpanded.value,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A90E2),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exerciseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF4A90E2),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded.value)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF8F9FA),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4A90E2).withOpacity(0.1),
                            const Color(0xFF50C878).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _buildAnimationWidget(
                          _getAnimationForExercise(exerciseName),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF4A90E2),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Follow the animation form for best results',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
