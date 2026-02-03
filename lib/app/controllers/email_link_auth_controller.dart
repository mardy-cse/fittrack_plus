import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class EmailLinkAuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final nameController = TextEditingController();

  final isLoading = false.obs;
  final linkSent = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // Send sign-in link to email
  Future<void> sendSignInLink() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _authService.sendSignInLinkToEmail(emailController.text.trim());

      linkSent.value = true;

      Get.snackbar(
        'Success',
        'Sign-in link sent to ${emailController.text.trim()}\nCheck your email inbox',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify and sign in with email link
  Future<void> signInWithLink(String emailLink) async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      if (email.isEmpty) {
        throw Exception('Please enter your email');
      }

      final credential = await _authService.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
        name: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
      );

      if (credential.user != null) {
        Get.snackbar(
          'Success',
          'Logged in successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to home
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if current URL is a sign-in link
  bool isSignInLink(String link) {
    return _authService.isSignInWithEmailLink(link);
  }
}
