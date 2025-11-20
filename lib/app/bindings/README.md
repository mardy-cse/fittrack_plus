# Bindings

## Purpose
This folder contains GetX bindings that manage dependency injection for controllers and services.

Bindings are used to instantiate controllers when a route is accessed, ensuring proper lifecycle management and memory efficiency.

## Structure
```
bindings/
├── home_binding.dart
├── auth_binding.dart
├── workout_binding.dart
└── profile_binding.dart
```

## Example Usage

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<WorkoutService>(() => WorkoutService());
  }
}
```

## How to Use
1. Create a binding class that extends `Bindings`
2. Override the `dependencies()` method
3. Use `Get.lazyPut()` or `Get.put()` to inject dependencies
4. Attach binding to route in GetPage configuration

```dart
GetPage(
  name: '/home',
  page: () => HomeView(),
  binding: HomeBinding(),
)
```

## Best Practices
- Use `lazyPut` for controllers that aren't immediately needed
- Use `put` for services that should be initialized immediately
- Group related dependencies in the same binding
- Keep bindings lightweight and focused
