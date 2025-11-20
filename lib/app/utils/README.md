# Utils

## Purpose
This folder contains utility classes, helper functions, validators, formatters, and constants used throughout the application.

Utils provide reusable functionality that doesn't fit into controllers or services.

## Structure
```
utils/
├── constants.dart           # App-wide constants
├── validators.dart          # Form validation functions
├── formatters.dart          # Date, number formatters
├── helpers.dart             # General helper functions
├── extensions.dart          # Dart extensions
├── enums.dart              # Enumerations
└── themes.dart             # Theme configurations
```

## Example Usage

### Constants
```dart
class AppConstants {
  static const String appName = 'FitTrack+';
  static const int maxWorkoutDuration = 300; // minutes
  static const List<String> workoutCategories = [
    'Strength',
    'Cardio',
    'Flexibility',
  ];
}
```

### Validators
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
```

### Formatters
```dart
class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
  
  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
```

### Extensions
```dart
extension StringExtensions on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension IntExtensions on int {
  String get pluralize {
    return this == 1 ? '' : 's';
  }
}
```

### Enums
```dart
enum WorkoutType {
  strength,
  cardio,
  flexibility,
  balance,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}
```

## Best Practices
- Keep utils stateless and pure functions
- Group related utilities together
- Use clear, descriptive names
- Add documentation comments
- Make constants type-safe
- Use extensions for common operations
- Keep validators consistent
- Handle edge cases properly
