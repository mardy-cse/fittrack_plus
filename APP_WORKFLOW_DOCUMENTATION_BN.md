# FitTrack+ অ্যাপ ওয়ার্কফ্লো ডকুমেন্টেশন (বাংলা)

## সূচিপত্র
1. [অ্যাপ আর্কিটেকচার](#অ্যাপ-আর্কিটেকচার)
2. [অথেন্টিকেশন ফ্লো](#অথেন্টিকেশন-ফ্লো)
3. [নেভিগেশন স্ট্রাকচার](#নেভিগেশন-স্ট্রাকচার)
4. [মূল ফিচারগুলির ওয়ার্কফ্লো](#মূল-ফিচারগুলির-ওয়ার্কফ্লো)
5. [ডেটা ফ্লো এবং স্টেট ম্যানেজমেন্ট](#ডেটা-ফ্লো-এবং-স্টেট-ম্যানেজমেন্ট)
6. [Firebase ইন্টিগ্রেশন](#firebase-ইন্টিগ্রেশন)
7. [গুরুত্বপূর্ণ পয়েন্ট](#গুরুত্বপূর্ণ-পয়েন্ট)

---

## অ্যাপ আর্কিটেকচার

### টেক স্ট্যাক
- **ফ্রেমওয়ার্ক**: Flutter (Dart)
- **স্টেট ম্যানেজমেন্ট**: GetX
- **ব্যাকএন্ড**: Firebase (Firestore, Auth, Storage)
- **আর্কিটেকচার প্যাটার্ন**: MVC with GetX

### প্রজেক্ট স্ট্রাকচার
```
lib/
├── app/
│   ├── bindings/        # Dependency injection
│   ├── controllers/     # Business logic ও state management
│   ├── models/          # Data models
│   ├── services/        # API ও business services
│   ├── views/           # UI screens
│   ├── widgets/         # Reusable UI components
│   └── utils/           # Utilities ও themes
└── main.dart            # App entry point
```

---

## অথেন্টিকেশন ফ্লো

### ১. অ্যাপ স্টার্টআপ
```
main.dart
  ├─> Firebase Initialize
  ├─> সব Services Initialize (WorkoutService, AuthService, etc.)
  └─> Authentication চেক করা
       ├─> Logged In? → MainNavigationView (Home)
       └─> Not Logged In? → OnboardingView
```

### ২. অনবোর্ডিং ফ্লো
```
OnboardingView (৩টি স্ক্রিন)
  └─> Skip/Continue → LoginView
       ├─> Email/Password Login
       ├─> Google Sign In
       ├─> Phone Authentication
       └─> Email Link Authentication
            └─> Success → ProfileSetupView (প্রথমবার হলে)
                 └─> Profile Complete → MainNavigationView
```

### ৩. প্রোফাইল সেটআপ (নতুন ইউজার)
**৪টি ধাপ:**
1. **Personal Info**: নাম, বয়স, লিঙ্গ
2. **Body Metrics**: উচ্চতা, ওজন
3. **Fitness Goals**: দৈনিক লক্ষ্য (steps, calories, workouts)
4. **Profile Photo**: ক্যামেরা/গ্যালারি থেকে আপলোড

---

## নেভিগেশন স্ট্রাকচার

### বটম নেভিগেশন
```
┌─────────────────────────────────────┐
│  Home  │ Progress │ Tools │ Profile │
└─────────────────────────────────────┘
```

**পরিচালনা**: `HomeController.currentNavIndex`

### স্ক্রিন ফ্লো
```
Home Tab (index: 0)
  ├─> Today's Summary (আজকের সামারি)
  ├─> Quick Stats Card
  ├─> Workout Grid (সব workouts)
  └─> Workout Card ক্লিক → WorkoutDetailView
                            └─> Start Workout → StartWorkoutView
                                                └─> Complete → Home-এ ফিরে যাওয়া

Progress Tab (index: 1)
  ├─> Stats Cards (Workouts, Calories, Minutes)
  ├─> Weekly Activity Chart
  ├─> Recent Workouts List
  └─> Calendar View

Tools Tab (index: 2)
  ├─> BMI Calculator
  ├─> Water Tracker
  ├─> Calorie Calculator
  └─> AI Coach (Gemini)

Profile Tab (index: 3)
  ├─> User Info
  ├─> Settings
  └─> Logout
```

---

## মূল ফিচারগুলির ওয়ার্কফ্লো

### 🏋️ Workout ফ্লো (বিস্তারিত)

#### ১. Workout ব্রাউজ করা (HomeTabView)
```dart
HomeController:
  ├─> WorkoutService থেকে ২৫+ workouts লোড করা
  ├─> Level অনুযায়ী ফিল্টার (All/Beginner/Intermediate/Advanced)
  └─> Grid-এ দেখানো (ছবি ও details সহ)
```

#### ২. Workout Details দেখা (WorkoutDetailView)
```dart
WorkoutDetailController:
  ├─> ID অনুযায়ী workout লোড
  ├─> দেখায়:
  │   ├─> Hero image + Lottie animation
  │   ├─> Duration, Level, Calories badges
  │   ├─> বিবরণ (Description)
  │   ├─> Exercise list (expandable)
  │   └─> Related workouts
  └─> Start Workout Button → StartWorkoutView-তে যাওয়া
```

#### ৩. Workout শুরু করা (StartWorkoutView)

**StartWorkoutController Initialization:**

```dart
১. Firestore-এ WorkoutSession তৈরি:
   - workoutId, userId, startTime
   - isCompleted: false (শুরুতে)
   - sessionId পাওয়া যায়

২. Timer ও exercise sequence শুরু:
   - প্রতিটি exercise: ৪০ সেকেন্ড
   - বিশ্রাম: ২০ সেকেন্ড
   - Text-to-Speech exercises announce করে

৩. Real-time ট্র্যাকিং:
   - totalSeconds (সময়কাল)
   - exercisesCompleted (সংখ্যা)
   - caloriesBurned (ক্যালোরি গণনা)

৪. স্ক্রিনে দেখায়:
   - বর্তমান exercise + Lottie animation
   - Circular progress timer
   - Stats cards (Time, Exercises, Calories)
   - Control buttons (Play/Pause, Skip)
```

**Exercise Sequence:**
```
Exercise 1 (৪০s) → Rest (২০s) → Exercise 2 (৪০s) → Rest (২০s) → ... → Complete
```

#### ৪. Workout Complete করা

```dart
_completeWorkout():
  
  ১. Firestore-এ WorkoutSession আপডেট:
     - endTime: DateTime.now()
     - isCompleted: true ⭐ (সবচেয়ে গুরুত্বপূর্ণ!)
     - durationSeconds: মোট সময়
     - caloriesBurned: মোট ক্যালোরি
     - exercisesCompleted: সম্পন্ন exercise সংখ্যা
  
  ২. set() with merge: true ব্যবহার করে save:
     - সব fields ঠিকমত save হয় ensure করে
  
  ৩. ProgressController refresh করা:
     - Stats পুনরায় calculate করা
     - UI তৎক্ষণাৎ আপডেট হয়
  
  ৪. Completion screen দেখানো:
     - ✓ Workout Complete! 🎉
     - Duration, Calories, Exercises count
     - Done button → আগের পেজে ফিরে যাওয়া
```

**ব্যাকএন্ড আপডেট কোড:**
```dart
// workout_log_service.dart
await _firestore
  .collection('workout_sessions')
  .doc(sessionId)
  .set(updatedSession.toMap(), SetOptions(merge: true));
```

---

### 📊 Progress Tracking ফ্লো

#### ১. Real-time Data Collection

```dart
ProgressController.onInit():
  
  ১. Real-time listener সেটআপ:
     - Firestore 'workout_sessions' collection watch করে
     - শুধু userId মিলে এমন sessions
  
  ২. Data পরিবর্তন হলে:
     - allSessions list আপডেট
     - সব stats পুনরায় calculate
     - UI automatically আপডেট (Obx এর মাধ্যমে)
```

#### ২. Stats Calculation (গণনা)

```dart
_calculateStats():
  
  ১. Completed sessions ফিল্টার:
     - শুধু যেগুলো isCompleted == true
  
  ২. মোট হিসাব:
     - totalWorkouts: completed sessions এর সংখ্যা
     - totalCalories: caloriesBurned এর যোগফল
     - totalMinutes: durationSeconds এর যোগফল ÷ ৬০
  
  ৩. Observable values আপডেট:
     - UI স্বয়ংক্রিয়ভাবে আপডেট হয় (Obx widgets)
```

#### ৩. Weekly Activity Chart

```dart
_calculateWeeklyData():
  ১. বর্তমান সপ্তাহ নির্ধারণ (Mon-Sun)
  ২. প্রতিটি completed session এর জন্য:
     - কোন দিনের তা খুঁজে বের করা
     - সেই দিনের total-এ যোগ করা
  ৩. ফলাফল: [Mon, Tue, Wed, Thu, Fri, Sat, Sun] minutes array
  ৪. Bar chart হিসেবে দেখানো (fl_chart package)
```

#### ৪. Streak Calculation (ধারাবাহিকতা)

```dart
_calculateStreak():
  ১. Sessions তারিখ অনুযায়ী সাজানো (নতুন আগে)
  ২. আজ থেকে শুরু করে পরপর দিনে workouts গণনা
  ৩. প্রথম gap এ থামানো
  ৪. দেখানো: "🔥 X Day Streak"
```

---

### 🛠️ Tools Features

#### BMI Calculator
```
১. Input: উচ্চতা (cm), ওজন (kg), বয়স, লিঙ্গ
২. Calculation: ওজন / (উচ্চতা/১০০)²
৩. Categories: Underweight, Normal, Overweight, Obese
৪. রঙিন result + recommendations
৫. Firestore-এ save (BMIRecord)
```

#### Water Tracker
```
১. দৈনিক লক্ষ্য: ৮ গ্লাস (২০০০ml)
২. গ্লাস গণনা
৩. Hydration percentage হিসাব
৪. Wave animation ও progress ring
৫. মধ্যরাতে reset
৬. Firestore: water_intake/{userId}/logs/{date}
```

#### AI Coach (Gemini)
```
১. User এর fitness data সংগ্রহ:
   - Profile info
   - সাম্প্রতিক workouts
   - Progress stats
   
২. Google Gemini API-তে পাঠানো

৩. Personalized পরামর্শ পাওয়া:
   - Workout সুপারিশ
   - Nutrition tips
   - Motivation
   - Goal adjustments
```

---

## ডেটা ফ্লো এবং স্টেট ম্যানেজমেন্ট

### GetX Pattern

#### Controllers (Business Logic)
```dart
class HomeController extends GetxController {
  // Observable State (পর্যবেক্ষণযোগ্য State)
  final RxList<Workout> workouts = <Workout>[].obs;
  final RxInt todayWorkouts = 0.obs;
  
  // Lifecycle
  @override
  void onInit() {
    loadWorkouts();
    _syncProgressStats();
  }
  
  // Reactive Updates
  // totalWorkouts পরিবর্তন হলে automatically _updateTodayStats() কল হয়
  ever(progressController.totalWorkouts, (_) => _updateTodayStats());
}
```

#### Views (UI)
```dart
class HomeTabView extends GetView<HomeController> {
  // Reactive UI with Obx
  // todayWorkouts পরিবর্তন হলে automatically rebuild হয়
  Obx(() => Text('${controller.todayWorkouts.value}'))
}
```

#### Bindings (Dependency Injection)
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // ProgressController আগে initialize (কারণ HomeController এর উপর নির্ভরশীল)
    Get.lazyPut<ProgressController>(() => ProgressController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

### State Synchronization (সমন্বয়)

**সমস্যা**: Home screen-এ আজকের data, Progress screen-এ সব সময়ের data

**সমাধান:**

```dart
// Home screen: শুধু আজকের stats
HomeController._updateTodayStats():
  ১. ProgressController get করা (shared instance)
  ২. আজকের জন্য allSessions filter করা
  ৩. আজকের workouts ও calories হিসাব
  ৪. Today's Summary-তে দেখানো

// Progress screen: মোট stats
ProgressController._calculateStats():
  ১. সব completed sessions filter করা
  ২. মোট workouts, calories, minutes হিসাব
  ৩. Stats cards-এ দেখানো
```

---

## Firebase ইন্টিগ্রেশন

### Collections Structure (কালেকশন স্ট্রাকচার)

```
Firestore Database:
│
├── users/                          # ইউজার তথ্য
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
├── workout_sessions/               # ওয়ার্কআউট সেশন
│   └── {sessionId}/
│       ├── userId
│       ├── workoutId
│       ├── workoutTitle
│       ├── startTime (Timestamp)
│       ├── endTime (Timestamp)
│       ├── durationSeconds
│       ├── caloriesBurned
│       ├── exercisesCompleted
│       ├── isCompleted ⭐ (সবচেয়ে গুরুত্বপূর্ণ!)
│       └── createdAt
│
├── bmi_records/                    # BMI রেকর্ড
│   └── {userId}/
│       └── records/
│
└── water_intake/                   # পানি সেবন
    └── {userId}/
        └── logs/
            └── {date}/
```

### Real-time Listeners (রিয়েল-টাইম আপডেট)

```dart
// ProgressController workout sessions watch করে
_workoutLogService.watchUserWorkoutSessions(userId).listen((sessions) {
  allSessions.value = sessions;
  _calculateStats();
});

// Automatically আপডেট হয় যখন:
// - নতুন workout complete হয়
// - বিদ্যমান session আপডেট হয়
// - Session delete হয়
```

---

## গুরুত্বপূর্ণ পয়েন্ট

### Workout Complete হওয়ার Requirements

Progress stats-এ workout count হওয়ার জন্য **অবশ্যই দরকার:**

✅ **MUST HAVE:**
1. `isCompleted: true` Firestore-এ
2. `endTime` set থাকতে হবে
3. `caloriesBurned > 0`
4. `durationSeconds > 0`

❌ **সাধারণ সমস্যা:**
- Session save হয়েছে কিন্তু `isCompleted` এখনো false
- `update()` ব্যবহার করা হয়েছে `set(merge: true)` এর বদলে
- ProgressController workout complete এর পরে refresh হচ্ছে না

### Stats Calculation Logic

```dart
// শুধু completed sessions count হয়
final completedSessions = allSessions.where((s) => s.isCompleted);

totalWorkouts = completedSessions.length;        // সংখ্যা
totalCalories = sum of caloriesBurned;           // যোগফল
totalMinutes = sum of durationSeconds / 60;      // মিনিটে
```

---

## Debugging Workflow (সমস্যা সমাধান)

### যখন Progress Stats আপডেট হয় না

**ক্রমানুসারে চেক করুন:**

#### ১. Console Logs (workout complete এর পরে):
```
✅ Workout session updated successfully in Firestore
✅ Progress controller refreshed
📊 ProgressController._calculateStats: Total sessions: X, Completed sessions: Y
```

#### ২. Firestore Console:
- workout_sessions collection খুলুন
- Session খুঁজুন
- যাচাই করুন: `isCompleted: true` আছে কিনা

#### ৩. Real-time Listener:
```
ProgressController: Real-time update - X sessions
Session: Morning Yoga Flow, isCompleted: true, calories: 15
```

#### ৪. Stats Calculation:
```
📈 Final Stats: Workouts: 1, Calories: 15, Minutes: 5
```

### সাধারণ সমাধান

| সমস্যা | সমাধান |
|--------|---------|
| Stats 0 দেখাচ্ছে | Firestore-এ `isCompleted` flag চেক করুন |
| আজকের data ভুল | `_updateTodayStats()` এ date filtering যাচাই করুন |
| UI আপডেট হচ্ছে না | `Obx()` widgets ব্যবহার করছেন কিনা দেখুন |
| Controller পাওয়া যাচ্ছে না | Binding initialization চেক করুন |

---

## প্রধান User Journeys

### Journey ১: নতুন ইউজার
```
১. অ্যাপ খুলুন (প্রথমবার)
২. ৩টি onboarding স্ক্রিন দেখুন
৩. "Get Started" ক্লিক করুন
৪. Login/Signup করুন
৫. Profile Setup (৪ ধাপ)
   - Personal Info → Body Metrics → Goals → Photo
৬. Home screen-এ পৌঁছান
```

### Journey ২: Workout Complete করা
```
১. Home-এ workout card ট্যাপ করুন
২. Details দেখুন
৩. "Start Workout" ট্যাপ করুন
৪. Exercise timer follow করুন (৪০s exercise, ২০s rest)
৫. সব exercises শেষ করুন
৬. "Workout Complete! 🎉" screen দেখুন
৭. "Done" ট্যাপ করুন
৮. Home-এ ফিরে যান
৯. আপডেট stats দেখুন:
   - Today's Summary: +১ workout, +১৫ calories
   - Progress tab: আপডেট totals ও chart
```

### Journey ৩: Progress Track করা
```
১. Progress tab-এ যান
২. Stats cards দেখুন (Workouts, Calories, Minutes)
৩. Weekly chart দেখুন
৪. Recent Workouts scroll করুন
৫. Calendar icon ট্যাপ করুন
৬. Workout markers সহ calendar দেখুন
৭. একটি তারিখ select করুন
৮. সেই দিনের সব workouts দেখুন
```

---

## কোড রেফারেন্স (প্রধান ফাইল)

### Entry Points
- `main.dart` - অ্যাপ initialization
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
- `workout_session.dart` - Session model (isCompleted flag সহ)
- `user_profile.dart` - User information

### UI Views
- `main_navigation_view.dart` - Bottom navigation
- `home_tab_view.dart` - Home screen
- `progress_tab_view.dart` - Progress screen
- `start_workout_view.dart` - Active workout screen

---

## সংক্ষিপ্ত সারাংশ

### কীভাবে পুরো অ্যাপ কাজ করে:

1. **User Login করে** → Firebase Auth
2. **Profile Setup করে** → Firestore `users` collection
3. **Workout শুরু করে** → `StartWorkoutController`
   - Firestore-এ session তৈরি (`isCompleted: false`)
   - Timer চালু হয়
   - Exercises একের পর এক
4. **Workout শেষ করে** → Firestore আপডেট (`isCompleted: true`)
5. **Stats Update হয়** → `ProgressController` real-time listen করে
   - Completed sessions filter করে
   - Stats calculate করে
   - UI আপডেট হয়
6. **Progress দেখে** → Charts, Stats, History

### মূল Key Point:

**`isCompleted: true`** - এটাই নির্ধারণ করে একটা workout count হবে কিনা!

---

**শেষ আপডেট**: ৯ ফেব্রুয়ারি, ২০২৬  
**সংস্করণ**: ১.০.০
