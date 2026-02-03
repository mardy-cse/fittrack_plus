/// Helper class for workout animations
class WorkoutAnimationHelper {
  /// Get animation asset path based on exercise name
  static String getAnimationForExercise(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();

    if (lowerName.contains('plank') ||
        lowerName.contains('core') ||
        lowerName.contains('ab')) {
      return 'assets/animations/plank.json';
    } else if (lowerName.contains('push') ||
        lowerName.contains('chest') ||
        lowerName.contains('arm')) {
      return 'assets/animations/pushup.json';
    } else if (lowerName.contains('squat') ||
        lowerName.contains('leg') ||
        lowerName.contains('lunge')) {
      return 'assets/animations/squat.json';
    } else if (lowerName.contains('run') ||
        lowerName.contains('cardio') ||
        lowerName.contains('jog')) {
      return 'assets/animations/running.json';
    } else if (lowerName.contains('jump') ||
        lowerName.contains('jack') ||
        lowerName.contains('burpee')) {
      return 'assets/animations/jumping_jacks.json';
    } else {
      // Default animation
      return 'assets/animations/plank.json';
    }
  }

  /// Get animation based on workout category
  static String getAnimationForCategory(String category) {
    final lowerCategory = category.toLowerCase();

    if (lowerCategory.contains('cardio') || lowerCategory.contains('hiit')) {
      return 'assets/animations/running.json';
    } else if (lowerCategory.contains('strength') ||
        lowerCategory.contains('upper')) {
      return 'assets/animations/pushup.json';
    } else if (lowerCategory.contains('leg') ||
        lowerCategory.contains('lower')) {
      return 'assets/animations/squat.json';
    } else if (lowerCategory.contains('core') ||
        lowerCategory.contains('abs')) {
      return 'assets/animations/plank.json';
    } else {
      return 'assets/animations/plank.json';
    }
  }
}
