# Services

## Purpose
This folder contains service classes that handle external operations like API calls, Firebase operations, local storage, and third-party integrations.

Services act as the data layer between controllers and external data sources.

## Structure
```
services/
├── auth_service.dart          # Firebase Authentication
├── firestore_service.dart     # Firestore CRUD operations
├── storage_service.dart       # Firebase Storage (images, files)
├── notification_service.dart  # Local notifications
├── pedometer_service.dart     # Step tracking
├── preferences_service.dart   # SharedPreferences
└── video_service.dart         # Video player setup
```

## Example Usage

```dart
class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create
  Future<void> addWorkout(WorkoutModel workout) async {
    await _firestore
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toMap());
  }
  
  // Read
  Future<List<WorkoutModel>> getWorkouts(String userId) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs
        .map((doc) => WorkoutModel.fromMap(doc.data()))
        .toList();
  }
  
  // Update
  Future<void> updateWorkout(WorkoutModel workout) async {
    await _firestore
        .collection('workouts')
        .doc(workout.id)
        .update(workout.toMap());
  }
  
  // Delete
  Future<void> deleteWorkout(String workoutId) async {
    await _firestore
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }
  
  // Stream (real-time updates)
  Stream<List<WorkoutModel>> watchWorkouts(String userId) {
    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromMap(doc.data()))
            .toList());
  }
}
```

## Initialization

```dart
// In main.dart
Future<void> initServices() async {
  await Get.putAsync(() => FirestoreService().init());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => PreferencesService().init());
}
```

## Best Practices
- Extend `GetxService` for services that need lifecycle management
- Keep services stateless (no UI logic)
- Use async/await for asynchronous operations
- Handle errors and throw meaningful exceptions
- Return Streams for real-time data
- Use dependency injection via GetX
- Create single responsibility services
- Add proper error logging
