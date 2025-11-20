import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/utils/themes.dart';
import 'app/views/splash/splash_view.dart';
import 'app/views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          name: '/home',
          page: () => const HomeView(),
          transition: Transition.fadeIn,
        ),
      ],

      // Default Transition
      defaultTransition: Transition.cupertino,
    );
  }
}
