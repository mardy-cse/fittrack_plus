import 'package:flutter/material.dart';
import 'profile_screen.dart';

/// Profile tab wrapper - delegates to ProfileScreen
class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
