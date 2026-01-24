import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import 'profile_screen.dart';

/// Profile tab wrapper - delegates to ProfileScreen
/// Manages controller lifecycle to reset unsaved changes when navigating away
class ProfileTabView extends StatefulWidget {
  const ProfileTabView({super.key});

  @override
  State<ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<ProfileTabView> {
  @override
  void dispose() {
    // Reset unsaved changes when navigating away from profile tab
    final controller = Get.find<ProfileController>();
    if (controller.isEditMode.value) {
      controller.resetToOriginal();
      controller.isEditMode.value = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
