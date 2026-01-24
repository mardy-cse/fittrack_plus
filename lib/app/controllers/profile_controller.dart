import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

/// Controller for managing user profile
class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  UserProfile? _originalProfile; // Store original profile for cancel/reset
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxString backgroundImagePath = ''.obs;

  // Form controllers
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final stepGoalController = TextEditingController();

  // Observable settings
  final RxString selectedGender = 'Male'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    stepGoalController.dispose();
    super.onClose();
  }

  /// Load user profile
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUserId;
      if (userId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final profile = await _userService.getUserProfile(userId);
      if (profile != null) {
        userProfile.value = profile;
        _populateFields(profile);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate form fields from profile
  void _populateFields(UserProfile profile) {
    nameController.text = profile.name;
    ageController.text = profile.age?.toString() ?? '';
    heightController.text = profile.height?.toString() ?? '';
    weightController.text = profile.weight?.toString() ?? '';
    stepGoalController.text = profile.dailyStepGoal?.toString() ?? '10000';
    selectedGender.value = profile.gender ?? 'Male';
    backgroundImagePath.value = profile.coverImageUrl ?? '';

    // Save original profile for cancel/reset functionality
    _originalProfile = profile;
  }

  /// Reset to original profile (discard unsaved changes)
  void resetToOriginal() {
    if (_originalProfile != null) {
      userProfile.value = _originalProfile;
      _populateFields(_originalProfile!);
      debugPrint('🔄 Profile reset to original state');
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    if (isEditMode.value) {
      // Cancel edit - reset to original profile
      resetToOriginal();
    } else {
      // Entering edit mode - save current state as original
      if (userProfile.value != null) {
        _originalProfile = userProfile.value;
      }
    }
    isEditMode.value = !isEditMode.value;
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUserId;
      if (userId == null) return;

      // Validate inputs
      if (nameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Name cannot be empty');
        return;
      }

      // Parse numeric fields
      final age = int.tryParse(ageController.text);
      final height = double.tryParse(heightController.text);
      final weight = double.tryParse(weightController.text);
      final stepGoal = int.tryParse(stepGoalController.text) ?? 10000;

      // Update profile (includes photoUrl and coverImageUrl from previews)
      final updatedProfile = userProfile.value!.copyWith(
        name: nameController.text.trim(),
        age: age,
        height: height,
        weight: weight,
        gender: selectedGender.value,
        dailyStepGoal: stepGoal,
        // photoUrl and coverImageUrl are already in userProfile.value from previews
      );

      debugPrint('💾 Saving profile to Firebase including images...');
      await _userService.updateUserProfile(updatedProfile);
      userProfile.value = updatedProfile;

      // Update the original profile after successful save
      _originalProfile = updatedProfile;

      debugPrint('✅ Profile saved to Firebase successfully');

      isEditMode.value = false;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick and upload profile photo
  Future<void> pickAndUploadPhoto() async {
    try {
      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) {
        debugPrint('No image selected');
        return;
      }

      isUploadingPhoto.value = true;

      final userId = _authService.currentUserId;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'User not logged in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint('📸 Profile image selected: ${image.path}');

      // Get image path
      final photoUrl = image.path;

      // Update local profile only (for instant UI preview)
      // Will be saved to Firebase when Save button is clicked
      if (userProfile.value != null) {
        userProfile.value = userProfile.value!.copyWith(photoUrl: photoUrl);
        debugPrint('✅ Local profile image updated - showing preview');
      }

      // Don't show snackbar during image picker (causes overlay error)
      debugPrint('💡 Profile image preview ready. Save to keep changes.');
    } catch (e) {
      debugPrint('Error saving photo: $e');
      Get.snackbar(
        'Error',
        'Failed to save photo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Pick and upload cover/background image
  Future<void> pickBackgroundImage() async {
    try {
      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('No background image selected');
        return;
      }

      isUploadingPhoto.value = true;

      final userId = _authService.currentUserId;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'User not logged in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint('📸 Cover image selected: ${image.path}');

      // Get image path
      final coverImageUrl = image.path;

      // Update local profile only (for instant UI preview)
      // Will be saved to Firebase when Save button is clicked
      if (userProfile.value != null) {
        debugPrint('🔍 Before update: ${userProfile.value?.coverImageUrl}');
        debugPrint('🔍 New cover image: $coverImageUrl');

        // Force a new object creation
        final old = userProfile.value;
        userProfile.value = null; // Clear first
        userProfile.value = old!.copyWith(coverImageUrl: coverImageUrl);
        backgroundImagePath.value = coverImageUrl;

        debugPrint('✅ Local cover image updated - showing preview');
        debugPrint(
          '📱 Cover image path after update: ${userProfile.value?.coverImageUrl}',
        );
      }

      // Don't show snackbar during image picker (causes overlay error)
      debugPrint('💡 Cover image preview ready. Save to keep changes.');
    } catch (e) {
      debugPrint('Error saving cover image: $e');
      Get.snackbar(
        'Error',
        'Failed to save cover image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e');
    }
  }
}
