import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form controllers
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Observable variables
  final selectedGender = Rx<String?>(null);
  final isLoading = false.obs;
  final currentStep = 0.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  final genderOptions = ['Male', 'Female', 'Other'];

  @override
  void onClose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }

  // Validate current step
  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0: // Age
        if (ageController.text.isEmpty) {
          Get.snackbar(
            'Required',
            'Please enter your age',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        final age = int.tryParse(ageController.text);
        if (age == null || age < 10 || age > 120) {
          Get.snackbar(
            'Invalid Age',
            'Please enter a valid age between 10 and 120',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        return true;

      case 1: // Gender
        if (selectedGender.value == null) {
          Get.snackbar(
            'Required',
            'Please select your gender',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        return true;

      case 2: // Height
        if (heightController.text.isEmpty) {
          Get.snackbar(
            'Required',
            'Please enter your height',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        final height = double.tryParse(heightController.text);
        if (height == null || height < 50 || height > 300) {
          Get.snackbar(
            'Invalid Height',
            'Please enter a valid height between 50 and 300 cm',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        return true;

      case 3: // Weight
        if (weightController.text.isEmpty) {
          Get.snackbar(
            'Required',
            'Please enter your weight',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        final weight = double.tryParse(weightController.text);
        if (weight == null || weight < 20 || weight > 500) {
          Get.snackbar(
            'Invalid Weight',
            'Please enter a valid weight between 20 and 500 kg',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  // Go to next step
  void nextStep() {
    if (validateCurrentStep()) {
      if (currentStep.value < 3) {
        currentStep.value++;
      } else {
        // Last step, save profile
        saveProfile();
      }
    }
  }

  // Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Select gender
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Save profile to Firestore
  Future<void> saveProfile() async {
    if (!validateCurrentStep()) return;

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final age = int.parse(ageController.text);
      final height = double.parse(heightController.text);
      final weight = double.parse(weightController.text);

      // Update user profile in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'age': age,
        'gender': selectedGender.value,
        'height': height,
        'weight': weight,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Profile setup completed!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      // Navigate to home
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to save profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Skip for now
  void skipForNow() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        title: const Text(
          'Skip Profile Setup?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'You can complete your profile later from the settings page. However, some features may be limited without complete profile information.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/home');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
