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

      // Check if email is verified
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        isLoading.value = false;

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Show verification required dialog
        Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Row(
              children: [
                Icon(Icons.mark_email_unread, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Email Not Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Please verify your email address before logging in. Check your inbox for the verification link.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Resend verification email
                  try {
                    await user.sendEmailVerification();
                    Get.back();
                    Get.snackbar(
                      'Email Sent',
                      'Verification email has been resent!',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to resend verification email',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                ),
                child: const Text('Resend Email'),
              ),
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return;
      }

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
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Login Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                ),
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

  // Sign up with email and password
  Future<void> signUp() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text;
      final name = nameController.text.trim();

      // Create account directly
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Sign out user immediately so they can't access app without verification
      await FirebaseAuth.instance.signOut();

      // Clear form
      clearForm();

      isLoading.value = false;

      // Show success dialog
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read, color: Color(0xFF4A90E2), size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification Email Sent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📧 Please check your inbox and confirm your email to sign in.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4A90E2),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Check your spam folder if you don\'t see it',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.offAllNamed('/login'); // Go to login
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return;
    } catch (e) {
      isLoading.value = false;

      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Show dialog for better visibility
      Get.dialog(
        Builder(
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Sign Up Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                ),
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

  // Forgot password - Send reset email
  Future<void> forgotPassword(String email) async {
    try {
      debugPrint('🔑 Forgot password initiated for: $email');
      isLoading.value = true;

      // Send password reset email via Firebase
      await _authService.sendPasswordResetEmail(email);

      // Close dialog first
      debugPrint('🚪 Closing dialog...');
      Get.back();

      // Wait a bit for dialog to close
      await Future.delayed(const Duration(milliseconds: 300));

      isLoading.value = false;

      // Show success dialog
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read, color: Color(0xFF4A90E2), size: 32),
              SizedBox(width: 12),
              Text(
                'Password Reset Email Sent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'We\'ve sent a password reset link to your email. Please check your inbox and follow the instructions.',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
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
