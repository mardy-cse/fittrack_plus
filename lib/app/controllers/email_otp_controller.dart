import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class EmailOTPController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // OTP input controllers
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Signup data
  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;

  // State
  final isLoading = false.obs;
  final isResending = false.obs;
  final canResend = false.obs;
  final remainingTime = 60.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Get signup data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      email.value = args['email'] ?? '';
      password.value = args['password'] ?? '';
      name.value = args['name'] ?? '';
    }
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }

  // Start resend timer
  void startTimer() {
    canResend.value = false;
    remainingTime.value = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Get OTP string
  String get otp => otpControllers.map((c) => c.text).join();

  // Check if OTP is complete
  bool get isOTPComplete => otp.length == 6;

  // Handle OTP input
  void onOTPChanged(int index, String value) {
    if (value.isEmpty && index > 0) {
      // Backspace pressed, move to previous field
      otpFocusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index < 5) {
      // Character entered, move to next field
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      // Last field filled, unfocus keyboard
      otpFocusNodes[index].unfocus();
      // Auto-verify if OTP is complete
      if (isOTPComplete) {
        verifyOTP();
      }
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    if (!isOTPComplete) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter complete 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      isLoading.value = true;

      debugPrint('🔍 Verifying OTP: $otp for email: ${email.value}');

      // Verify OTP
      final isValid = await _authService.verifyEmailOTP(
        email: email.value,
        otp: otp,
      );

      debugPrint('✅ OTP Valid: $isValid');

      if (isValid) {
        debugPrint('📝 Creating account...');

        // Complete signup
        await _authService.completeEmailSignup(
          email: email.value,
          password: password.value,
          name: name.value,
        );

        debugPrint('🎉 Account created successfully!');

        // Navigate to home
        debugPrint('🏠 Navigating to home...');
        Get.offAllNamed('/home');

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            'Success! 🎉',
            'Account created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        });
      } else {
        debugPrint('❌ Invalid OTP');
        Get.snackbar(
          'Invalid OTP',
          'The OTP you entered is incorrect',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      debugPrint('❌ Error during verification: $e');
      Get.snackbar(
        'Verification Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (!canResend.value || isResending.value) return;

    try {
      isResending.value = true;

      final otp = await _authService.sendEmailOTP(email.value);

      Get.snackbar(
        'OTP Resent',
        'Development Mode - Your OTP: $otp',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 15),
      );

      // Clear OTP fields
      for (var controller in otpControllers) {
        controller.clear();
      }

      // Reset focus to first field
      otpFocusNodes[0].requestFocus();

      // Restart timer
      startTimer();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resend OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isResending.value = false;
    }
  }

  // Clear all OTP fields
  void clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes[0].requestFocus();
  }
}
