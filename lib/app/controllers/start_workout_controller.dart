import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../services/workout_log_service.dart';
import '../services/auth_service.dart';

class StartWorkoutController extends GetxController {
  final WorkoutLogService _workoutLogService = Get.find<WorkoutLogService>();
  final AuthService _authService = Get.find<AuthService>();
  final FlutterTts _flutterTts = FlutterTts();

  // Workout data
  late Workout workout;
  
  // Session tracking
  final Rx<WorkoutSession?> currentSession = Rx<WorkoutSession?>(null);
  String? sessionId;

  // Timer variables
  final RxInt totalSeconds = 0.obs;
  final RxInt currentExerciseIndex = 0.obs;
  final RxInt currentExerciseSeconds = 0.obs;
  final RxInt restSeconds = 0.obs;
  final RxBool isResting = false.obs;
  final RxBool isPaused = false.obs;
  final RxBool isCompleted = false.obs;
  
  // Stats
  final RxInt caloriesBurned = 0.obs;
  final RxInt exercisesCompleted = 0.obs;
  
  Timer? _timer;
  final int exerciseDuration = 40; // seconds per exercise
  final int restDuration = 20; // seconds rest between exercises

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Workout) {
      workout = args;
      _initialize();
    }
  }

  // Initialize controller
  Future<void> _initialize() async {
    await _initializeTts();
    await _createWorkoutSession();
    _startWorkout();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.onClose();
  }

  // Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  // Create workout session
  Future<void> _createWorkoutSession() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    currentSession.value = WorkoutSession(
      workoutId: workout.id,
      workoutTitle: workout.title,
      userId: userId,
      startTime: DateTime.now(),
      durationSeconds: 0,
      caloriesBurned: 0,
      exercisesCompleted: 0,
      totalExercises: workout.exercises.length,
    );

    // Save initial session
    sessionId = await _workoutLogService.saveWorkoutSession(currentSession.value!);
  }

  // Start workout
  void _startWorkout() {
    isPaused.value = false;
    _speak("Let's begin your ${workout.title} workout. Get ready!");
    
    // Start first exercise after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!isPaused.value) {
        _startExercise();
      }
    });
  }

  // Start exercise
  void _startExercise() {
    if (currentExerciseIndex.value >= workout.exercises.length) {
      _completeWorkout();
      return;
    }

    isResting.value = false;
    currentExerciseSeconds.value = exerciseDuration;
    
    final exercise = workout.exercises[currentExerciseIndex.value];
    _speak("Start ${exercise}");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused.value) {
        totalSeconds.value++;
        currentExerciseSeconds.value--;
        
        // Calculate calories (approximate: 5 calories per minute)
        if (totalSeconds.value % 12 == 0) {
          caloriesBurned.value++;
        }

        // Voice cues at specific times
        if (currentExerciseSeconds.value == 10) {
          _speak("10 seconds remaining");
        } else if (currentExerciseSeconds.value == 3) {
          _speak("3, 2, 1");
        }

        if (currentExerciseSeconds.value <= 0) {
          timer.cancel();
          exercisesCompleted.value++;
          _startRest();
        }
      }
    });
  }

  // Start rest period
  void _startRest() {
    isResting.value = true;
    restSeconds.value = restDuration;
    _speak("Rest time. Take a breath.");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused.value) {
        totalSeconds.value++;
        restSeconds.value--;

        if (restSeconds.value == 5) {
          final nextIndex = currentExerciseIndex.value + 1;
          if (nextIndex < workout.exercises.length) {
            _speak("Get ready for ${workout.exercises[nextIndex]}");
          }
        }

        if (restSeconds.value <= 0) {
          timer.cancel();
          currentExerciseIndex.value++;
          _startExercise();
        }
      }
    });
  }

  // Pause workout
  void pauseWorkout() {
    isPaused.value = true;
    _speak("Workout paused");
  }

  // Resume workout
  void resumeWorkout() {
    isPaused.value = false;
    _speak("Resuming workout");
  }

  // Skip current exercise
  void skipExercise() {
    _timer?.cancel();
    if (isResting.value) {
      restSeconds.value = 0;
      currentExerciseIndex.value++;
      _startExercise();
    } else {
      exercisesCompleted.value++;
      _startRest();
    }
  }

  // Complete workout
  Future<void> _completeWorkout() async {
    _timer?.cancel();
    isCompleted.value = true;
    _speak("Congratulations! You completed your workout!");

    // Update session
    if (sessionId != null && currentSession.value != null) {
      final updatedSession = currentSession.value!.copyWith(
        endTime: DateTime.now(),
        durationSeconds: totalSeconds.value,
        caloriesBurned: caloriesBurned.value,
        exercisesCompleted: exercisesCompleted.value,
        isCompleted: true,
        completedExercises: workout.exercises,
      );

      await _workoutLogService.updateWorkoutSession(
        sessionId!,
        updatedSession.toMap(),
      );

      // Show completion dialog
      _showCompletionDialog();
    }
  }

  // Show completion dialog
  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Workout Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${formatDuration(totalSeconds.value)}'),
            const SizedBox(height: 8),
            Text('Exercises: ${exercisesCompleted.value}/${workout.exercises.length}'),
            const SizedBox(height: 8),
            Text('Calories Burned: ${caloriesBurned.value} kcal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Quit workout
  void quitWorkout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Quit Workout?'),
        content: const Text('Are you sure you want to quit this workout? Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              _timer?.cancel();
              
              // Save partial session
              if (sessionId != null && currentSession.value != null) {
                final partialSession = currentSession.value!.copyWith(
                  endTime: DateTime.now(),
                  durationSeconds: totalSeconds.value,
                  caloriesBurned: caloriesBurned.value,
                  exercisesCompleted: exercisesCompleted.value,
                  isCompleted: false,
                );

                await _workoutLogService.updateWorkoutSession(
                  sessionId!,
                  partialSession.toMap(),
                );
              }

              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Speak text
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Format duration (public method for UI)
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get current exercise name
  String get currentExerciseName {
    if (currentExerciseIndex.value < workout.exercises.length) {
      return workout.exercises[currentExerciseIndex.value];
    }
    return '';
  }

  // Get progress percentage
  double get progressPercentage {
    if (workout.exercises.isEmpty) return 0.0;
    return exercisesCompleted.value / workout.exercises.length;
  }
}
