class AppConstants {
  // App Info
  static const String appName = 'FitTrack+';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String exercisesCollection = 'exercises';
  static const String nutritionCollection = 'nutrition';
  static const String progressCollection = 'progress';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String workoutImagesPath = 'workout_images';
  
  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String userIdKey = 'user_id';
  
  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 800);
  
  // Workout Categories
  static const List<String> workoutCategories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Balance',
    'HIIT',
    'Yoga',
    'Pilates',
    'CrossFit',
  ];
  
  // Exercise Muscle Groups
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Full Body',
  ];
  
  // Nutrition Goals
  static const List<String> nutritionGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintain Weight',
    'General Health',
  ];
}
