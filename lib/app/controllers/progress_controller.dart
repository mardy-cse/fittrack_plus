import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/workout_session.dart';
import '../services/workout_log_service.dart';
import '../services/auth_service.dart';

class ProgressController extends GetxController {
  final WorkoutLogService _workoutLogService = Get.find<WorkoutLogService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable variables
  final RxList<WorkoutSession> recentSessions = <WorkoutSession>[].obs;
  final RxList<WorkoutSession> allSessions = <WorkoutSession>[].obs;
  final RxBool isLoading = false.obs;

  // Stats
  final RxInt totalWorkouts = 0.obs;
  final RxInt totalCalories = 0.obs;
  final RxInt totalMinutes = 0.obs;
  final RxInt currentStreak = 0.obs;

  // Weekly chart data (7 days)
  final RxList<double> weeklyWorkouts = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  // Calendar
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<WorkoutSession> selectedDateSessions = <WorkoutSession>[].obs;

  // Stream subscription for real-time updates
  StreamSubscription<List<WorkoutSession>>? _sessionsSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupRealtimeListener();
  }

  @override
  void onClose() {
    _sessionsSubscription?.cancel();
    super.onClose();
  }

  // Setup real-time listener for workout sessions
  void _setupRealtimeListener() {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    isLoading.value = true;

    _sessionsSubscription = _workoutLogService
        .watchUserWorkoutSessions(userId)
        .listen(
          (sessions) {
            debugPrint(
              'ProgressController: Real-time update - ${sessions.length} sessions',
            );

            allSessions.value = sessions;
            recentSessions.value = sessions.take(10).toList();

            _calculateStats();
            _calculateWeeklyData();
            _calculateStreak();

            isLoading.value = false;
          },
          onError: (error) {
            debugPrint('Error in real-time listener: $error');
            isLoading.value = false;
          },
        );
  }

  // Load all progress data
  Future<void> loadProgressData() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId;

      if (userId == null) {
        debugPrint('ProgressController: User ID is null');
        isLoading.value = false;
        return;
      }

      debugPrint('ProgressController: Loading sessions for user: $userId');

      // Load all sessions
      allSessions.value = await _workoutLogService.getUserWorkoutSessions(
        userId,
      );

      debugPrint('ProgressController: Loaded ${allSessions.length} sessions');

      // Load recent sessions (last 10)
      recentSessions.value = allSessions.take(10).toList();

      // Calculate stats
      _calculateStats();
      _calculateWeeklyData();
      _calculateStreak();

      debugPrint(
        'ProgressController: Stats - Workouts: ${totalWorkouts.value}, Calories: ${totalCalories.value}, Streak: ${currentStreak.value}',
      );
    } catch (e) {
      debugPrint('Error loading progress data: $e');
      Get.snackbar(
        'Error',
        'Failed to load progress data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate total stats
  void _calculateStats() {
    final completedSessions = allSessions.where((s) => s.isCompleted).toList();

    totalWorkouts.value = completedSessions.length;
    totalCalories.value = completedSessions.fold(
      0,
      (sum, s) => sum + s.caloriesBurned,
    );
    totalMinutes.value = completedSessions.fold(
      0,
      (sum, s) => sum + (s.durationSeconds ~/ 60),
    );
  }

  // Calculate weekly workout data for chart
  void _calculateWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday

    // Reset weekly data
    weeklyWorkouts.value = [0, 0, 0, 0, 0, 0, 0];

    // Count workouts for each day of the week
    for (var session in allSessions.where((s) => s.isCompleted)) {
      final daysDiff = session.createdAt.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        weeklyWorkouts[daysDiff] =
            weeklyWorkouts[daysDiff] + (session.durationSeconds / 60);
      }
    }
  }

  // Calculate workout streak
  void _calculateStreak() {
    if (allSessions.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    final completedSessions = allSessions.where((s) => s.isCompleted).toList();
    if (completedSessions.isEmpty) {
      currentStreak.value = 0;
      return;
    }

    // Sort by date descending
    completedSessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var session in completedSessions) {
      final sessionDate = DateTime(
        session.createdAt.year,
        session.createdAt.month,
        session.createdAt.day,
      );

      final checkDateOnly = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      final diff = checkDateOnly.difference(sessionDate).inDays;

      if (diff == 0 || diff == 1) {
        streak++;
        checkDate = sessionDate;
      } else {
        break;
      }
    }

    currentStreak.value = streak;
  }

  // Load sessions for selected date
  void loadSessionsForDate(DateTime date) {
    selectedDate.value = date;

    final dateOnly = DateTime(date.year, date.month, date.day);

    selectedDateSessions.value = allSessions.where((session) {
      final sessionDate = DateTime(
        session.createdAt.year,
        session.createdAt.month,
        session.createdAt.day,
      );
      return sessionDate == dateOnly;
    }).toList();
  }

  // Get sessions for a specific date (for calendar markers)
  bool hasWorkoutOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return allSessions.any((session) {
      final sessionDate = DateTime(
        session.createdAt.year,
        session.createdAt.month,
        session.createdAt.day,
      );
      return sessionDate == dateOnly && session.isCompleted;
    });
  }

  // Format duration
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }

  // Format date
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return '${now.difference(date).inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadProgressData();
  }
}
