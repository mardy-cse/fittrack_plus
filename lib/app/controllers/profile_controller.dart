import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

/// Controller for managing user profile
class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
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
  final RxBool notificationsEnabled = true.obs;
  final RxInt workoutReminderHour = 8.obs;
  final RxInt workoutReminderMinute = 0.obs;
  final RxInt waterReminderHour = 10.obs;
  final RxInt waterReminderMinute = 0.obs;

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
    notificationsEnabled.value = profile.notificationsEnabled ?? true;
    workoutReminderHour.value = profile.workoutReminderHour ?? 8;
    workoutReminderMinute.value = profile.workoutReminderMinute ?? 0;
    waterReminderHour.value = profile.waterReminderHour ?? 10;
    waterReminderMinute.value = profile.waterReminderMinute ?? 0;
  }

  /// Toggle edit mode
  void toggleEditMode() {
    if (isEditMode.value) {
      // Cancel edit - reload profile
      if (userProfile.value != null) {
        _populateFields(userProfile.value!);
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

      // Update profile
      final updatedProfile = userProfile.value!.copyWith(
        name: nameController.text.trim(),
        age: age,
        height: height,
        weight: weight,
        gender: selectedGender.value,
        dailyStepGoal: stepGoal,
        notificationsEnabled: notificationsEnabled.value,
        workoutReminderHour: workoutReminderHour.value,
        workoutReminderMinute: workoutReminderMinute.value,
        waterReminderHour: waterReminderHour.value,
        waterReminderMinute: waterReminderMinute.value,
      );

      await _userService.updateUserProfile(updatedProfile);
      userProfile.value = updatedProfile;

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
        print('No image selected');
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

      print('Saving image locally for user: $userId');

      // Save to local storage instead of Firebase Storage (to avoid billing)
      final photoUrl = image.path;

      // Update profile with local photo path
      await _userService.updateUserFields(userId, {'photoUrl': photoUrl});
      print('Profile updated in Firestore with local path');

      // Update local profile
      if (userProfile.value != null) {
        userProfile.value = userProfile.value!.copyWith(photoUrl: photoUrl);
      }

      Get.snackbar(
        'Success',
        'Profile photo updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error saving photo: $e');
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

  /// Pick and save background image
  Future<void> pickBackgroundImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      backgroundImagePath.value = image.path;

      Get.snackbar(
        'Success',
        'Background image updated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show workout reminder time picker
  Future<void> pickWorkoutReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: workoutReminderHour.value,
        minute: workoutReminderMinute.value,
      ),
    );

    if (picked != null) {
      workoutReminderHour.value = picked.hour;
      workoutReminderMinute.value = picked.minute;

      // Save to Firestore immediately
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _userService.updateUserFields(userId, {
          'workoutReminderHour': picked.hour,
          'workoutReminderMinute': picked.minute,
        });

        // Update local profile
        if (userProfile.value != null) {
          userProfile.value = userProfile.value!.copyWith(
            workoutReminderHour: picked.hour,
            workoutReminderMinute: picked.minute,
          );
        }
      }

      // Immediately reschedule notification
      if (notificationsEnabled.value) {
        await _notificationService.scheduleWorkoutReminder(
          hour: picked.hour,
          minute: picked.minute,
        );

        // Show confirmation notification
        await _notificationService.showImmediateNotification(
          title: 'Workout Reminder Set ✅',
          body: 'You will receive daily reminders at ${picked.format(context)}',
          payload: 'workout',
        );

        Get.snackbar(
          'Saved',
          'Workout reminder set for ${picked.format(context)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  /// Show water reminder time picker
  Future<void> pickWaterReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: waterReminderHour.value,
        minute: waterReminderMinute.value,
      ),
    );

    if (picked != null) {
      waterReminderHour.value = picked.hour;
      waterReminderMinute.value = picked.minute;

      // Save to Firestore immediately
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _userService.updateUserFields(userId, {
          'waterReminderHour': picked.hour,
          'waterReminderMinute': picked.minute,
        });

        // Update local profile
        if (userProfile.value != null) {
          userProfile.value = userProfile.value!.copyWith(
            waterReminderHour: picked.hour,
            waterReminderMinute: picked.minute,
          );
        }
      }

      // Immediately reschedule notification
      if (notificationsEnabled.value) {
        await _notificationService.scheduleWaterReminder(
          hour: picked.hour,
          minute: picked.minute,
        );

        // Show confirmation notification
        await _notificationService.showImmediateNotification(
          title: 'Water Reminder Set ✅',
          body: 'You will receive daily reminders at ${picked.format(context)}',
          payload: 'water',
        );

        Get.snackbar(
          'Saved',
          'Water reminder set for ${picked.format(context)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;

    // Save to Firestore
    final userId = _authService.currentUserId;
    if (userId != null) {
      await _userService.updateUserFields(userId, {
        'notificationsEnabled': value,
      });

      // Update local profile
      if (userProfile.value != null) {
        userProfile.value = userProfile.value!.copyWith(
          notificationsEnabled: value,
        );
      }
    }

    if (value) {
      // Enable - schedule all notifications
      await _notificationService.scheduleWorkoutReminder(
        hour: workoutReminderHour.value,
        minute: workoutReminderMinute.value,
      );
      await _notificationService.scheduleWaterReminder(
        hour: waterReminderHour.value,
        minute: waterReminderMinute.value,
      );

      Get.snackbar(
        'Enabled',
        'Notifications have been enabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Disable - cancel all notifications
      await _notificationService.cancelAllNotifications();

      Get.snackbar(
        'Disabled',
        'Notifications have been disabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
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

  /// Format time for display
  String formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  /// Test notification (for debugging)
  Future<void> testNotification() async {
    try {
      await _notificationService.showImmediateNotification(
        title: 'Test Notification 🔔',
        body: 'This is a test notification. Your reminders are working!',
        payload: 'test',
      );

      Get.snackbar(
        'Sent',
        'Test notification sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification: $e');
    }
  }

  /// Check pending notifications (for debugging)
  Future<void> checkPendingNotifications() async {
    try {
      final pending = await _notificationService.getPendingNotifications();

      if (pending.isEmpty) {
        Get.snackbar(
          'No Pending Notifications',
          'There are no scheduled notifications',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        String message = 'Scheduled:\n';
        for (var notif in pending) {
          message += '• ID ${notif.id}: ${notif.title}\n';
        }

        Get.dialog(
          AlertDialog(
            title: const Text('Pending Notifications'),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check notifications: $e');
    }
  }
}
