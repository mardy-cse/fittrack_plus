import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class PhoneAuthController extends GetxController {
  // Services
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final nameController = TextEditingController();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool codeSent = false.obs;
  final RxString verificationId = ''.obs;
  final RxInt resendTimer = 60.obs;

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // Send OTP
  Future<void> sendOTP() async {
    try {
      isLoading.value = true;

      final phoneNumber = phoneController.text.trim();

      // Add country code if not present
      final formattedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+88$phoneNumber'; // Bangladesh country code

      await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        codeSent: (String verificationId) {
          this.verificationId.value = verificationId;
          codeSent.value = true;
          isLoading.value = false;

          Get.snackbar(
            'Success',
            'OTP sent to $formattedPhone',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          // Start resend timer
          _startResendTimer();
        },
        verificationFailed: (String error) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            error,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        codeAutoRetrievalTimeout: () {
          isLoading.value = false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    try {
      isLoading.value = true;

      await _authService.verifyOTP(
        verificationId: verificationId.value,
        smsCode: otpController.text.trim(),
        name: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
      );

      Get.snackbar(
        'Success',
        'Phone verification successful!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to home
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (resendTimer.value > 0) return;

    otpController.clear();
    codeSent.value = false;
    await sendOTP();
  }

  // Start resend timer
  void _startResendTimer() {
    resendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
  }
}
