import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../services/workout_planner_service.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  final WorkoutPlannerService _service = Get.find<WorkoutPlannerService>();
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  int _currentSlide = 0;

  final List<Map<String, dynamic>> _workoutSlides = [
    {
      'image':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      'overlay': [
        Color(0xFF667eea).withOpacity(0.7),
        Color(0xFF764ba2).withOpacity(0.7),
      ],
      'title': 'Strength Training',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&q=80',
      'overlay': [
        Color(0xFFf093fb).withOpacity(0.7),
        Color(0xFFF5576C).withOpacity(0.7),
      ],
      'title': 'Cardio Fitness',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&q=80',
      'overlay': [
        Color(0xFF4facfe).withOpacity(0.7),
        Color(0xFF00f2fe).withOpacity(0.7),
      ],
      'title': 'Yoga & Flexibility',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
      'overlay': [
        Color(0xFF43e97b).withOpacity(0.7),
        Color(0xFF38f9d7).withOpacity(0.7),
      ],
      'title': 'Group Training',
    },
  ];

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
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentSlide < _workoutSlides.length - 1) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
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

  // Get icon based on workout type
  IconData _getWorkoutIcon(String? workout) {
    if (workout == null || workout.isEmpty) {
      return Icons.event_available;
    }

    final workoutLower = workout.toLowerCase();

    // Cardio & Running
    if (workoutLower.contains('cardio') ||
        workoutLower.contains('running') ||
        workoutLower.contains('run')) {
      return Icons.directions_run;
    }

    // Upper Body
    if (workoutLower.contains('upper body') ||
        workoutLower.contains('upper') ||
        workoutLower.contains('chest') ||
        workoutLower.contains('push') ||
        workoutLower.contains('pull') ||
        workoutLower.contains('back') ||
        workoutLower.contains('shoulder') ||
        workoutLower.contains('arm') ||
        workoutLower.contains('bicep') ||
        workoutLower.contains('tricep')) {
      return Icons.fitness_center;
    }

    // Lower Body & Legs
    if (workoutLower.contains('lower body') ||
        workoutLower.contains('lower') ||
        workoutLower.contains('leg') ||
        workoutLower.contains('squat') ||
        workoutLower.contains('glute')) {
      return Icons.accessibility_new;
    }

    // Yoga & Stretching & Flexibility
    if (workoutLower.contains('yoga') ||
        workoutLower.contains('stretch') ||
        workoutLower.contains('flexibility') ||
        workoutLower.contains('recovery')) {
      return Icons.self_improvement;
    }

    // HIIT & High Intensity
    if (workoutLower.contains('hiit') ||
        workoutLower.contains('interval') ||
        workoutLower.contains('intense')) {
      return Icons.local_fire_department;
    }

    // Core & Abs
    if (workoutLower.contains('core') || workoutLower.contains('ab')) {
      return Icons.stars;
    }

    // Full Body
    if (workoutLower.contains('full body') ||
        workoutLower.contains('total body')) {
      return Icons.accessibility;
    }

    // Swimming
    if (workoutLower.contains('swim')) {
      return Icons.pool;
    }

    // Cycling
    if (workoutLower.contains('cycl') || workoutLower.contains('bike')) {
      return Icons.directions_bike;
    }

    // Walking
    if (workoutLower.contains('walk')) {
      return Icons.directions_walk;
    }

    // Rest Day
    if (workoutLower.contains('rest')) {
      return Icons.hotel;
    }

    // Default
    return Icons.fitness_center;
  }

  // Get color based on workout type
  Color _getWorkoutColor(String? workout) {
    if (workout == null || workout.isEmpty) {
      return Colors.grey[300]!;
    }

    final workoutLower = workout.toLowerCase();

    if (workoutLower.contains('cardio') || workoutLower.contains('run')) {
      return const Color(0xFFFF6B6B); // Red
    }
    if (workoutLower.contains('upper') ||
        workoutLower.contains('push') ||
        workoutLower.contains('pull')) {
      return const Color(0xFF4A90E2); // Blue
    }
    if (workoutLower.contains('lower') || workoutLower.contains('leg')) {
      return const Color(0xFF9B59B6); // Purple
    }
    if (workoutLower.contains('yoga') ||
        workoutLower.contains('stretch') ||
        workoutLower.contains('recovery')) {
      return const Color(0xFF3AB795); // Green
    }
    if (workoutLower.contains('hiit') || workoutLower.contains('interval')) {
      return const Color(0xFFE67E22); // Orange
    }
    if (workoutLower.contains('core')) {
      return const Color(0xFFF39C12); // Yellow-Orange
    }
    if (workoutLower.contains('full body')) {
      return const Color(0xFF1ABC9C); // Teal
    }
    if (workoutLower.contains('rest')) {
      return const Color(0xFF95A5A6); // Gray
    }

    return const Color(0xFF4A90E2); // Default Blue
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
        ],
      ),
      body: Column(
        children: [
          // Image Slider Header
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                // PageView with only background images (sliding)
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSlide = index;
                    });
                  },
                  itemCount: _workoutSlides.length,
                  itemBuilder: (context, index) {
                    final slide = _workoutSlides[index];
                    final overlayColors = (slide['overlay'] as List)
                        .cast<Color>();
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(slide['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: overlayColors,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Static content on top (not sliding)
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Plan Your Week',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 10, color: Colors.black45),
                                Shadow(blurRadius: 20, color: Colors.black26),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap any day to add or edit workout',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          // AI Generate Button
                          Obx(
                            () => ElevatedButton.icon(
                              onPressed: isLoading.value
                                  ? null
                                  : _generateAIPlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667eea),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor: Colors.black38,
                              ),
                              icon: isLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF667eea),
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome, size: 22),
                              label: Text(
                                isLoading.value
                                    ? 'Generating...'
                                    : 'Generate AI Plan',
                                style: const TextStyle(
                                  fontSize: 15,
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
                // Slide indicators
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _workoutSlides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentSlide == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentSlide == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
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
                            color: _getWorkoutColor(workoutPlan[day]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: workoutPlan[day] != null
                                ? [
                                    BoxShadow(
                                      color: _getWorkoutColor(
                                        workoutPlan[day],
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _getWorkoutIcon(workoutPlan[day]),
                            color: workoutPlan[day] != null
                                ? Colors.white
                                : Colors.grey[600],
                            size: 28,
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
                                backgroundColor: const Color(0xFF1A1F3A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    const Icon(
                                      Icons.fitness_center,
                                      color: Color(0xFF4A90E2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Plan for $day',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: controller,
                                      autofocus: true,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Workout Type',
                                        labelStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        hintText:
                                            'e.g., Upper Body, Cardio, Legs',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4A90E2),
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.edit,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Quick suggestions: Upper Body, Lower Body, Full Body, Cardio, HIIT, Yoga, Rest',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
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
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Remove'),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                    ),
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
