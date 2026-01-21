import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import '../services/steps_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class StepsController extends GetxController {
  final StepsService _stepsService = Get.find<StepsService>();
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  // Observable variables
  final RxInt todaySteps = 0.obs;
  final RxInt weeklyTotal = 0.obs;
  final RxInt weeklyAverage = 0.obs;
  final RxList<int> weeklySummary = <int>[0, 0, 0, 0, 0, 0, 0].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Step goal
  final RxInt dailyGoal = 10000.obs; // Default 10k steps

  // Pedometer stream subscriptions
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  // Pedestrian status
  final RxString pedestrianStatus = 'stopped'.obs;

  // Initial step count (when app starts)
  int? _initialStepCount;
  DateTime? _lastSaveTime;

  @override
  void onInit() {
    super.onInit();
    _initializePedometer();
    _loadTodaySteps();
    _loadWeeklySummary();
  }

  @override
  void onClose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    super.onClose();
  }

  // Initialize pedometer stream
  void _initializePedometer() {
    try {
      // Listen to step count stream
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      // Listen to pedestrian status
      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );
    } catch (e) {
      // Silent fail for emulator
      errorMessage.value = 'Emulator Mode - Use "Add Steps" button';
      _loadTodaySteps();
    }
  }

  // Handle step count updates
  void _onStepCount(StepCount event) {
    // On first load, store initial count
    if (_initialStepCount == null) {
      _initialStepCount = event.steps;
      return;
    }

    // Calculate steps since app started
    final stepsSinceStart = event.steps - _initialStepCount!;

    // Update today's steps
    todaySteps.value = stepsSinceStart;

    // Auto-save every 10 steps or every 60 seconds
    final now = DateTime.now();
    final shouldSave =
        todaySteps.value % 10 == 0 ||
        _lastSaveTime == null ||
        now.difference(_lastSaveTime!).inSeconds >= 60;

    if (shouldSave) {
      _saveStepsToFirestore();
      _lastSaveTime = now;
    }

    errorMessage.value = '';
  }

  // Handle step count errors
  void _onStepCountError(error) {
    // Silent handling - no error logs for emulator
    if (error.toString().contains('not available')) {
      errorMessage.value = 'Emulator Mode - Use "Add Steps" button';
    } else {
      errorMessage.value = 'Step counter unavailable';
    }

    // Fallback: load from Firestore
    _loadTodaySteps();
  }

  // Handle pedestrian status changes
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    pedestrianStatus.value = event.status.toLowerCase();
  }

  // Handle pedestrian status errors
  void _onPedestrianStatusError(error) {
    // Silent fail - emulator doesn't support this
  }

  // Save steps to Firestore
  Future<void> _saveStepsToFirestore() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      await _stepsService.saveDailySteps(
        userId: userId,
        steps: todaySteps.value,
      );
    } catch (e) {
      debugPrint('❌ Failed to save steps: $e');
    }
  }

  // Load today's steps from Firestore
  Future<void> _loadTodaySteps() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      final steps = await _stepsService.getStepsForDate(userId: userId);

      // Only update if pedometer hasn't started yet
      if (_initialStepCount == null) {
        todaySteps.value = steps;
      }
    } catch (e) {
      debugPrint('❌ Failed to load today steps: $e');
    }
  }

  // Load weekly summary
  Future<void> _loadWeeklySummary() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      isLoading.value = true;

      // Get weekly data
      final summary = await _stepsService.getWeeklySummary(userId: userId);
      final total = await _stepsService.getWeeklyTotal(userId: userId);
      final average = await _stepsService.getWeeklyAverage(userId: userId);

      // Update observables
      weeklySummary.value = summary;
      weeklyTotal.value = total;
      weeklyAverage.value = average;
    } catch (e) {
      debugPrint('❌ Failed to load weekly summary: $e');
      errorMessage.value = 'Failed to load weekly data';
    } finally {
      isLoading.value = false;
    }
  }

  // Manually refresh all data
  Future<void> refreshData() async {
    await Future.wait([_loadTodaySteps(), _loadWeeklySummary()]);
  }

  // Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (dailyGoal.value == 0) return 0.0;
    final progress = todaySteps.value / dailyGoal.value;
    return progress.clamp(0.0, 1.0);
  }

  // Check if goal is reached
  bool get isGoalReached => todaySteps.value >= dailyGoal.value;

  // Get remaining steps to goal
  int get stepsToGoal {
    final remaining = dailyGoal.value - todaySteps.value;
    return remaining > 0 ? remaining : 0;
  }

  // Update daily goal
  void updateDailyGoal(int newGoal) async {
    if (newGoal > 0 && newGoal <= 100000) {
      dailyGoal.value = newGoal;
      // Save goal to user profile
      try {
        final userId = _authService.currentUserId;
        if (userId != null) {
          await _userService.updateUserFields(userId, {
            'dailyStepGoal': newGoal,
          });
        }
      } catch (e) {
        debugPrint('Failed to save step goal: $e');
      }
    }
  }

  // Get steps for specific date
  Future<int> getStepsForDate(DateTime date) async {
    final userId = _authService.currentUserId;
    if (userId == null) return 0;

    return await _stepsService.getStepsForDate(userId: userId, date: date);
  }

  // Reset pedometer (for testing)
  void resetPedometer() {
    _initialStepCount = null;
    todaySteps.value = 0;
    errorMessage.value = '';
  }

  // Add manual steps (for emulator testing)
  void addManualSteps(int steps) {
    todaySteps.value += steps;
    _saveStepsToFirestore();
    _loadWeeklySummary();
  }
}
