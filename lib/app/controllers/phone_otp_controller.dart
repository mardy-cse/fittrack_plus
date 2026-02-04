import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneOTPController extends GetxController {
  // OTP Controllers
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Observable variables
  final phoneNumber = ''.obs;
  final otpVerified = false.obs;
  final isLoading = false.obs;
  final isResending = false.obs;
  final canResend = false.obs;
  final remainingTime = 60.obs;

  // Timer
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();

    // Get phone number from arguments
    if (Get.arguments != null && Get.arguments['phoneNumber'] != null) {
      phoneNumber.value = Get.arguments['phoneNumber'];
    }

    // Start resend timer
    _startResendTimer();
  }

  @override
  void onClose() {
    // Dispose controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.onClose();
  }

  // Start resend timer
  void _startResendTimer() {
    canResend.value = false;
    remainingTime.value = 60;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Handle OTP input
  void onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  // Get complete OTP
  String getOTP() {
    return otpControllers.map((controller) => controller.text).join();
  }

  // Clear OTP
  void clearOTP() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    final otp = getOTP();

    if (otp.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual phone verification logic
      // For now, accept any 6-digit OTP
      debugPrint('Verifying OTP: $otp for phone: ${phoneNumber.value}');

      // Mark as verified
      otpVerified.value = true;

      Get.snackbar(
        'Success',
        'Phone number verified successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      Get.snackbar(
        'Error',
        'Failed to verify OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    try {
      isResending.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Implement actual resend OTP logic
      debugPrint('Resending OTP to: ${phoneNumber.value}');

      // Clear current OTP
      clearOTP();

      // Restart timer
      _startResendTimer();

      Get.snackbar(
        'OTP Sent',
        'A new OTP has been sent to your phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error resending OTP: $e');
      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isResending.value = false;
    }
  }

  // Handle verification completion
  void onVerificationComplete() {
    // TODO: Navigate to appropriate screen or complete signup
    debugPrint('Phone verification complete!');

    // Example: Navigate to home or complete registration
    Get.offAllNamed('/home');
  }
}
