# FitTrack+ Visual Workflow Diagrams

This document contains visual representations of key workflows in FitTrack+.

---

## 1. Complete App Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          APP STARTUP                                │
│                         (main.dart)                                 │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                   ┌─────────▼────────┐
                   │  Firebase Init   │
                   │  Services Init   │
                   └─────────┬────────┘
                             │
                   ┌─────────▼────────┐
                   │ Authentication?  │
                   └─────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │                             │
         NO   ▼                        YES  ▼
    ┌──────────────────┐         ┌──────────────────┐
    │ OnboardingView   │         │ Profile Exists?  │
    │ (3 screens)      │         └────────┬─────────┘
    └────────┬─────────┘                  │
             │                  ┌─────────┼────────┐
             ▼                  │                  │
    ┌──────────────────┐   NO   ▼            YES  ▼
    │   LoginView      │  ┌──────────────┐  ┌──────────────┐
    │  - Email/Pass    │  │ ProfileSetup │  │ HomeScreen   │
    │  - Google        │  │  (4 steps)   │  │ (Main Nav)   │
    │  - Phone         │  └──────┬───────┘  └──────────────┘
    │  - Email Link    │         │
    └────────┬─────────┘         │
             │                   │
             └───────────────────┘
                      │
                      ▼
             ┌──────────────────┐
             │   HomeScreen     │
             │  (Main Nav)      │
             └──────────────────┘
```

---

## 2. Workout Execution Flow

```
         ┌─────────────────┐
         │  HomeTabView    │
         │  (Browse)       │
         └────────┬────────┘
                  │ User selects workout
                  ▼
         ┌─────────────────┐
         │ WorkoutDetail   │
         │ View            │
         │ - Image         │
         │ - Details       │
         │ - Exercises     │
         └────────┬────────┘
                  │ Taps "Start Workout"
                  ▼
         ┌─────────────────────────────────────┐
         │   StartWorkoutController.onInit()   │
         │                                     │
         │  1. Create WorkoutSession:          │
         │     - workoutId, userId             │
         │     - startTime = now               │
         │     - isCompleted = FALSE           │
         │     ↓ Save to Firestore             │
         │     ↓ Get sessionId                 │
         │                                     │
         │  2. Start Timer & Sequence          │
         └────────┬────────────────────────────┘
                  │
                  ▼
    ┌─────────────────────────────────────────────┐
    │         Exercise Sequence Loop              │
    │                                             │
    │  FOR each exercise:                         │
    │    ┌──────────────────────┐                │
    │    │  Exercise (40s)      │                │
    │    │  - TTS announces     │                │
    │    │  - Show animation    │                │
    │    │  - Update timer      │                │
    │    └──────────┬───────────┘                │
    │               │                             │
    │               ▼                             │
    │    ┌──────────────────────┐                │
    │    │  Rest (20s)          │                │
    │    │  - Orange theme      │                │
    │    │  - Countdown         │                │
    │    └──────────┬───────────┘                │
    │               │                             │
    │               │ exercisesCompleted++        │
    │               └──────────────┐              │
    │                              │              │
    └──────────────────────────────┼──────────────┘
                                   │
                         All exercises done?
                                   │
                                   ▼ YES
              ┌────────────────────────────────────┐
              │  _completeWorkout()                │
              │                                    │
              │  1. Stop timer                     │
              │  2. Update session in Firestore:   │
              │     - endTime = now                │
              │     - isCompleted = TRUE ⭐        │
              │     - finalDuration, calories      │
              │     ↓ set(merge: true)             │
              │                                    │
              │  3. Refresh ProgressController     │
              │     ↓ triggers stats recalculation │
              │                                    │
              │  4. isCompleted.value = true       │
              └────────────┬───────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │  Completion Screen     │
              │  - ✓ Workout Complete  │
              │  - Stats summary       │
              │  - Done button         │
              └────────────┬───────────┘
                           │ User taps Done
                           ▼
              ┌────────────────────────┐
              │  Get.back()            │
              │  → Returns to Home     │
              │  → Stats updated ✅    │
              └────────────────────────┘
```

---

## 3. Progress Tracking Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Firestore Database                       │
│                                                             │
│  workout_sessions collection:                               │
│  ┌───────────────────────────────────────────┐             │
│  │ sessionId_1:                              │             │
│  │   userId: "user123"                       │             │
│  │   workoutTitle: "Morning Yoga Flow"       │             │
│  │   isCompleted: true ✓                     │             │
│  │   caloriesBurned: 15                      │             │
│  │   durationSeconds: 300                    │             │
│  │   createdAt: 2026-02-09 08:00             │             │
│  └───────────────────────────────────────────┘             │
│  ┌───────────────────────────────────────────┐             │
│  │ sessionId_2:                              │             │
│  │   isCompleted: false ✗ (incomplete)       │             │
│  └───────────────────────────────────────────┘             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Real-time Stream
                      │ .snapshots()
                      ▼
┌─────────────────────────────────────────────────────────────┐
│          ProgressController._setupRealtimeListener()        │
│                                                             │
│  _sessionsSubscription = service                            │
│    .watchUserWorkoutSessions(userId)                        │
│    .listen((sessions) {                                     │
│                                                             │
│      allSessions.value = sessions                           │
│                                                             │
│      _calculateStats() ──┐                                  │
│      _calculateWeekly() ─┼─> Stats Calculation             │
│      _calculateStreak() ─┘                                  │
│                                                             │
│    });                                                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              _calculateStats() Logic                        │
│                                                             │
│  Step 1: Filter Completed Only                             │
│  ┌────────────────────────────────────┐                    │
│  │ completedSessions =                │                    │
│  │   allSessions.where(               │                    │
│  │     (s) => s.isCompleted == true   │                    │
│  │   )                                │                    │
│  └────────────────────────────────────┘                    │
│                                                             │
│  Step 2: Calculate Totals                                  │
│  ┌────────────────────────────────────┐                    │
│  │ totalWorkouts = count              │                    │
│  │ totalCalories = sum(calories)      │                    │
│  │ totalMinutes = sum(duration)/60    │                    │
│  └────────────────────────────────────┘                    │
│                                                             │
│  Step 3: Update Observables                                │
│  ┌────────────────────────────────────┐                    │
│  │ totalWorkouts.value = X            │ ─┐                 │
│  │ totalCalories.value = Y            │  │                 │
│  │ totalMinutes.value = Z             │  │                 │
│  └────────────────────────────────────┘  │                 │
└───────────────────────────────────────────┼─────────────────┘
                                            │
                                            │ Reactive Update
                                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  UI (ProgressTabView)                       │
│                                                             │
│  Obx(() => Text('${controller.totalWorkouts.value}'))      │
│                                                             │
│  Auto-rebuilds when observable changes! ✨                 │
│                                                             │
│  ┌───────────────────────────────────────────┐             │
│  │  Stats Cards:                             │             │
│  │  ┌─────┐  ┌─────┐  ┌─────┐               │             │
│  │  │  X  │  │  Y  │  │  Z  │               │             │
│  │  │Work │  │ Cal │  │ Min │               │             │
│  │  └─────┘  └─────┘  └─────┘               │             │
│  └───────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Home vs Progress Stats Synchronization

```
┌─────────────────────────────────────────────────────────────┐
│                   ProgressController                        │
│                   (Shared Instance)                         │
│                                                             │
│  allSessions = [                                            │
│    Session1 (Today, 8:00 AM),    ← Today                   │
│    Session2 (Today, 6:00 PM),    ← Today                   │
│    Session3 (Yesterday),                                    │
│    Session4 (3 days ago),                                   │
│    ...                                                      │
│  ]                                                          │
└─────────┬───────────────────────────────────┬───────────────┘
          │                                   │
          │                                   │
          ▼                                   ▼
┌──────────────────────┐          ┌──────────────────────┐
│  HomeController      │          │  ProgressTabView     │
│                      │          │                      │
│ _updateTodayStats()  │          │ Shows All Stats      │
│                      │          │                      │
│ Filter TODAY only:   │          │ Uses directly:       │
│ ┌─────────────────┐  │          │ ┌─────────────────┐  │
│ │ today = now()   │  │          │ │ totalWorkouts   │  │
│ │                 │  │          │ │ totalCalories   │  │
│ │ todaySessions = │  │          │ │ totalMinutes    │  │
│ │   allSessions   │  │          │ │                 │  │
│ │   .where(       │  │          │ │ (All completed  │  │
│ │     date==today │  │          │ │  sessions)      │  │
│ │   )             │  │          │ └─────────────────┘  │
│ └─────────────────┘  │          │                      │
│                      │          │ Weekly Chart:        │
│ Calculate:           │          │ - Last 7 days        │
│ ┌─────────────────┐  │          │ - Minutes per day    │
│ │ todayWorkouts=2 │  │          │                      │
│ │ todayCalories=30│  │          │ Recent Workouts:     │
│ └─────────────────┘  │          │ - Last 10 sessions   │
│                      │          │                      │
│ Display in:          │          │                      │
│ "Today's Summary"    │          │                      │
└──────────────────────┘          └──────────────────────┘
```

---

## 5. Controller Lifecycle & Bindings

```
         App Starts
              │
              ▼
    ┌──────────────────┐
    │   main.dart      │
    │                  │
    │ Get.initialRoute │
    │   = '/home'      │
    └────────┬─────────┘
             │
             ▼
    ┌──────────────────────────────────┐
    │   HomeBinding.dependencies()     │
    │                                  │
    │  1. Create ProgressController    │ ← First!
    │     Get.lazyPut<Progress>()      │
    │                                  │
    │  2. Create HomeController        │
    │     Get.lazyPut<Home>()          │
    └────────┬─────────────────────────┘
             │
             ├────────────────────────────────┐
             │                                │
             ▼                                ▼
    ┌──────────────────┐         ┌──────────────────┐
    │ Progress         │         │ Home             │
    │ Controller       │         │ Controller       │
    │                  │         │                  │
    │ onInit():        │         │ onInit():        │
    │ - Setup real-time│         │ - Load workouts  │
    │   listener       │         │ - Sync progress  │
    │ - Watch sessions │◄────────┤   stats          │
    │ - Calculate stats│         │                  │
    └────────┬─────────┘         └──────────────────┘
             │
             │ Firestore updates
             ▼
    ┌──────────────────┐
    │  allSessions     │
    │  (Observable)    │
    └────────┬─────────┘
             │
             │ Triggers
             ▼
    ┌──────────────────┐
    │ _calculateStats()│
    │                  │
    │ Updates:         │
    │ - totalWorkouts  │
    │ - totalCalories  │
    │ - totalMinutes   │
    └────────┬─────────┘
             │
             │ Reactive
             ▼
    ┌──────────────────┐
    │   UI Rebuilds    │
    │   (Obx widgets)  │
    └──────────────────┘
```

---

## 6. Authentication Flow Decision Tree

```
User Opens App
      │
      ▼
Check Auth State
      │
      ├─ Authenticated? ──────┐
      │                       │
     NO                      YES
      │                       │
      ▼                       ▼
First Time User?      Profile Complete?
      │                       │
      ├───────┬───────        ├─────────┬─────────
     YES     NO              YES       NO
      │       │               │         │
      ▼       ▼               ▼         ▼
 Onboarding  Login        Home      Profile
  (3 screens) View        Screen    Setup
      │       │               │      (4 steps)
      │       │               │         │
      └───┬───┘               │         │
          │                   │         │
          ▼                   │         │
    Choose Auth Method        │         │
          │                   │         │
    ┌─────┼─────┬─────┬─────┐│         │
    │     │     │     │     ││         │
Email  Google Phone Email   ││         │
/Pass  SignIn Auth  Link    ││         │
    │     │     │     │     ││         │
    └─────┴─────┴─────┴─────┘│         │
             │                │         │
             ▼                │         │
       New User?              │         │
             │                │         │
       ┌─────┼─────┐          │         │
      YES         NO           │         │
       │           │           │         │
       │           └──────┬────┘         │
       │                  │              │
       ▼                  │              │
  ProfileSetup            │              │
  (4 steps)               │              │
       │                  │              │
       └──────────────────┴──────────────┘
                          │
                          ▼
                    Home Screen
                  (Main Navigation)
```

---

## 7. Data Synchronization Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                    USER ACTIONS                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
         ▼            ▼            ▼
    Complete      Edit         Delete
    Workout      Profile      Session
         │            │            │
         └────────────┼────────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │  Controller Action     │
         │  (e.g., completeWorkout)│
         └────────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │   Service Layer        │
         │   (e.g., WorkoutLog    │
         │         Service)       │
         └────────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │   Firestore Update     │
         │   .set() / .update()   │
         └────────────┬───────────┘
                      │
                      │ Real-time
                      ▼
         ┌────────────────────────┐
         │  Stream Listener       │
         │  .snapshots()          │
         └────────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │  Controller receives   │
         │  updated data          │
         └────────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │  Update Observable     │
         │  .value = newData      │
         └────────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │  UI Auto-Rebuilds      │
         │  (Obx wrapped)         │
         └────────────────────────┘
```

---

## 8. Critical Path: isCompleted Flag

```
START WORKOUT
      │
      ▼
┌──────────────────┐
│ Create Session   │
│ isCompleted:     │
│   FALSE ✗        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Do Exercises     │
│ (40s each)       │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────┐
│ All exercises done               │
│ _completeWorkout() called        │
│                                  │
│ Update Firestore:                │
│ ┌──────────────────────────────┐ │
│ │ isCompleted: TRUE ⭐ ✓      │ │
│ │ endTime: now                 │ │
│ │ durationSeconds: total       │ │
│ │ caloriesBurned: calculated   │ │
│ └──────────────────────────────┘ │
└────────┬─────────────────────────┘
         │
         ▼
┌───────────────────────────────────┐
│ Real-time listener fires          │
│ ProgressController receives update│
└────────┬──────────────────────────┘
         │
         ▼
┌───────────────────────────────────┐
│ _calculateStats()                 │
│                                   │
│ Filter: s.isCompleted == true     │
│         ^^^^^^^^^^^^^^^^          │
│         THIS IS THE KEY!          │
│                                   │
│ If TRUE: ✓ Counts in stats        │
│ If FALSE: ✗ Ignored               │
└────────┬──────────────────────────┘
         │
         ▼
┌───────────────────────────────────┐
│ Stats Updated                     │
│ - totalWorkouts++                 │
│ - totalCalories += X              │
│ - totalMinutes += Y               │
└────────┬──────────────────────────┘
         │
         ▼
┌───────────────────────────────────┐
│ UI Shows Updated Stats            │
│ Progress Tab ✓                    │
│ Home Today's Summary ✓            │
└───────────────────────────────────┘
```

---

## 9. Troubleshooting Decision Tree

```
Stats Not Showing?
      │
      ▼
Check Console Logs
      │
      ├─ "Session updated successfully"? ────┐
      │                                      │
     NO                                     YES
      │                                      │
      ▼                                      ▼
Check Firestore                    Check isCompleted flag
Connection                                   │
      │                            ┌─────────┼─────────┐
      │                           true               false
      │                            │                   │
      ▼                            ▼                   ▼
Internet OK?              Stats should show    ← PROBLEM HERE!
      │                            │            Why not true?
      ├─ YES → Firebase            │                   │
      │        Rules OK?           │                   ▼
      │                            │          Check update code:
      │                            │          - Using set(merge)?
      │                            │          - Setting isCompleted:true?
      │                            │          - Await completed?
      ▼                            │                   │
Check Controller                   │                   │
Initialization                     │                   │
      │                            │                   │
      ├─ Binding exists?           │                   │
      ├─ Get.find() works?         │                   │
      │                            │                   │
      ▼                            │                   │
Check UI Reactive                  │                   │
      │                            │                   │
      ├─ Using Obx()?              │                   │
      ├─ .value accessed?          │                   │
      │                            │                   │
      └────────────────────────────┴───────────────────┘
                                   │
                                   ▼
                            Problem Identified!
```

---

## 10. GetX Reactive Pattern Visualization

```
┌─────────────────────────────────────────────────────────────┐
│                      Controller                              │
│                                                             │
│  final RxInt counter = 0.obs;                               │
│                │                                            │
│                │ Observable Variable                        │
│                │                                            │
│  void increment() {                                         │
│    counter.value++;  ← Updates value                        │
│  }                                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Change Notification
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Obx Widget Tree                          │
│                                                             │
│  Obx(() {                    ← Listener registered          │
│    return Text(                                             │
│      '${controller.counter.value}'  ← Reads .value          │
│    );                                                       │
│  })                                                         │
│                                                             │
│  When counter changes:                                      │
│  1. Obx detects change                                      │
│  2. Rebuilds ONLY this widget                               │
│  3. Shows new value                                         │
└─────────────────────────────────────────────────────────────┘


Example Flow:
─────────────

Initial State:
  counter.value = 0
  UI shows: "0"

User Action (button tap):
  ↓
  controller.increment()
  ↓
  counter.value = 1
  ↓
  Obx detects change
  ↓
  Text widget rebuilds
  ↓
  UI shows: "1"

All automatic! No setState() needed! ✨
```

---

## Summary: The Complete Picture

```
┌─────────────────────────────────────────────────────────────┐
│                     FITTRACK+ ECOSYSTEM                      │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   Firebase   │◄──►│    GetX     │◄──►│   Flutter   │    │
│  │  (Backend)   │    │  (State)    │    │    (UI)     │    │
│  └──────┬───────┘    └──────┬──────┘    └──────┬──────┘    │
│         │                   │                   │           │
│    ┌────┴────┐         ┌────┴────┐         ┌────┴────┐     │
│    │Auth     │         │Controllers│       │Views    │     │
│    │Firestore│         │Services  │       │Widgets  │     │
│    │Storage  │         │Bindings  │       │Routes   │     │
│    └─────────┘         └──────────┘       └─────────┘     │
│                                                             │
│  Data Flow:                                                 │
│  User Action → Controller → Service → Firestore            │
│                                          ↓                  │
│  UI Update ← Observable ← Stream ← Real-time Listener       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

**Visual Guides Created**: February 9, 2026
