import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ResetPasswordOTPController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // OTP input controllers
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Password controllers
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Email
  final email = ''.obs;

  // State
  final isLoading = false.obs;
  final isResending = false.obs;
  final canResend = false.obs;
  final remainingTime = 60.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final otpVerified = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      email.value = args['email'] ?? '';
    }

    // Start resend timer
    _startResendTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Get OTP string
  String get otp => otpControllers.map((c) => c.text).join();

  // Check if OTP is complete
  bool get isOTPComplete => otp.length == 6;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Handle OTP input change
  void onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify when 6 digits are entered
    if (value.isNotEmpty && index == 5) {
      otpFocusNodes[index].unfocus();
      if (isOTPComplete) {
        verifyOTP();
      }
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    if (!isOTPComplete || isLoading.value) return;

    try {
      isLoading.value = true;

      debugPrint('🔍 Verifying OTP: $otp for email: ${email.value}');

      final isValid = await _authService.verifyEmailOTP(
        email: email.value,
        otp: otp,
      );

      debugPrint('✅ OTP Valid: $isValid');

      if (isValid) {
        otpVerified.value = true;
        Get.snackbar(
          'OTP Verified ✅',
          'Now set your new password',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      } else {
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

  // Reset password
  Future<void> resetPassword() async {
    debugPrint('🔐 Reset password called');
    debugPrint('✅ OTP Verified: ${otpVerified.value}');
    debugPrint('📝 New Password length: ${newPasswordController.text.length}');
    debugPrint(
      '📝 Confirm Password length: ${confirmPasswordController.text.length}',
    );

    if (!otpVerified.value) {
      debugPrint('❌ OTP not verified');
      Get.snackbar(
        'Error',
        'Please verify OTP first',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      debugPrint('❌ Password too short');
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      debugPrint('❌ Passwords do not match');
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      debugPrint('🚀 Starting password reset...');
      isLoading.value = true;

      // Send password reset email (Firebase requires this approach)
      await _authService.resetPasswordWithOTP(
        email: email.value,
        newPassword: newPasswordController.text,
      );

      debugPrint('✅ Password reset successful');

      // Stop loading before navigation
      isLoading.value = false;

      // Clean up this controller completely
      debugPrint('🧹 Cleaning up reset password controller...');
      Get.delete<ResetPasswordOTPController>(force: true);

      // Navigate to login - use regular offAllNamed without animations for clean transition
      debugPrint('🧭 Navigating to login...');
      await Get.offAllNamed('/login');

      // Show success message after navigation completes
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar(
        'Success! 🎉',
        'Password reset link sent to your email. Please check your inbox.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('❌ Error resetting password: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
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

      // Restart timer
      _startResendTimer();

      // Clear OTP fields
      clearOTP();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isResending.value = false;
    }
  }

  // Clear OTP
  void clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  // Start resend timer
  void _startResendTimer() {
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
}
