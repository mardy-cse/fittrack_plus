# FitTrack+ App Workflow Documentation

## Table of Contents
1. [App Architecture](#app-architecture)
2. [Authentication Flow](#authentication-flow)
3. [Navigation Structure](#navigation-structure)
4. [Core Features Workflow](#core-features-workflow)
5. [Data Flow & State Management](#data-flow--state-management)
6. [Firebase Integration](#firebase-integration)
7. [Controllers & Services](#controllers--services)
8. [Key User Journeys](#key-user-journeys)

---

## App Architecture

### Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: GetX
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Architecture Pattern**: MVC with GetX
- **Navigation**: GetX Navigation

### Project Structure
```
lib/
├── app/
│   ├── bindings/        # Dependency injection
│   ├── controllers/     # Business logic & state management
│   ├── models/          # Data models
│   ├── services/        # API & business services
│   ├── views/           # UI screens
│   ├── widgets/         # Reusable UI components
│   ├── utils/           # Utilities & themes
│   └── routes/          # Route definitions
├── main.dart            # App entry point
└── firebase_options.dart
```

---

## Authentication Flow

### 1. App Startup
```
main.dart
  ├─> Firebase.initializeApp()
  ├─> Initialize Services (WorkoutService, AuthService, etc.)
  └─> Check Authentication State
       ├─> Logged In? → MainNavigationView (Home)
       └─> Not Logged In? → OnboardingView
```

### 2. Onboarding Flow
```
OnboardingView (3 screens)
  └─> Skip/Continue → LoginView
       ├─> Email/Password Login
       ├─> Google Sign In
       ├─> Phone Authentication
       └─> Email Link Authentication
            └─> Success → ProfileSetupView (if first time)
                 └─> Complete Profile → MainNavigationView
```

### 3. Profile Setup (First Time Users)
**4 Steps:**
1. **Personal Info**: Name, Age, Gender
2. **Body Metrics**: Height, Weight
3. **Fitness Goals**: Daily targets (steps, calories, workouts)
4. **Profile Photo**: Upload from camera/gallery

**Controller**: `ProfileSetupController`
- Validates each step
- Saves to Firestore (`users` collection)
- Creates UserProfile model

---

## Navigation Structure

### Bottom Navigation (MainNavigationView)
```
┌─────────────────────────────────────┐
│  Home  │ Progress │ Tools │ Profile │
└─────────────────────────────────────┘
```

**Managed by**: `HomeController.currentNavIndex`

### Screen Flow
```
Home Tab (index: 0)
  ├─> Today's Summary
  ├─> Quick Stats Card
  ├─> Workout Grid
  └─> Workout Card → WorkoutDetailView
                      └─> Start Workout → StartWorkoutView
                                          └─> Complete → Back to Home

Progress Tab (index: 1)
  ├─> Stats Cards (Workouts, Calories, Minutes)
  ├─> Weekly Activity Chart
  ├─> Recent Workouts List
  └─> Calendar View (Dialog)

Tools Tab (index: 2)
  ├─> BMI Calculator
  ├─> Water Tracker
  ├─> Calorie Calculator
  └─> AI Coach (Gemini)

Profile Tab (index: 3)
  ├─> User Info
  ├─> Settings
  ├─> Help & Support
  └─> Logout
```

---

## Core Features Workflow

### 🏋️ Workout Flow

#### 1. Browse Workouts (HomeTabView)
```dart
HomeController
  ├─> Loads 25+ workouts from WorkoutService
  ├─> Filters by level (All/Beginner/Intermediate/Advanced)
  └─> Displays in grid with images & details
```

#### 2. View Workout Details (WorkoutDetailView)
```dart
WorkoutDetailController
  ├─> Loads workout by ID
  ├─> Shows:
  │   ├─> Hero image with Lottie animation
  │   ├─> Duration, Level, Calories badges
  │   ├─> Description
  │   ├─> Exercise list (expandable)
  │   └─> Related workouts
  └─> Start Workout Button → Navigate to StartWorkoutView
```

#### 3. Start Workout (StartWorkoutView)
```dart
StartWorkoutController initialization:
  1. Create WorkoutSession in Firestore
     - workoutId, userId, startTime
     - isCompleted: false (initially)
  
  2. Start timer & exercise sequence:
     - Each exercise: 40 seconds
     - Rest between: 20 seconds
     - Text-to-Speech announces exercises
  
  3. Track in real-time:
     - totalSeconds (duration)
     - exercisesCompleted (count)
     - caloriesBurned (calculated)
  
  4. Display:
     - Current exercise with Lottie animation
     - Circular progress timer
     - Stats cards (Time, Exercises, Calories)
     - Control buttons (Play/Pause, Skip)
```

**Exercise Sequence:**
```
Exercise 1 (40s) → Rest (20s) → Exercise 2 (40s) → Rest (20s) → ... → Complete
```

#### 4. Complete Workout
```dart
_completeWorkout():
  1. Update WorkoutSession in Firestore:
     - endTime: DateTime.now()
     - isCompleted: true ⭐ (CRITICAL)
     - finalDuration, finalCalories, exercisesCompleted
  
  2. Save using set() with merge: true
     - Ensures all fields are properly saved
  
  3. Refresh ProgressController
     - Forces stats recalculation
     - Updates UI immediately
  
  4. Show completion screen:
     - ✓ Workout Complete! 🎉
     - Duration, Calories, Exercises count
     - Done button → Navigate back
```

**Backend Update:**
```dart
WorkoutLogService.updateWorkoutSession():
  await _firestore
    .collection('workout_sessions')
    .doc(sessionId)
    .set(updatedSession.toMap(), SetOptions(merge: true));
```

---

### 📊 Progress Tracking Flow

#### 1. Data Collection (Real-time)
```dart
ProgressController:
  onInit():
    1. Setup real-time listener
       - Watches Firestore 'workout_sessions' collection
       - Filters by userId
    
    2. On data change:
       - Updates allSessions list
       - Recalculates all stats
       - Updates UI reactively (Obx)
```

#### 2. Stats Calculation
```dart
_calculateStats():
  1. Filter completed sessions:
     - Only where isCompleted == true
  
  2. Calculate totals:
     - totalWorkouts: count of completed sessions
     - totalCalories: sum of caloriesBurned
     - totalMinutes: sum of durationSeconds / 60
  
  3. Update observable values:
     - UI auto-updates via Obx widgets
```

#### 3. Weekly Activity Chart
```dart
_calculateWeeklyData():
  1. Get current week (Mon-Sun)
  2. For each completed session:
     - Find which day it belongs to
     - Add duration to that day's total
  3. Result: [Mon, Tue, Wed, Thu, Fri, Sat, Sun] minutes array
  4. Display as bar chart using fl_chart
```

#### 4. Streak Calculation
```dart
_calculateStreak():
  1. Sort sessions by date (newest first)
  2. Start from today, count consecutive days with workouts
  3. Break on first gap
  4. Display: "🔥 X Day Streak"
```

---

### 🛠️ Tools Features

#### BMI Calculator
```dart
BMIController:
  1. Input: height (cm), weight (kg), age, gender
  2. Calculate: weight / (height/100)²
  3. Categories: Underweight, Normal, Overweight, Obese
  4. Shows color-coded result with recommendations
  5. Save to BMIRecord → Firestore
```

#### Water Tracker
```dart
WaterTrackerService:
  1. Daily goal: 8 glasses (2000ml)
  2. Track glasses consumed
  3. Calculate hydration percentage
  4. Visual: Wave animation & progress ring
  5. Reset daily at midnight
  6. Save to Firestore: water_intake/{userId}/logs/{date}
```

#### Calorie Calculator
```dart
CalorieController:
  Uses Harris-Benedict Equation:
  
  For Men:
    BMR = 88.362 + (13.397 × weight) + (4.799 × height) - (5.677 × age)
  
  For Women:
    BMR = 447.593 + (9.247 × weight) + (3.098 × height) - (4.330 × age)
  
  Activity Multipliers:
    - Sedentary: 1.2
    - Light: 1.375
    - Moderate: 1.55
    - Very Active: 1.725
    - Extra Active: 1.9
```

#### AI Coach (Gemini)
```dart
GeminiService:
  1. Collects user fitness data:
     - Profile info
     - Recent workouts
     - Progress stats
     - Water intake
  
  2. Sends to Google Gemini API
  
  3. Gets personalized advice:
     - Workout recommendations
     - Nutrition tips
     - Motivation
     - Goal adjustments
```

---

## Data Flow & State Management

### GetX Pattern

#### Controllers (Business Logic)
```dart
class HomeController extends GetxController {
  // Observable State
  final RxList<Workout> workouts = <Workout>[].obs;
  final RxInt todayWorkouts = 0.obs;
  
  // Lifecycle
  @override
  void onInit() {
    loadWorkouts();
    _syncProgressStats();
  }
  
  // Reactive Updates
  ever(progressController.totalWorkouts, (_) => _updateTodayStats());
}
```

#### Views (UI)
```dart
class HomeTabView extends GetView<HomeController> {
  // Reactive UI with Obx
  Obx(() => Text('${controller.todayWorkouts.value}'))
  
  // Auto-rebuilds when todayWorkouts changes
}
```

#### Bindings (Dependency Injection)
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressController>(() => ProgressController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

### State Synchronization

**Problem Solved**: Home screen shows today's data, Progress shows all-time data

```dart
// Home screen needs today's stats
HomeController._updateTodayStats():
  1. Get ProgressController (shared instance)
  2. Filter allSessions for today only
  3. Calculate today's workouts & calories
  4. Display in Today's Summary

// Progress screen shows totals
ProgressController._calculateStats():
  1. Filter all completed sessions
  2. Calculate total workouts, calories, minutes
  3. Display in stats cards
```

---

## Firebase Integration

### Collections Structure

```
Firestore Database:
│
├── users/
│   └── {userId}/
│       ├── email
│       ├── name
│       ├── age, gender
│       ├── height, weight
│       ├── dailyStepsGoal
│       ├── dailyCaloriesGoal
│       ├── dailyWorkoutsGoal
│       └── profileImageUrl
│
├── workout_sessions/
│   └── {sessionId}/
│       ├── userId
│       ├── workoutId
│       ├── workoutTitle
│       ├── startTime (Timestamp)
│       ├── endTime (Timestamp)
│       ├── durationSeconds
│       ├── caloriesBurned
│       ├── exercisesCompleted
│       ├── totalExercises
│       ├── isCompleted ⭐
│       ├── completedExercises []
│       └── createdAt (Timestamp)
│
├── bmi_records/
│   └── {userId}/
│       └── records/
│           └── {recordId}/
│               ├── height, weight
│               ├── bmi, category
│               └── timestamp
│
└── water_intake/
    └── {userId}/
        └── logs/
            └── {date}/
                ├── glassesConsumed
                ├── goalGlasses
                └── updatedAt
```

### Real-time Listeners

```dart
// Progress Controller watches workout sessions
_workoutLogService.watchUserWorkoutSessions(userId).listen((sessions) {
  allSessions.value = sessions;
  _calculateStats();
});

// Automatically updates when:
// - New workout completed
// - Existing session updated
// - Session deleted
```

### Query Patterns

```dart
// Get user's sessions
_firestore
  .collection('workout_sessions')
  .where('userId', isEqualTo: userId)
  .snapshots()

// Update session
_firestore
  .collection('workout_sessions')
  .doc(sessionId)
  .set(data, SetOptions(merge: true))
```

---

## Controllers & Services

### Key Controllers

| Controller | Responsibility |
|------------|---------------|
| **HomeController** | Workout list, navigation, today's stats sync |
| **ProgressController** | All-time stats, weekly chart, streak calculation |
| **StartWorkoutController** | Workout timer, exercise sequence, session tracking |
| **WorkoutDetailController** | Single workout details, related workouts |
| **ProfileSetupController** | 4-step onboarding, validation, user creation |
| **BMIController** | BMI calculation & history |
| **WaterTrackerController** | Daily water intake tracking |
| **CalorieController** | Calorie needs calculation |

### Key Services

| Service | Responsibility |
|---------|---------------|
| **AuthService** | Firebase Auth, login/logout, user state |
| **WorkoutService** | Load workout data from JSON |
| **WorkoutLogService** | CRUD for workout sessions in Firestore |
| **UserService** | User profile CRUD operations |
| **GeminiService** | AI coach integration with Google Gemini |
| **WaterTrackerService** | Water intake persistence |

---

## Key User Journeys

### Journey 1: New User Onboarding
```
1. User opens app (first time)
2. Sees 3 onboarding screens
3. Clicks "Get Started"
4. Chooses authentication method
5. Completes login/signup
6. Directed to Profile Setup (4 steps)
7. Fills personal info → Next
8. Enters body metrics → Next
9. Sets daily goals → Next
10. Uploads profile photo → Complete
11. Lands on Home screen
```

### Journey 2: Complete a Workout
```
1. User taps workout card on Home
2. Views workout details & animations
3. Taps "Start Workout"
4. Follows exercise timer (40s exercise, 20s rest)
5. Completes all exercises
6. Sees "Workout Complete! 🎉" screen
7. Taps "Done"
8. Returns to Home
9. Sees updated stats:
   - Today's Summary: +1 workout, +15 calories
   - Progress tab: Updated totals & chart
```

### Journey 3: Track Progress
```
1. User navigates to Progress tab
2. Views stats cards:
   - Total workouts
   - Total calories burned
   - Total minutes exercised
3. Sees weekly activity chart
4. Scrolls to Recent Workouts
5. Taps calendar icon
6. Views calendar with workout markers
7. Selects a date
8. Sees all workouts from that day
```

### Journey 4: Use AI Coach
```
1. User navigates to Tools tab
2. Taps "AI Fitness Coach"
3. Types question: "What workout should I do today?"
4. AI analyzes:
   - User's fitness level
   - Recent workout history
   - Goals
5. Receives personalized recommendation
6. Can directly start recommended workout
```

---

## Critical Data Points

### Workout Completion Requirements
For a workout to count in Progress stats:

✅ **MUST HAVE:**
1. `isCompleted: true` in Firestore
2. `endTime` set
3. `caloriesBurned > 0`
4. `durationSeconds > 0`

❌ **Common Issues:**
- Session saved but `isCompleted` still false
- Using `update()` instead of `set(merge: true)`
- ProgressController not refreshing after completion

### Stats Calculation Logic
```dart
// Only completed sessions count
final completedSessions = allSessions.where((s) => s.isCompleted);

totalWorkouts = completedSessions.length;
totalCalories = sum of caloriesBurned;
totalMinutes = sum of durationSeconds / 60;
```

---

## Debugging Workflow

### When Progress Stats Don't Update

**Check in order:**

1. **Console Logs** (after workout completion):
   ```
   ✅ Workout session updated successfully in Firestore
   ✅ Progress controller refreshed
   📊 ProgressController._calculateStats: Total sessions: X, Completed sessions: Y
   ```

2. **Firestore Console**:
   - Open workout_sessions collection
   - Find the session
   - Verify `isCompleted: true`

3. **Real-time Listener**:
   ```
   ProgressController: Real-time update - X sessions
   Session: Morning Yoga Flow, isCompleted: true, calories: 15
   ```

4. **Stats Calculation**:
   ```
   📈 Final Stats: Workouts: 1, Calories: 15, Minutes: 5
   ```

### Common Fixes

| Issue | Solution |
|-------|----------|
| Stats show 0 | Check `isCompleted` flag in Firestore |
| Today's data wrong | Verify date filtering in `_updateTodayStats()` |
| UI not updating | Ensure using `Obx()` widgets |
| Controller not found | Check binding initialization |

---

## Performance Optimizations

### 1. Lazy Loading
```dart
Get.lazyPut<ProgressController>(() => ProgressController(), fenix: true);
// Only creates controller when needed
// fenix: true allows recreation if disposed
```

### 2. Stream Subscriptions
```dart
// Cleanup on controller disposal
@override
void onClose() {
  _sessionsSubscription?.cancel();
  super.onClose();
}
```

### 3. Efficient Queries
```dart
// Client-side filtering (no compound indexes needed)
final snapshot = await _firestore
  .collection('workout_sessions')
  .where('userId', isEqualTo: userId)
  .get();

// Sort in memory
sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
```

---

## Future Enhancements

### Planned Features
- [ ] Social features (share workouts, challenges)
- [ ] Offline mode with local caching
- [ ] Wearable device integration
- [ ] Advanced analytics & insights
- [ ] Custom workout creator
- [ ] Nutrition meal planner
- [ ] Integration with health apps (Apple Health, Google Fit)

---

## Appendix: Key Files Reference

### Entry Points
- `main.dart` - App initialization
- `lib/app/routes/app_pages.dart` - Route definitions

### Core Controllers
- `home_controller.dart` - Main screen logic
- `progress_controller.dart` - Progress tracking
- `start_workout_controller.dart` - Workout execution

### Core Services
- `workout_log_service.dart` - Session persistence
- `auth_service.dart` - Authentication
- `workout_service.dart` - Workout data loading

### Models
- `workout.dart` - Workout data structure
- `workout_session.dart` - Workout session with isCompleted flag
- `user_profile.dart` - User information

### UI Views
- `main_navigation_view.dart` - Bottom navigation
- `home_tab_view.dart` - Home screen
- `progress_tab_view.dart` - Progress tracking screen
- `start_workout_view.dart` - Active workout screen

---

## Support & Troubleshooting

**Debug Mode**: Enable detailed logging
```dart
debugPrint() calls throughout the app provide:
- Controller lifecycle events
- Firestore operations
- Stats calculations
- Navigation events
```

**Firebase Console**: 
- Authentication logs
- Firestore data inspection
- Real-time database monitoring

**GetX DevTools**: 
- Controller state inspection
- Dependency tree visualization
- Performance monitoring

---

**Last Updated**: February 9, 2026  
**Version**: 1.0.0  
**Developer**: FitTrack+ Team
