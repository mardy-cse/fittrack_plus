# FitTrack+ Folder Structure

## Complete Structure

```
lib/
├── main.dart                           # App entry point
├── firebase_options.dart               # Firebase configuration
│
└── app/
    ├── bindings/                       # Dependency injection
    │   └── README.md                   # Bindings documentation
    │
    ├── controllers/                    # State management (GetX)
    │   └── README.md                   # Controllers documentation
    │
    ├── models/                         # Data models
    │   └── README.md                   # Models documentation
    │
    ├── services/                       # External operations
    │   ├── firebase_service.dart       # Firebase initialization
    │   └── README.md                   # Services documentation
    │
    ├── utils/                          # Utilities & helpers
    │   ├── constants.dart              # App constants
    │   ├── themes.dart                 # Theme configurations
    │   └── README.md                   # Utils documentation
    │
    ├── views/                          # UI screens
    │   ├── splash/
    │   │   └── splash_view.dart        # Splash screen
    │   ├── home/
    │   │   └── home_view.dart          # Home screen
    │   └── README.md                   # Views documentation
    │
    └── widgets/                        # Reusable UI components
        └── README.md                   # Widgets documentation
```

## Folder Purposes

### `/app/bindings/`
**Purpose**: Dependency injection and lifecycle management
- Instantiates controllers when routes are accessed
- Manages dependencies for views
- Ensures proper memory management

**Example Structure**:
```
bindings/
├── auth_binding.dart
├── home_binding.dart
├── workout_binding.dart
└── profile_binding.dart
```

### `/app/controllers/`
**Purpose**: Business logic and state management
- Handles user interactions
- Manages reactive state with GetX
- Communicates with services
- Updates UI through observable variables

**Example Structure**:
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

### `/app/models/`
**Purpose**: Data structure definitions
- Represents application entities
- Provides serialization/deserialization
- Includes fromMap() and toMap() methods

**Example Structure**:
```
models/
├── user_model.dart
├── workout_model.dart
├── exercise_model.dart
├── nutrition_model.dart
├── progress_model.dart
└── goal_model.dart
```

### `/app/services/`
**Purpose**: External operations and API interactions
- Firebase operations
- API calls
- Local storage
- Third-party integrations

**Example Structure**:
```
services/
├── firebase_service.dart
├── auth_service.dart
├── firestore_service.dart
├── storage_service.dart
├── notification_service.dart
├── pedometer_service.dart
└── preferences_service.dart
```

### `/app/utils/`
**Purpose**: Utility functions and helpers
- Constants and configurations
- Validators
- Formatters
- Extensions
- Theme definitions

**Example Structure**:
```
utils/
├── constants.dart
├── themes.dart
├── validators.dart
├── formatters.dart
├── helpers.dart
├── extensions.dart
└── enums.dart
```

### `/app/views/`
**Purpose**: UI screens and pages
- Full-screen layouts
- Uses GetView<T> for controller access
- Presentation layer

**Example Structure**:
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

### `/app/widgets/`
**Purpose**: Reusable custom widgets
- Shared UI components
- Composable elements
- Used across multiple views

**Example Structure**:
```
widgets/
├── common/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── loading_indicator.dart
│   └── empty_state.dart
├── cards/
│   ├── workout_card.dart
│   ├── exercise_card.dart
│   └── nutrition_card.dart
├── charts/
│   ├── progress_chart.dart
│   └── weight_chart.dart
└── dialogs/
    └── confirmation_dialog.dart
```

## Architecture Pattern

This structure follows the **MVC + Services** pattern with GetX:

```
View (UI) 
    ↓ User Interaction
Controller (Logic)
    ↓ Data Request
Service (Data Source)
    ↓ Response
Controller (Process)
    ↓ Update State
View (Update UI)
```

## Data Flow

```
User Action → View → Controller → Service → External Source
                ↑                              ↓
                └────── Observable ←───────────┘
```

## Best Practices

1. **Separation of Concerns**: Each folder has a specific responsibility
2. **Single Responsibility**: Each file should do one thing well
3. **Dependency Injection**: Use bindings for proper lifecycle management
4. **Reactive Programming**: Use GetX observables for state management
5. **Modular Design**: Keep components small and reusable
6. **Clear Naming**: Use descriptive names that reflect purpose
7. **Documentation**: Add README files explaining folder purposes

## Current Status

✅ Folder structure created
✅ README documentation added to all folders
✅ Existing files reorganized
✅ Imports updated
✅ No compilation errors

## Next Steps

Ready to implement:
- Authentication controllers and views
- Workout management
- Exercise library
- Nutrition tracking
- Progress analytics
- User profile management

---

**Architecture**: Clean, modular, production-ready
**State Management**: GetX
**Pattern**: MVC + Services
**Status**: ✅ STEP 1 COMPLETE
