import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing local notifications
/// Handles daily reminders for workouts, water intake, and step goals
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int workoutReminderId = 1;
  static const int waterReminderId = 2;
  static const int stepGoalReminderId = 3;

  /// Initialize notification service
  Future<NotificationService> init() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'daily_reminders',
      'Daily Reminders',
      description: 'Daily reminders for workouts, water, and steps',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Create the channel on Android
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();

    debugPrint('NotificationService: Initialized with notification channel');
    return this;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Android 13+ permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    // Navigate based on payload
    switch (response.payload) {
      case 'workout':
        Get.toNamed('/home'); // Navigate to home/workout tab
        break;
      case 'water':
        Get.toNamed('/tools'); // Navigate to tools tab
        break;
      case 'steps':
        Get.toNamed('/progress'); // Navigate to progress tab
        break;
    }
  }

  /// Schedule daily workout reminder
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    String title = 'Time to Workout! 💪',
    String body = 'Don\'t break your streak! Complete your daily workout.',
  }) async {
    await _scheduleDailyNotification(
      id: workoutReminderId,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
      payload: 'workout',
    );

    debugPrint(
      'NotificationService: Workout reminder scheduled for $hour:$minute',
    );
  }

  /// Schedule daily water reminder
  Future<void> scheduleWaterReminder({
    required int hour,
    required int minute,
    String title = 'Stay Hydrated! 💧',
    String body = 'Time to drink water and keep yourself hydrated.',
  }) async {
    await _scheduleDailyNotification(
      id: waterReminderId,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
      payload: 'water',
    );

    debugPrint(
      'NotificationService: Water reminder scheduled for $hour:$minute',
    );
  }

  /// Schedule daily step goal reminder
  Future<void> scheduleStepGoalReminder({
    required int hour,
    required int minute,
    String title = 'Get Moving! 🚶',
    String body = 'You\'re close to your step goal! Take a quick walk.',
  }) async {
    await _scheduleDailyNotification(
      id: stepGoalReminderId,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
      payload: 'steps',
    );

    debugPrint(
      'NotificationService: Step goal reminder scheduled for $hour:$minute',
    );
  }

  /// Internal method to schedule daily notification
  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    // Cancel any existing notification with this ID first
    await _notifications.cancel(id);

    // Create notification time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
      0,
      0,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint(
      'NotificationService: Scheduling notification #$id for $scheduledDate',
    );

    // Android notification details with proper settings
    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Daily reminders for workouts, water, and steps',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Schedule the notification to repeat daily at the same time
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // This makes it repeat daily
        payload: payload,
      );

      debugPrint(
        'NotificationService: Successfully scheduled notification #$id',
      );
    } catch (e) {
      debugPrint('NotificationService: Error scheduling notification: $e');
      rethrow;
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('NotificationService: Cancelled notification $id');
  }

  /// Cancel workout reminder
  Future<void> cancelWorkoutReminder() async {
    await cancelNotification(workoutReminderId);
  }

  /// Cancel water reminder
  Future<void> cancelWaterReminder() async {
    await cancelNotification(waterReminderId);
  }

  /// Cancel step goal reminder
  Future<void> cancelStepGoalReminder() async {
    await cancelNotification(stepGoalReminderId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('NotificationService: Cancelled all notifications');
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate_notifications',
      'Immediate Notifications',
      channelDescription: 'Notifications shown immediately',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Use 0 for immediate notifications
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }

    return true; // Assume enabled for iOS
  }
}
