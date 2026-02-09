# FitTrack+ 🏋️‍♂️💪

> A comprehensive fitness tracking application built with Flutter, Firebase, and GetX

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
[![GetX](https://img.shields.io/badge/GetX-State%20Management-purple.svg)](https://pub.dev/packages/get)

---

## 📱 About FitTrack+

FitTrack+ is a feature-rich fitness tracking application that helps users monitor their workouts, track progress, calculate health metrics, and achieve their fitness goals with AI-powered coaching.

### ✨ Key Features

- 🏋️ **25+ Workout Programs** - Pre-designed workouts with Lottie animations
- 📊 **Progress Tracking** - Real-time stats, weekly charts, and streak tracking
- 🧮 **Health Calculators** - BMI, Calorie needs, and more
- 💧 **Water Tracker** - Daily hydration monitoring
- 🤖 **AI Coach** - Personalized fitness advice powered by Google Gemini
- 📈 **Analytics** - Detailed insights into your fitness journey
- 🔥 **Streak System** - Stay motivated with daily workout streaks
- 🎨 **Modern UI** - Beautiful dark/light themes with smooth animations

---

## 📚 Documentation

**👉 Start Here:** [DOCUMENTATION INDEX](DOCUMENTATION_INDEX.md)

### Quick Links

| Document | Purpose |
|----------|---------|
| 📖 [**Complete Workflow**](APP_WORKFLOW_DOCUMENTATION.md) | Full technical documentation (English) |
| 🇧🇩 [**বাংলা ডকুমেন্টেশন**](APP_WORKFLOW_DOCUMENTATION_BN.md) | Complete documentation in Bangla |
| ⚡ [**Quick Reference**](QUICK_REFERENCE.md) | Code patterns and quick lookups |
| 🎨 [**Visual Diagrams**](VISUAL_WORKFLOW_DIAGRAMS.md) | Flow charts and visual guides |
| 🚀 [**Setup Guide**](SETUP_GUIDE.md) | Installation and configuration |
| 📋 [**Project Status**](PROJECT_STATUS.md) | Current development status |

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- Firebase account
- Android Studio / VS Code
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/fittrack_plus.git

# Navigate to project directory
cd fittrack_plus

# Install dependencies
flutter pub get

# Run the app
flutter run
```

For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

## 🏗️ Tech Stack

### Frontend
- **Flutter** - UI framework
- **Dart** - Programming language
- **GetX** - State management, routing, and dependency injection
- **Lottie** - Smooth animations

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - Image storage
- **Google Gemini API** - AI coaching

### Key Packages
- `get` - State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `lottie` - Animations
- `fl_chart` - Charts and graphs
- `table_calendar` - Calendar widget
- `flutter_tts` - Text-to-speech

---

## 📱 App Structure

```
lib/
├── app/
│   ├── bindings/          # Dependency injection
│   ├── controllers/       # Business logic
│   ├── models/            # Data models
│   ├── services/          # Firebase & API services
│   ├── views/             # UI screens
│   │   ├── home/
│   │   ├── progress/
│   │   ├── workout/
│   │   ├── profile/
│   │   └── tools/
│   ├── widgets/           # Reusable components
│   ├── utils/             # Themes & utilities
│   └── routes/            # Navigation routes
├── main.dart              # App entry point
└── firebase_options.dart  # Firebase config
```

---

## 🎯 Core Features Explained

### 1. Workout System
- Browse 25+ pre-designed workouts
- Start workouts with timer and animations
- Track duration, calories, and exercises
- Save sessions to Firebase in real-time

### 2. Progress Tracking
- Real-time statistics (workouts, calories, minutes)
- Weekly activity bar chart
- Workout streak calculation
- Calendar view with workout markers
- Recent workout history

### 3. Tools Suite
- **BMI Calculator** - Calculate and track BMI
- **Water Tracker** - Daily hydration monitoring
- **Calorie Calculator** - Determine daily calorie needs
- **AI Coach** - Get personalized fitness advice

### 4. Profile Management
- User profile with photo
- Customizable fitness goals
- Body metrics tracking
- Settings and preferences

---

## 🔥 How It Works

### Workout Flow
```
Browse Workouts → View Details → Start Workout → Complete Exercises → Save Progress → Update Stats
```

### Data Synchronization
```
User Action → Controller → Service → Firestore → Real-time Listener → Controller Update → UI Refresh
```

See [VISUAL_WORKFLOW_DIAGRAMS.md](VISUAL_WORKFLOW_DIAGRAMS.md) for detailed flow diagrams.

---

## 🐛 Troubleshooting

**Stats not showing?**
- Check [Troubleshooting Guide](APP_WORKFLOW_DOCUMENTATION.md#debugging-workflow)
- Verify `isCompleted: true` in Firestore
- Ensure real-time listeners are active

**Can't login?**
- Check Firebase configuration
- Verify internet connection
- Review Firebase Auth setup in [SETUP_GUIDE.md](SETUP_GUIDE.md)

For more help, see the [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

---

## 📖 Learning Resources

### For New Developers
1. Start with [SETUP_GUIDE.md](SETUP_GUIDE.md)
2. Read [APP_WORKFLOW_DOCUMENTATION.md](APP_WORKFLOW_DOCUMENTATION.md)
3. Explore [VISUAL_WORKFLOW_DIAGRAMS.md](VISUAL_WORKFLOW_DIAGRAMS.md)
4. Use [QUICK_REFERENCE.md](QUICK_REFERENCE.md) while coding

### বাংলাভাষী ডেভেলপারদের জন্য
সম্পূর্ণ বাংলা documentation পেতে [APP_WORKFLOW_DOCUMENTATION_BN.md](APP_WORKFLOW_DOCUMENTATION_BN.md) দেখুন।

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Follow the code patterns in [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
5. Update documentation if needed
6. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Development Team

**Developed by:** FitTrack+ Team  
**Last Updated:** February 9, 2026  
**Version:** 1.0.0

---

## 📞 Support

- 📖 Documentation: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)
- 🐛 Issues: Check troubleshooting guides
- 💬 Questions: Review documentation first

---

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- GetX for powerful state management
- Firebase for backend services
- Google Gemini for AI capabilities
- LottieFiles for beautiful animations

---

**Ready to start?** 👉 [SETUP_GUIDE.md](SETUP_GUIDE.md)  
**Need help?** 👉 [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)  
**বাংলায় পড়তে চান?** 👉 [APP_WORKFLOW_DOCUMENTATION_BN.md](APP_WORKFLOW_DOCUMENTATION_BN.md)

---

<p align="center">Made with ❤️ and 💪</p>
