import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_profile.dart';
import 'notification_service.dart';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Initialize service
  Future<UserService> init() async {
    return this;
  }

  // Schedule notifications based on user profile
  Future<void> _scheduleNotifications(UserProfile profile) async {
    try {
      final notificationService = Get.find<NotificationService>();

      // Only schedule if notifications are enabled
      if (profile.notificationsEnabled != true) {
        await notificationService.cancelAllNotifications();
        debugPrint('UserService: Notifications disabled by user');
        return;
      }

      // Show immediate test notification
      await notificationService.showImmediateNotification(
        title: 'Notifications Enabled! 🔔',
        body: 'You will receive daily reminders for workout and water intake.',
        payload: 'test',
      );

      // Schedule workout reminder
      if (profile.workoutReminderHour != null) {
        await notificationService.scheduleWorkoutReminder(
          hour: profile.workoutReminderHour!,
          minute: profile.workoutReminderMinute ?? 0,
        );
        debugPrint(
          'UserService: Workout reminder scheduled for ${profile.workoutReminderHour}:${profile.workoutReminderMinute ?? 0}',
        );
      }

      // Schedule water reminder
      if (profile.waterReminderHour != null) {
        await notificationService.scheduleWaterReminder(
          hour: profile.waterReminderHour!,
          minute: profile.waterReminderMinute ?? 0,
        );
        debugPrint(
          'UserService: Water reminder scheduled for ${profile.waterReminderHour}:${profile.waterReminderMinute ?? 0}',
        );
      }

      debugPrint('UserService: All notifications scheduled successfully');
    } catch (e) {
      debugPrint('UserService: Failed to schedule notifications: $e');
    }
  }

  // Create a new user profile
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.uid)
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final profile = UserProfile.fromSnapshot(doc);

      // Schedule notifications when profile is loaded
      await _scheduleNotifications(profile);

      return profile;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.uid)
          .update(profile.toMap());

      // Reschedule notifications after profile update
      await _scheduleNotifications(profile);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update specific fields
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      await _firestore.collection(_collection).doc(uid).update(fields);
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check user profile: $e');
    }
  }

  // Stream user profile (real-time updates)
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _firestore.collection(_collection).doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserProfile.fromSnapshot(doc);
    });
  }

  // Get all users (admin functionality)
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      return snapshot.docs.map((doc) => UserProfile.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Search users by name
  Future<List<UserProfile>> searchUsersByName(String searchTerm) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Update user photo URL
  Future<void> updatePhotoUrl(String uid, String photoUrl) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw Exception('Failed to update photo URL: $e');
    }
  }

  // Update user weight (for tracking progress)
  Future<void> updateWeight(String uid, double weight) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'weight': weight,
      });
    } catch (e) {
      throw Exception('Failed to update weight: $e');
    }
  }

  // Update user height
  Future<void> updateHeight(String uid, double height) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'height': height,
      });
    } catch (e) {
      throw Exception('Failed to update height: $e');
    }
  }

  // Get users by gender (for statistics)
  Future<List<UserProfile>> getUsersByGender(String gender) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('gender', isEqualTo: gender)
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get users by gender: $e');
    }
  }

  // Get users count
  Future<int> getUsersCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get users count: $e');
    }
  }

  // Batch update (for admin)
  Future<void> batchUpdateUsers(List<UserProfile> profiles) async {
    try {
      final batch = _firestore.batch();

      for (var profile in profiles) {
        final docRef = _firestore.collection(_collection).doc(profile.uid);
        batch.update(docRef, profile.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update users: $e');
    }
  }

  // Check if email exists (for validation)
  Future<bool> emailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email: $e');
    }
  }
}
