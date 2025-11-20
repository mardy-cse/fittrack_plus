# Controllers

## Purpose
This folder contains GetX controllers that manage state and business logic for the application.

Controllers handle user interactions, data manipulation, and communicate with services. They follow the reactive programming pattern using GetX observables.

## Structure
```
controllers/
├── auth/
│   ├── login_controller.dart
│   ├── register_controller.dart
│   └── forgot_password_controller.dart
├── home/
│   └── home_controller.dart
├── workout/
│   ├── workout_controller.dart
│   └── exercise_controller.dart
├── nutrition/
│   └── nutrition_controller.dart
├── progress/
│   └── progress_controller.dart
└── profile/
    └── profile_controller.dart
```

## Example Usage

```dart
class HomeController extends GetxController {
  // Observable variables
  final RxInt stepCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxList<Workout> workouts = <Workout>[].obs;
  
  // Services
  final WorkoutService _workoutService = Get.find();
  
  @override
  void onInit() {
    super.onInit();
    fetchWorkouts();
  }
  
  Future<void> fetchWorkouts() async {
    try {
      isLoading.value = true;
      workouts.value = await _workoutService.getWorkouts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch workouts');
    } finally {
      isLoading.value = false;
    }
  }
  
  void incrementSteps() {
    stepCount.value++;
  }
}
```

## In View

```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('Steps: ${controller.stepCount.value}'));
  }
}
```

## Best Practices
- Extend `GetxController` for lifecycle management
- Use `.obs` for reactive variables
- Use `Obx()` or `GetX<T>()` widgets to listen to changes
- Keep controllers focused on single responsibility
- Use services for data operations
- Handle errors gracefully with try-catch
- Clean up resources in `onClose()`
