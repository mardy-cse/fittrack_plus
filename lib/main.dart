import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/utils/themes.dart';
import 'app/views/splash/splash_view.dart';
import 'app/views/auth/login_view.dart';
import 'app/views/auth/signup_view.dart';
import 'app/views/auth/phone_auth_view.dart';
import 'app/views/auth/email_otp_view.dart';
import 'app/bindings/auth_binding.dart';
import 'app/bindings/phone_auth_binding.dart';
import 'app/bindings/email_otp_binding.dart';
import 'app/bindings/home_binding.dart';
import 'app/bindings/workout_detail_binding.dart';
import 'app/bindings/start_workout_binding.dart';
import 'app/views/navigation/main_navigation_view.dart';
import 'app/views/workout/workout_detail_view.dart';
import 'app/views/workout/start_workout_view.dart';
import 'app/services/user_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/workout_service.dart';
import 'app/services/workout_log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Services
  await Get.putAsync(() => UserService().init());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => WorkoutService().init());
  await Get.putAsync(() => WorkoutLogService().init());

  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitTrack+',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Initial Route
      initialRoute: '/',

      // Route Configuration
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashView(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: AuthBinding(),
          transition: Transition.fadeIn,
          preventDuplicates: true,
        ),
        GetPage(
          name: '/signup',
          page: () => const SignupView(),
          binding: AuthBinding(),
          transition: Transition.rightToLeft,
          preventDuplicates: true,
        ),
        GetPage(
          name: '/phone-auth',
          page: () => const PhoneAuthView(),
          binding: PhoneAuthBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/email-otp',
          page: () => const EmailOTPView(),
          binding: EmailOTPBinding(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/home',
          page: () => const MainNavigationView(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/workout-detail',
          page: () => const WorkoutDetailView(),
          binding: WorkoutDetailBinding(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/start-workout',
          page: () => const StartWorkoutView(),
          binding: StartWorkoutBinding(),
          transition: Transition.fadeIn,
        ),
      ],

      // Default Transition
      defaultTransition: Transition.cupertino,
    );
  }
}
