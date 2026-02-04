import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  // Services
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController confirmPasswordController;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Reset state on controller init
    isLoading.value = false;
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Login with email and password
  Future<void> login() async {
    try {
      isLoading.value = true;

      await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Clear form after successful login
      clearForm();

      Get.snackbar(
        'Success',
        'Login successful!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Check if profile is complete
      await _checkProfileAndNavigate();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Show dialog for better visibility
      Get.dialog(
        Builder(
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Login Failed'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign up with email and password (with OTP verification)
  Future<void> signUp() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      // Send OTP to email and get OTP for development mode
      final otp = await _authService.signUpWithEmailOTP(
        email: email,
        password: password,
        name: name,
      );

      isLoading.value = false;

      // Show OTP in development mode
      Get.snackbar(
        'OTP Sent! 📧',
        'Development Mode - Your OTP: $otp\n(Check console for details)',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 15),
      );

      // Navigate to email OTP screen
      Get.toNamed(
        '/email-otp',
        arguments: {'email': email, 'password': password, 'name': name},
      );
    } catch (e) {
      isLoading.value = false;

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Show dialog for better visibility
      Get.dialog(
        Builder(
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Sign Up Failed'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Also show snackbar as backup
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Clear form first to avoid confusion
      clearForm();

      await _authService.signInWithGoogle();

      Get.snackbar(
        'Success',
        'Google Sign In successful!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Check if profile is complete
      await _checkProfileAndNavigate();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if profile is complete and navigate accordingly
  Future<void> _checkProfileAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final age = data?['age'];
        final gender = data?['gender'];
        final height = data?['height'];
        final weight = data?['weight'];

        // Check if all required fields are filled
        if (age == null || gender == null || height == null || weight == null) {
          // Navigate to profile setup
          Get.offAllNamed('/profile-setup');
        } else {
          // Navigate to home
          Get.offAllNamed('/home');
        }
      } else {
        // Navigate to profile setup for new users
        Get.offAllNamed('/profile-setup');
      }
    } catch (e) {
      debugPrint('Error checking profile: $e');
      // Default to home on error
      Get.offAllNamed('/home');
    }
  }

  // Forgot password - Send OTP
  Future<void> forgotPassword(String email) async {
    try {
      debugPrint('🔑 Forgot password initiated for: $email');
      isLoading.value = true;

      // Send OTP for password reset
      debugPrint('📤 Sending OTP...');
      final otp = await _authService.sendForgotPasswordOTP(email);
      debugPrint('✅ OTP received: $otp');

      // Close dialog first
      debugPrint('🚪 Closing dialog...');
      Get.back();

      // Wait a bit for dialog to close
      await Future.delayed(const Duration(milliseconds: 300));

      isLoading.value = false;

      // Show OTP in development mode
      debugPrint('📱 Showing OTP snackbar...');
      Get.snackbar(
        'OTP Sent! 📧',
        'Development Mode - Your OTP: $otp',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 15),
      );

      // Navigate to reset password OTP screen
      debugPrint('🧭 Navigating to reset password screen...');
      Get.toNamed('/reset-password-otp', arguments: {'email': email});
      debugPrint('✅ Navigation completed');
    } catch (e) {
      debugPrint('❌ Error in forgotPassword: $e');
      isLoading.value = false;

      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }
}
