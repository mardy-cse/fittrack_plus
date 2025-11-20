# FitTrack+ 🏋️‍♂️

A modern, cross-platform fitness tracking application built with Flutter.

## Features

- 🔐 Firebase Authentication
- 📊 Workout Tracking
- 📈 Progress Analytics with Charts
- 🍎 Nutrition Monitoring
- 🎨 Material 3 Design
- 🌓 Dark/Light Theme Support
- 📱 Cross-platform (iOS, Android, Web)

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Configuration

**IMPORTANT:** Before running the app, you need to configure Firebase:

#### Option 1: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your project:
```bash
flutterfire configure
```

This will:
- Create a Firebase project (or select an existing one)
- Register your app with Firebase
- Generate the `firebase_options.dart` file with proper credentials

#### Option 2: Manual Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Create a Firestore Database
4. Download configuration files:
   - `google-services.json` for Android → Place in `android/app/`
   - `GoogleService-Info.plist` for iOS → Place in `ios/Runner/`
5. Update `lib/firebase_options.dart` with your Firebase credentials

### 3. Enable Firebase Services

In Firebase Console, enable:
- ✅ Authentication → Email/Password
- ✅ Firestore Database
- ✅ Storage (for profile images)

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   └── theme/          # Theme configuration
├── models/             # Data models
├── services/           # Firebase & API services
├── controllers/        # GetX controllers
├── screens/            # UI screens
│   ├── splash/
│   ├── auth/
│   ├── home/
│   └── ...
├── widgets/            # Reusable widgets
├── firebase_options.dart
└── main.dart
```

## Packages Used

- **get**: State management & navigation
- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: Cloud database
- **fl_chart**: Beautiful charts
- **lottie**: Animations
- **pedometer**: Step tracking
- **chewie**: Video player
- **cached_network_image**: Image caching
- **image_picker**: Image selection

## Development

This project uses:
- Flutter SDK: ^3.9.2
- GetX for state management
- Firebase for backend services
- Material 3 design principles

## Notes

- The app requires proper Firebase configuration to run
- Make sure to add your own Firebase credentials
- The splash screen will redirect to home after 3 seconds
- Theme automatically adapts to system preference (dark/light)

## Next Steps

After setup, you can:
1. Build authentication screens (login, register)
2. Create workout tracking features
3. Implement nutrition monitoring
4. Add progress analytics
5. Integrate step counter using pedometer package

---

Built with ❤️ using Flutter & Firebase
