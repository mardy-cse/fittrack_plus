# Views

## Purpose
This folder contains the UI screens (pages) of the application. Each view represents a full screen that users navigate to.

Views use GetView<T> to access their respective controllers and should be stateless when possible.

## Structure
```
views/
├── splash/
│   └── splash_view.dart
├── auth/
│   ├── login_view.dart
│   ├── register_view.dart
│   └── forgot_password_view.dart
├── home/
│   └── home_view.dart
├── workout/
│   ├── workout_list_view.dart
│   ├── workout_detail_view.dart
│   └── add_workout_view.dart
├── exercise/
│   ├── exercise_library_view.dart
│   └── exercise_detail_view.dart
├── nutrition/
│   ├── nutrition_view.dart
│   └── add_meal_view.dart
├── progress/
│   └── progress_view.dart
└── profile/
    ├── profile_view.dart
    └── settings_view.dart
```

## Example Usage

```dart
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: controller.openNotifications,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsCard(),
              const SizedBox(height: 16),
              _buildWorkoutsList(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/workout/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => Text(
              '${controller.stepCount.value} steps',
              style: const TextStyle(fontSize: 24),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWorkoutsList() {
    return Obx(() => Column(
      children: controller.workouts
          .map((workout) => WorkoutCard(workout: workout))
          .toList(),
    ));
  }
}
```

## Using GetView

```dart
// GetView automatically finds the controller
class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    // Access controller without Get.find()
    return Text(controller.userName.value);
  }
}
```

## Navigation Examples

```dart
// Navigate to named route
Get.toNamed('/workout/detail', arguments: workoutId);

// Navigate and remove previous routes
Get.offAllNamed('/home');

// Navigate with transition
Get.to(() => ProfileView(), transition: Transition.fadeIn);

// Go back
Get.back();

// Get arguments
final workoutId = Get.arguments as String;
```

## Best Practices
- Use `GetView<T>` to automatically access controllers
- Keep views focused on UI presentation
- Extract complex widgets to separate methods or custom widgets
- Use `Obx()` for reactive UI updates
- Handle loading and error states
- Use `const` constructors when possible
- Keep build methods clean and readable
- Use responsive design patterns
- Follow Material Design guidelines
