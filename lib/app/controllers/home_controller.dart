import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/workout.dart';
import '../models/user_profile.dart';
import '../services/workout_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'progress_controller.dart';
// import 'steps_controller.dart'; // Disabled for emulator

class HomeController extends GetxController {
  final WorkoutService _workoutService = Get.find<WorkoutService>();
  final UserService userService = Get.find<UserService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable variables
  final RxList<Workout> workouts = <Workout>[].obs;
  final RxList<Workout> filteredWorkouts = <Workout>[].obs;
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxString selectedLevel = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentNavIndex = 0.obs;

  // Stats - now synced from ProgressController and StepsController
  final RxInt todaySteps = 0.obs;
  final RxInt todayCalories = 0.obs;
  final RxInt todayWorkouts = 0.obs;
  final RxInt currentStreak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadWorkouts();
    _syncProgressStats();
    // _syncStepsData(); // Disabled for emulator
  }

  // Sync stats from ProgressController
  void _syncProgressStats() {
    try {
      final progressController = Get.find<ProgressController>();

      // Listen to changes in progress stats
      ever(progressController.totalWorkouts, (_) => _updateTodayStats());
      ever(progressController.totalCalories, (_) => _updateTodayStats());
      ever(progressController.currentStreak, (_) {
        currentStreak.value = progressController.currentStreak.value;
      });

      // Initial load
      _updateTodayStats();
    } catch (e) {
      debugPrint('Progress sync error: $e');
    }
  }

  // Calculate today's stats from recent sessions
  void _updateTodayStats() {
    try {
      final progressController = Get.find<ProgressController>();
      final today = DateTime.now();

      // Filter today's sessions
      final todaySessions = progressController.allSessions.where((session) {
        return session.createdAt.year == today.year &&
            session.createdAt.month == today.month &&
            session.createdAt.day == today.day;
      }).toList();

      // Calculate stats
      todayWorkouts.value = todaySessions.length;
      todayCalories.value = todaySessions.fold(
        0,
        (sum, session) => sum + session.caloriesBurned,
      );
    } catch (e) {
      debugPrint('Today stats update error: $e');
    }
  }

  // Sync steps data from StepsController (Disabled for emulator)
  // void _syncStepsData() {
  //   try {
  //     final stepsController = Get.find<StepsController>();
  //
  //     // Listen to changes in steps
  //     ever(stepsController.todaySteps, (_) {
  //       todaySteps.value = stepsController.todaySteps.value;
  //     });
  //
  //     // Initial load
  //     todaySteps.value = stepsController.todaySteps.value;
  //   } catch (e) {
  //     print('Steps sync error: $e');
  //   }
  // }

  // Load user profile
  Future<void> loadUserProfile() async {
    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        final profile = await userService.getUserProfile(uid);
        userProfile.value = profile;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Load workouts
  Future<void> loadWorkouts() async {
    try {
      isLoading.value = true;

      // First try to get from Firestore
      final fetchedWorkouts = await _workoutService.getAllWorkouts();

      // If Firestore is empty, load from local JSON
      if (fetchedWorkouts.isEmpty) {
        final localWorkouts = await _workoutService.loadLocalWorkouts();
        workouts.value = localWorkouts;
        filteredWorkouts.value = localWorkouts;
      } else {
        workouts.value = fetchedWorkouts;
        filteredWorkouts.value = fetchedWorkouts;
      }
    } catch (e) {
      // If Firestore fails, try local JSON
      try {
        final localWorkouts = await _workoutService.loadLocalWorkouts();
        workouts.value = localWorkouts;
        filteredWorkouts.value = localWorkouts;
      } catch (localError) {
        Get.snackbar(
          'Error',
          'Failed to load workouts',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Filter workouts by level
  void filterByLevel(String level) {
    selectedLevel.value = level;
    if (level == 'All') {
      filteredWorkouts.value = workouts;
    } else {
      filteredWorkouts.value = workouts
          .where((workout) => workout.level == level)
          .toList();
    }
  }

  // Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get user name
  String getUserName() {
    return userProfile.value?.name ?? 'User';
  }

  // Change navigation index
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([loadUserProfile(), loadWorkouts()]);
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
