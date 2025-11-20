import 'package:get/get.dart';
import '../models/workout.dart';
import '../models/user_profile.dart';
import '../services/workout_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class HomeController extends GetxController {
  final WorkoutService _workoutService = Get.find<WorkoutService>();
  final UserService _userService = Get.find<UserService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable variables
  final RxList<Workout> workouts = <Workout>[].obs;
  final RxList<Workout> filteredWorkouts = <Workout>[].obs;
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxString selectedLevel = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentNavIndex = 0.obs;

  // Stats
  final RxInt todaySteps = 0.obs;
  final RxInt todayCalories = 0.obs;
  final RxInt todayWorkouts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadWorkouts();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        final profile = await _userService.getUserProfile(uid);
        userProfile.value = profile;
      }
    } catch (e) {
      print('Error loading user profile: $e');
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
      filteredWorkouts.value =
          workouts.where((workout) => workout.level == level).toList();
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
    await Future.wait([
      loadUserProfile(),
      loadWorkouts(),
    ]);
  }
}
