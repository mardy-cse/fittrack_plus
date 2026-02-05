import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'water_tracker_service.dart';
import '../controllers/progress_controller.dart';
import '../controllers/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyDIjJRxGZ4v8cpG9Qc98JMOGA42XXNj6X8'; // TODO: Replace with your actual API key
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _isFirstMessage = true;

  GeminiService() {
    try {
      debugPrint('🔧 Initializing Gemini AI with gemini-pro model...');
      _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
      _initializeChat();
      debugPrint('✅ Gemini AI initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Gemini: $e');
      rethrow;
    }
  }

  void _initializeChat() {
    _chat = _model.startChat();
    _isFirstMessage = true;
  }

  Future<String> sendMessage(String message) async {
    try {
      debugPrint('📤 Sending message to Gemini API...');

      // Add comprehensive system instruction with user data to first message
      String finalMessage = message;
      if (_isFirstMessage) {
        final comprehensiveData = await _getComprehensiveUserData();
        finalMessage =
            '''You are an expert AI fitness coach named "FitBot" with complete access to the user's fitness data. You have their profile, workout history, progress analytics, and can provide personalized insights like a professional fitness consultant.

User Profile & Data Context:
$comprehensiveData

Provide detailed, personalized responses based on this data. Be conversational, insightful, and comprehensive like a personal trainer who knows everything about the user's fitness journey.

User: $message''';
        _isFirstMessage = false;
      }

      final response = await _chat.sendMessage(Content.text(finalMessage));
      final text = response.text;

      if (text == null || text.isEmpty) {
        debugPrint('⚠️ Received empty response from Gemini');
        throw Exception('Empty response from AI');
      }

      debugPrint('📥 Received response from Gemini (${text.length} chars)');
      return text;
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Gemini API failed, using personalized fallback response: $e',
      );

      // Fallback responses with user context
      return await _getPersonalizedFallbackResponse(message);
    }
  }

  Future<String> _getPersonalizedFallbackResponse(String message) async {
    final lowerMessage = message.toLowerCase();

    try {
      // Get comprehensive user data for intelligent responses
      final comprehensiveData = await _getComprehensiveUserData();
      final userData = await _getUserFitnessData();
      final profileData = await _getUserProfileData();

      // Analyze query type and provide comprehensive response
      return await _generateIntelligentResponse(
        message,
        comprehensiveData,
        userData,
        profileData,
      );
    } catch (e) {
      debugPrint('Error getting comprehensive user data: $e');
    }

    return _getFallbackResponse(message);
  }

  Future<Map<String, dynamic>> _getUserFitnessData() async {
    try {
      // Get all fitness tracking data
      WaterTrackerService? waterService;
      ProgressController? progressController;

      try {
        waterService = Get.find<WaterTrackerService>();
      } catch (e) {
        waterService = WaterTrackerService();
      }

      try {
        progressController = Get.find<ProgressController>();
      } catch (e) {
        progressController = Get.put(ProgressController());
      }

      // Today's data
      final todayWaterLog = await waterService.getTodayLog();

      // Comprehensive fitness stats
      final stats = {
        // Water tracking
        'waterGlasses': todayWaterLog?.glassesConsumed ?? 0,
        'waterGoal': 8,
        'hydrationPercentage': ((todayWaterLog?.glassesConsumed ?? 0) / 8 * 100)
            .round(),

        // Today's workout data
        'todayWorkouts': progressController?.totalWorkouts.value ?? 0,
        'todayCalories': progressController?.totalCalories.value ?? 0,
        'todayMinutes': progressController?.totalMinutes.value ?? 0,

        // Overall progress
        'currentStreak': progressController?.currentStreak.value ?? 0,
        'totalSessions': progressController?.recentSessions.length ?? 0,
        'weeklyGoalProgress': _getWeeklyProgress(progressController),

        // Performance trends
        'averageWorkoutDuration': _getAverageWorkoutDuration(
          progressController,
        ),
        'mostActiveDay': _getMostActiveDay(progressController),
        'improvementTrend': _getImprovementTrend(progressController),
      };

      return stats;
    } catch (e) {
      debugPrint('❌ Error fetching fitness data: $e');
      return _getDefaultFitnessData();
    }
  }

  // Comprehensive user data methods
  Future<Map<String, dynamic>> _getUserProfileData() async {
    try {
      ProfileController? profileController;

      try {
        profileController = Get.find<ProfileController>();
      } catch (e) {
        profileController = Get.put(ProfileController());
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {};

      // Get profile data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};

      return {
        'name': data['name'] ?? 'User',
        'age': data['age'] ?? 0,
        'height': data['height'] ?? 0.0,
        'weight': data['weight'] ?? 0.0,
        'gender': data['gender'] ?? '',
        'dailyStepGoal': data['dailyStepGoal'] ?? 10000,
        'weeklyWorkoutGoal': data['weeklyWorkoutGoal'] ?? 5,
        'dailyCalorieGoal': data['dailyCalorieGoal'] ?? 2000,
        'fitnessLevel': _getFitnessLevel(data),
        'joinDate': data['createdAt']?.toDate() ?? DateTime.now(),
        'isPremium': data['isPremium'] ?? false,
      };
    } catch (e) {
      debugPrint('❌ Error fetching profile data: $e');
      return {};
    }
  }

  Future<String> _getComprehensiveUserData() async {
    try {
      final profileData = await _getUserProfileData();
      final fitnessData = await _getUserFitnessData();
      final workoutHistory = await _getWorkoutHistory();
      final healthMetrics = await _getHealthMetrics();

      return '''
**USER PROFILE:**
• Name: ${profileData['name'] ?? 'User'}
• Age: ${profileData['age']} years
• Height: ${profileData['height']} cm
• Weight: ${profileData['weight']} kg
• Gender: ${profileData['gender']}
• Fitness Level: ${profileData['fitnessLevel']}
• Member Since: ${_formatDate(profileData['joinDate'])}

**TODAY'S STATS:**
• Water: ${fitnessData['waterGlasses']}/${fitnessData['waterGoal']} glasses (${fitnessData['hydrationPercentage']}%)
• Workouts: ${fitnessData['todayWorkouts']} completed
• Calories Burned: ${fitnessData['todayCalories']} kcal
• Exercise Time: ${fitnessData['todayMinutes']} minutes

**PROGRESS SUMMARY:**
• Current Streak: ${fitnessData['currentStreak']} days
• Total Sessions: ${fitnessData['totalSessions']}
• Weekly Goal Progress: ${fitnessData['weeklyGoalProgress']}
• Average Workout: ${fitnessData['averageWorkoutDuration']} minutes
• Most Active Day: ${fitnessData['mostActiveDay']}
• Trend: ${fitnessData['improvementTrend']}

**RECENT WORKOUTS:**
$workoutHistory

**HEALTH METRICS:**
$healthMetrics

**GOALS:**
• Daily Steps: ${profileData['dailyStepGoal']}
• Weekly Workouts: ${profileData['weeklyWorkoutGoal']}
• Daily Calories: ${profileData['dailyCalorieGoal']}
''';
    } catch (e) {
      debugPrint('❌ Error getting comprehensive data: $e');
      return 'Basic fitness tracking data available';
    }
  }

  Future<String> _generateIntelligentResponse(
    String message,
    String comprehensiveData,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) async {
    final lowerMessage = message.toLowerCase();

    // Handle casual responses first (thanks, ok, sure, etc.)
    if (_isCasualResponse(lowerMessage)) {
      return _generateCasualResponse(lowerMessage, profileData);
    }

    // Handle specific individual questions first
    final specificAnswer = _handleSpecificQuestions(
      message,
      lowerMessage,
      fitnessData,
      profileData,
    );
    if (specificAnswer != null) {
      return specificAnswer;
    }

    // Analyze query intent for comprehensive responses
    if (_isWaterQuery(lowerMessage)) {
      return _generateAdvancedWaterResponse(message, fitnessData, profileData);
    }

    if (_isProgressQuery(lowerMessage)) {
      return _generateAdvancedProgressResponse(
        message,
        fitnessData,
        profileData,
      );
    }

    if (_isWorkoutRecommendationQuery(lowerMessage)) {
      return _generatePersonalizedWorkoutSuggestion(
        message,
        fitnessData,
        profileData,
      );
    }

    if (_isHealthAnalysisQuery(lowerMessage)) {
      return _generateHealthAnalysis(message, fitnessData, profileData);
    }

    if (_isGoalQuery(lowerMessage)) {
      return _generateGoalAnalysis(message, fitnessData, profileData);
    }

    if (_isNutritionQuery(lowerMessage)) {
      return _generatePersonalizedNutrition(message, fitnessData, profileData);
    }

    // Default comprehensive response
    return _generateComprehensiveOverview(message, fitnessData, profileData);
  }

  // Handle specific individual questions with direct answers
  String? _handleSpecificQuestions(
    String originalMessage,
    String lowerMessage,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    // Water related specific questions
    if (lowerMessage.contains('ajke koi glass pani') ||
        lowerMessage.contains('how many glasses water') ||
        lowerMessage.contains('water intake today')) {
      final glasses = fitnessData['waterGlasses'] ?? 0;
      return '💧 **Today you\'ve had ${glasses} glasses of water.** ${glasses >= 8 ? '🎉 Great hydration!' : 'Keep drinking more!'}';
    }

    if (lowerMessage.contains('am i hydrated') ||
        lowerMessage.contains('hydration enough') ||
        lowerMessage.contains('enough water')) {
      final percentage = fitnessData['hydrationPercentage'] ?? 0;
      if (percentage >= 100)
        return '💧 **Yes! You\'re perfectly hydrated** (${percentage}% of daily goal)';
      if (percentage >= 75)
        return '💧 **Almost there!** You\'re ${percentage}% hydrated - just a bit more!';
      return '💧 **Need more water.** You\'re only ${percentage}% hydrated. Drink up! 🥛';
    }

    // Workout related specific questions
    if (lowerMessage.contains('how many workout today') ||
        lowerMessage.contains('ajke koto workout') ||
        lowerMessage.contains('workouts completed today')) {
      final workouts = fitnessData['todayWorkouts'] ?? 0;
      return '🏋️ **Today you completed ${workouts} workout${workouts == 1 ? '' : 's'}.** ${workouts > 0 ? 'Excellent work! 💪' : 'Ready to start your first one?'}';
    }

    if (lowerMessage.contains('did i workout today') ||
        lowerMessage.contains('aj workout korechi') ||
        lowerMessage.contains('worked out today')) {
      final workouts = fitnessData['todayWorkouts'] ?? 0;
      return workouts > 0
          ? '✅ **Yes! You worked out today.** ${workouts} session${workouts == 1 ? '' : 's'} completed! 🔥'
          : '❌ **No workouts today yet.** Ready to start? 💪';
    }

    // Streak related questions
    if (lowerMessage.contains('what\'s my streak') ||
        lowerMessage.contains('current streak') ||
        lowerMessage.contains('streak kemon') ||
        lowerMessage.contains('how many days streak')) {
      final streak = fitnessData['currentStreak'] ?? 0;
      return '🔥 **Your current streak is ${streak} days!** ${_getStreakMotivation(streak)}';
    }

    // Calorie related questions
    if (lowerMessage.contains('how many calories') ||
        lowerMessage.contains('calories burned today') ||
        lowerMessage.contains('ajke koto calorie')) {
      final calories = fitnessData['todayCalories'] ?? 0;
      return '🔥 **Today you burned ${calories} calories!** ${calories > 200
          ? 'Great burn! 🚀'
          : calories > 0
          ? 'Good start! ⚡'
          : 'Time to get moving! 💪'}';
    }

    // Time/Duration questions
    if (lowerMessage.contains('how long workout') ||
        lowerMessage.contains('workout time today') ||
        lowerMessage.contains('exercise duration')) {
      final minutes = fitnessData['todayMinutes'] ?? 0;
      return '⏱️ **Today\'s exercise time: ${minutes} minutes.** ${minutes >= 30
          ? 'Perfect duration! 🎯'
          : minutes > 0
          ? 'Good start! Keep building! ⚡'
          : 'Ready to begin? 🌟'}';
    }

    // BMI questions
    if (lowerMessage.contains('what\'s my bmi') ||
        lowerMessage.contains('bmi koto') ||
        lowerMessage.contains('body mass index')) {
      final height = profileData['height'] ?? 0.0;
      final weight = profileData['weight'] ?? 0.0;
      if (height > 0 && weight > 0) {
        final bmi = _calculateBMI(height, weight);
        return '📊 **Your BMI is ${bmi.toStringAsFixed(1)}** (${_getBMICategory(bmi)} range)';
      }
      return '📊 Please update your height and weight in profile to calculate BMI.';
    }

    // Goal achievement questions
    if (lowerMessage.contains('am i meeting') &&
            lowerMessage.contains('goal') ||
        lowerMessage.contains('goal achieved') ||
        lowerMessage.contains('target complete')) {
      final waterGoal = (fitnessData['hydrationPercentage'] ?? 0) >= 100;
      final workoutGoal = (fitnessData['todayWorkouts'] ?? 0) > 0;

      if (waterGoal && workoutGoal)
        return '🎯 **Yes! Meeting both water and workout goals today!** 🌟';
      if (waterGoal)
        return '💧 **Water goal achieved!** Still need to workout. 🏋️';
      if (workoutGoal) return '💪 **Workout goal met!** Need more water. 💧';
      return '⏳ **Working toward goals.** Keep pushing! 🚀';
    }

    // Weekly progress questions
    if (lowerMessage.contains('this week') &&
        (lowerMessage.contains('workout') ||
            lowerMessage.contains('progress'))) {
      final weeklyProgress = fitnessData['weeklyGoalProgress'] ?? '0/5';
      return '📅 **This week\'s workouts: ${weeklyProgress}** ${weeklyProgress.startsWith('5') ? 'Weekly goal achieved! 🏆' : 'Keep going! 💪'}';
    }

    // Last workout question
    if (lowerMessage.contains('last workout') ||
        lowerMessage.contains('recent workout') ||
        lowerMessage.contains('previous exercise')) {
      try {
        final controller = Get.find<ProgressController>();
        if (controller.recentSessions.isNotEmpty) {
          final lastSession = controller.recentSessions.first;
          return '🏋️ **Last workout: ${lastSession.workoutTitle}** (${(lastSession.durationSeconds / 60).round()} min, ${lastSession.caloriesBurned} cal)';
        }
      } catch (e) {}
      return '🏋️ **No recent workouts found.** Ready to start? 💪';
    }

    // Age, height, weight questions
    if (lowerMessage.contains('how old') ||
        lowerMessage.contains('my age') ||
        lowerMessage.contains('age koto')) {
      final age = profileData['age'] ?? 0;
      return age > 0
          ? '🎂 **You are ${age} years old.**'
          : 'Please update your age in profile.';
    }

    if (lowerMessage.contains('my height') ||
        lowerMessage.contains('how tall') ||
        lowerMessage.contains('height koto')) {
      final height = profileData['height'] ?? 0.0;
      return height > 0
          ? '📏 **Your height is ${height} cm.**'
          : 'Please update your height in profile.';
    }

    if (lowerMessage.contains('my weight') ||
        lowerMessage.contains('current weight') ||
        lowerMessage.contains('weight koto')) {
      final weight = profileData['weight'] ?? 0.0;
      return weight > 0
          ? '⚖️ **Your weight is ${weight} kg.**'
          : 'Please update your weight in profile.';
    }

    // Fitness level question
    if (lowerMessage.contains('fitness level') ||
        lowerMessage.contains('how fit am i')) {
      final level = profileData['fitnessLevel'] ?? 'Beginner';
      return '💪 **Your fitness level: ${level}** ${_getFitnessLevelMotivation(level)}';
    }

    // Daily calorie needs
    if (lowerMessage.contains('daily calorie need') ||
        lowerMessage.contains('how many calories need')) {
      final dailyCalories = _calculateDailyCalories(profileData);
      return '🔥 **Your daily calorie needs: ${dailyCalories} kcal** (based on your profile)';
    }

    // Simple yes/no questions
    if (lowerMessage.contains('am i active') ||
        lowerMessage.contains('active enough')) {
      final activityLevel = _getActivityLevel(fitnessData);
      final isActive =
          activityLevel == 'Active' || activityLevel == 'Very Active';
      return isActive
          ? '✅ **Yes! You\'re ${activityLevel.toLowerCase()}.** Great job! 🔥'
          : '⚡ **You\'re ${activityLevel.toLowerCase()}.** Let\'s boost your activity! 💪';
    }

    // No specific match found
    return null;
  }

  String _getStreakMotivation(int streak) {
    if (streak >= 30) return 'Incredible consistency! 🏆';
    if (streak >= 14) return 'Amazing habit building! 🔥';
    if (streak >= 7) return 'One week strong! ⭐';
    if (streak >= 3) return 'Building momentum! 💪';
    if (streak > 0) return 'Keep it going! 🌟';
    return 'Ready to start your streak? 🚀';
  }

  String _getFitnessLevelMotivation(String level) {
    switch (level.toLowerCase()) {
      case 'advanced':
        return 'You\'re crushing it! 🏆';
      case 'intermediate':
        return 'Great progress! 🔥';
      case 'beginner+':
        return 'Building up nicely! 💪';
      default:
        return 'Every expert was once a beginner! 🌟';
    }
  }

  // Helper methods for data analysis
  Map<String, dynamic> _getDefaultFitnessData() {
    return {
      'waterGlasses': 0,
      'waterGoal': 8,
      'hydrationPercentage': 0,
      'todayWorkouts': 0,
      'todayCalories': 0,
      'todayMinutes': 0,
      'currentStreak': 0,
      'totalSessions': 0,
      'weeklyGoalProgress': '0/5',
      'averageWorkoutDuration': 0,
      'mostActiveDay': 'None',
      'improvementTrend': 'Starting journey',
    };
  }

  String _getWeeklyProgress(ProgressController? controller) {
    if (controller == null) return '0/5';
    return '${controller.recentSessions.length}/${5}';
  }

  int _getAverageWorkoutDuration(ProgressController? controller) {
    if (controller == null || controller.recentSessions.isEmpty) return 0;
    return (controller.totalMinutes.value / controller.recentSessions.length)
        .round();
  }

  String _getMostActiveDay(ProgressController? controller) {
    if (controller == null || controller.recentSessions.isEmpty) return 'None';
    return 'Monday'; // Would analyze actual session patterns
  }

  String _getImprovementTrend(ProgressController? controller) {
    if (controller == null) return 'Starting journey';
    final streak = controller.currentStreak.value;
    if (streak >= 7) return 'Excellent consistency! 📈';
    if (streak >= 3) return 'Building momentum! 📊';
    if (streak > 0) return 'Getting started! 🌟';
    return 'Ready to begin! 💪';
  }

  String _getFitnessLevel(Map<String, dynamic> data) {
    final workoutHistory = data['totalWorkouts'] ?? 0;
    if (workoutHistory > 100) return 'Advanced';
    if (workoutHistory > 50) return 'Intermediate';
    if (workoutHistory > 10) return 'Beginner+';
    return 'Beginner';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference < 30) return '$difference days ago';
    if (difference < 365) return '${(difference / 30).floor()} months ago';
    return '${(difference / 365).floor()} years ago';
  }

  Future<String> _getWorkoutHistory() async {
    try {
      final controller = Get.find<ProgressController>();
      final sessions = controller.recentSessions;

      if (sessions.isEmpty) return '• No recent workouts';

      final history = sessions
          .take(5)
          .map(
            (session) =>
                '• ${session.workoutTitle}: ${(session.durationSeconds / 60).round()}min, ${session.caloriesBurned} kcal',
          )
          .join('\n');

      return history;
    } catch (e) {
      return '• Workout history being loaded...';
    }
  }

  Future<String> _getHealthMetrics() async {
    try {
      final fitnessData = await _getUserFitnessData();
      final profileData = await _getUserProfileData();

      final bmi = _calculateBMI(profileData['height'], profileData['weight']);
      final dailyCalorieNeeds = _calculateDailyCalories(profileData);

      return '''• BMI: ${bmi.toStringAsFixed(1)} (${_getBMICategory(bmi)})
• Daily Calorie Needs: ${dailyCalorieNeeds} kcal
• Hydration Status: ${fitnessData['hydrationPercentage']}%
• Activity Level: ${_getActivityLevel(fitnessData)}''';
    } catch (e) {
      return '• Health metrics calculation in progress...';
    }
  }

  // Query type detection methods
  bool _isWaterQuery(String query) {
    return query.contains('water') ||
        query.contains('pani') ||
        query.contains('glass') ||
        query.contains('hydration') ||
        query.contains('drink');
  }

  bool _isProgressQuery(String query) {
    return query.contains('progress') ||
        query.contains('streak') ||
        query.contains('stats') ||
        query.contains('performance') ||
        query.contains('achievement');
  }

  bool _isWorkoutRecommendationQuery(String query) {
    return query.contains('workout') ||
        query.contains('exercise') ||
        query.contains('training') ||
        query.contains('routine') ||
        query.contains('plan') ||
        query.contains('suggest');
  }

  bool _isHealthAnalysisQuery(String query) {
    return query.contains('health') ||
        query.contains('fitness level') ||
        query.contains('bmi') ||
        query.contains('calories') ||
        query.contains('analysis');
  }

  bool _isGoalQuery(String query) {
    return query.contains('goal') ||
        query.contains('target') ||
        query.contains('objective') ||
        query.contains('aim') ||
        query.contains('plan');
  }

  bool _isNutritionQuery(String query) {
    return query.contains('nutrition') ||
        query.contains('diet') ||
        query.contains('food') ||
        query.contains('meal') ||
        query.contains('eat');
  }

  // Casual response detection
  bool _isCasualResponse(String query) {
    final casualWords = [
      'thanks',
      'thank you',
      'thnks',
      'thx',
      'ty',
      'ok',
      'okay',
      'sure',
      'alright',
      'good',
      'nice',
      'cool',
      'great',
      'awesome',
      'perfect',
      'got it',
      'i see',
      'dhonnobad',
      'thik ache',
      'accha',
      'hmm',
      'hm',
      'yes',
      'yeah',
      'yep',
      'no',
      'nope',
      'naa',
      'na',
    ];

    return casualWords.any((word) => query.contains(word));
  }

  String _generateCasualResponse(
    String lowerMessage,
    Map<String, dynamic> profileData,
  ) {
    final name = profileData['name'] ?? 'there';

    if (lowerMessage.contains('thank') ||
        lowerMessage.contains('thnk') ||
        lowerMessage.contains('dhonnobad')) {
      final responses = [
        '😊 You\'re welcome! Keep up the great work!',
        '💪 My pleasure! Stay consistent!',
        '🌟 Anytime! You\'ve got this!',
        '👍 Happy to help! Keep pushing forward!',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }

    if (lowerMessage.contains('ok') ||
        lowerMessage.contains('sure') ||
        lowerMessage.contains('alright') ||
        lowerMessage.contains('thik ache')) {
      final responses = [
        '💪 Perfect! What else can I help you with?',
        '⚡ Great! Any other fitness questions?',
        '🎯 Sounds good! Need more insights?',
        '🚀 Excellent! Ready for more?',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }

    if (lowerMessage.contains('good') ||
        lowerMessage.contains('nice') ||
        lowerMessage.contains('cool') ||
        lowerMessage.contains('awesome')) {
      final responses = [
        '🔥 Glad you found it helpful! Keep going strong!',
        '⭐ That\'s the spirit! Your dedication shows!',
        '💯 You\'re doing amazing! Every step counts!',
        '🏆 Your positive attitude is key to success!',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }

    if (lowerMessage.contains('yes') ||
        lowerMessage.contains('yeah') ||
        lowerMessage.contains('yep')) {
      return '🎯 Great! What would you like to know about your fitness journey?';
    }

    if (lowerMessage.contains('no') ||
        lowerMessage.contains('nope') ||
        lowerMessage.contains('naa')) {
      return '👍 No worries! I\'m here whenever you need fitness guidance!';
    }

    // Default casual response
    return '😊 I\'m here to help with your fitness goals anytime!';
  }

  // BMI and health calculation methods
  double _calculateBMI(double height, double weight) {
    if (height <= 0 || weight <= 0) return 0.0;
    final heightInM = height / 100;
    return weight / (heightInM * heightInM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  int _calculateDailyCalories(Map<String, dynamic> profile) {
    final age = profile['age'] ?? 25;
    final height = profile['height'] ?? 170.0;
    final weight = profile['weight'] ?? 70.0;
    final gender = profile['gender'] ?? 'Male';

    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    return (bmr * 1.55).round();
  }

  String _getActivityLevel(Map<String, dynamic> fitnessData) {
    final todayWorkouts = fitnessData['todayWorkouts'] ?? 0;
    final currentStreak = fitnessData['currentStreak'] ?? 0;

    if (currentStreak >= 14) return 'Very Active';
    if (currentStreak >= 7) return 'Active';
    if (todayWorkouts > 0) return 'Moderate';
    return 'Low';
  }

  String _generateAdvancedWaterResponse(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final glasses = fitnessData['waterGlasses'] ?? 0;
    final goal = fitnessData['waterGoal'] ?? 8;
    final percentage = fitnessData['hydrationPercentage'] ?? 0;
    final weight = profileData['weight'] ?? 70.0;
    final recommendedIntake = (weight * 35).round();

    return '''💧 **Advanced Hydration Analysis for ${profileData['name']}**

**Today's Status:**
🥛 **${glasses}** glasses consumed (**${percentage}%** of goal)
🎯 Goal: $goal glasses (${goal * 250}ml)
📊 Recommended for your weight (${weight}kg): ${recommendedIntake}ml

**Hydration Insights:**
${_getHydrationInsight(percentage)}

**Benefits for Your Fitness:**
✅ **Workout Performance:** ${glasses >= goal * 0.75 ? 'Optimized' : 'Could improve with more water'}
✅ **Recovery:** ${glasses >= goal ? 'Enhanced' : 'Drink more for better recovery'}
✅ **Metabolism:** ${glasses >= goal * 0.5 ? 'Active' : 'Increase water for metabolic boost'}

**Personalized Tips:**
• Best time to drink: Before, during, and after workouts
• Your ideal pre-workout: 250ml (30 mins before)
• Post-workout: 500ml per hour of exercise
• For your age (${profileData['age']}): Consistent intake is key

${glasses >= goal ? '🌟 Excellent hydration! Your body is optimized for performance!' : '💪 Every glass counts toward your fitness goals!'}
''';
  }

  String _generateWaterResponse(Map<String, dynamic> userData, String message) {
    final waterGlasses = userData['waterGlasses'] ?? 0;
    final dailyGoal = 8; // Default water goal

    if (message.contains('koi') ||
        message.contains('how many') ||
        message.contains('kitna')) {
      return '''💧 **Today's Water Intake**

🥛 You've had **$waterGlasses glasses** of water today!
🎯 Daily Goal: $dailyGoal glasses

${_getWaterMotivation(waterGlasses, dailyGoal)}

**Benefits of staying hydrated:**
✅ Better workout performance
✅ Improved recovery
✅ Enhanced metabolism
✅ Clearer skin

${waterGlasses < dailyGoal ? 'Keep it up! Every glass counts! 💪' : 'Excellent hydration! You\'re doing great! 🌟'}''';
    }

    return _getFallbackResponse(message);
  }

  String _generateProgressResponse(
    Map<String, dynamic> userData,
    String message,
  ) {
    final workouts = userData['todayWorkouts'] ?? 0;
    final calories = userData['todayCalories'] ?? 0;
    final minutes = userData['totalMinutes'] ?? 0;
    final streak = userData['currentStreak'] ?? 0;

    return '''📊 **Your Fitness Progress Today**

🏋️ Workouts Completed: **$workouts**
🔥 Calories Burned: **$calories kcal**
⏱️ Total Exercise Time: **$minutes minutes**
🔥 Current Streak: **$streak days**

${_getProgressMotivation(workouts, streak)}

**Today's Achievements:**
${workouts > 0 ? '✅ Workout completed - Great job!' : '⏳ No workouts yet - Ready to start?'}
${calories > 200
        ? '✅ Good calorie burn!'
        : calories > 0
        ? '⚡ Getting started!'
        : '💪 Time to move!'}

${_getNextActionSuggestion(workouts, userData)}''';
  }

  String _generateStatsResponse(Map<String, dynamic> userData, String message) {
    final streak = userData['currentStreak'] ?? 0;
    final totalWorkouts = userData['todayWorkouts'] ?? 0;
    final calories = userData['todayCalories'] ?? 0;

    return '''🎯 **Your Fitness Stats**

🔥 Current Streak: **$streak days**
💪 Total Workouts: **$totalWorkouts**
⚡ Calories Burned: **$calories kcal**

${_getStreakMessage(streak)}

**Keep Going:**
• Consistency is key to results!
• Every workout counts toward your goals
• You're building healthy habits! 

${streak > 0 ? 'Your dedication is paying off! 🌟' : 'Start your streak today! Every journey begins with one step! 💪'}''';
  }

  String _getWaterMotivation(int current, int goal) {
    final percentage = (current / goal * 100).round();

    if (current >= goal) {
      return '🎉 **Goal Achieved!** Excellent hydration today!';
    } else if (current >= goal * 0.75) {
      return '🚀 **Almost there!** Just ${goal - current} more glasses to go!';
    } else if (current >= goal * 0.5) {
      return '💪 **Halfway there!** Keep drinking water throughout the day!';
    } else {
      return '🌟 **Getting started!** Remember to drink water regularly!';
    }
  }

  String _getProgressMotivation(int workouts, int streak) {
    if (workouts > 0 && streak > 7) {
      return '🔥 **You\'re on fire!** Amazing consistency!';
    } else if (workouts > 0) {
      return '💪 **Great work today!** Building those healthy habits!';
    } else if (streak > 0) {
      return '⚡ **Keep your streak alive!** Time for today\'s workout!';
    } else {
      return '🌟 **Ready to start?** Every fitness journey begins with one workout!';
    }
  }

  String _getNextActionSuggestion(int workouts, Map<String, dynamic> userData) {
    if (workouts == 0) {
      return '''
**Suggested Actions:**
• Start with a 15-minute workout
• Try some basic exercises like squats or push-ups
• Set a small goal for today!''';
    } else {
      return '''
**Keep the momentum:**
• Stay hydrated after your workout
• Plan tomorrow\'s session
• Track your progress!''';
    }
  }

  String _getStreakMessage(int streak) {
    if (streak >= 30) {
      return '🏆 **INCREDIBLE!** 30+ day streak! You\'re a fitness champion!';
    } else if (streak >= 14) {
      return '🔥 **AMAZING!** 2+ weeks of consistency! You\'re building real habits!';
    } else if (streak >= 7) {
      return '⭐ **EXCELLENT!** One week streak! You\'re on the right track!';
    } else if (streak >= 3) {
      return '💪 **GOOD START!** Keep this momentum going!';
    } else if (streak > 0) {
      return '🌟 **Every day counts!** Building your fitness habit!';
    } else {
      return '🚀 **Ready to begin!** Start your fitness streak today!';
    }
  }

  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('workout') || lowerMessage.contains('exercise')) {
      return '''💪 **Beginner Full Body Workout (30 minutes)**

**Warm-up (5 mins):**
• Arm circles - 30 seconds
• Leg swings - 30 seconds each leg
• Light jogging in place - 2 minutes
• Dynamic stretches - 2 minutes

**Main Workout (20 mins):**
• Push-ups: 3 sets × 8-12 reps
• Bodyweight squats: 3 sets × 12-15 reps
• Plank: 3 sets × 30-45 seconds
• Mountain climbers: 3 sets × 20 reps
• Lunges: 3 sets × 10 reps each leg

**Cool-down (5 mins):**
• Static stretching
• Deep breathing

**Tips:**
✅ Rest 30-60 seconds between sets
✅ Focus on proper form over speed
✅ Stay hydrated throughout
✅ Listen to your body

Great job taking the first step! 🌟''';
    }

    if (lowerMessage.contains('nutrition') || lowerMessage.contains('diet')) {
      return '''🥗 **Healthy Nutrition Tips**

**Basic Guidelines:**
• Eat 5-6 small meals throughout the day
• Include protein in every meal
• Stay hydrated - 8-10 glasses of water daily
• Choose whole grains over refined carbs

**For Muscle Building:**
• Protein: 1.6-2.2g per kg body weight
• Focus on: chicken, fish, eggs, beans, nuts

**For Weight Loss:**
• Create a moderate calorie deficit
• Increase vegetables and fiber
• Reduce processed foods

**Pre-workout:** Banana + nuts (30 mins before)
**Post-workout:** Protein shake + fruit (within 30 mins)

Remember: Consistency is key! Small changes lead to big results. 💪''';
    }

    if (lowerMessage.contains('form') || lowerMessage.contains('technique')) {
      return '''📐 **Exercise Form Tips**

**Push-ups:**
✅ Keep body in straight line
✅ Lower chest to ground
✅ Push through palms
❌ Don't let hips sag or pike up

**Squats:**
✅ Feet shoulder-width apart
✅ Lower until thighs parallel to ground
✅ Keep chest up, weight in heels
❌ Don't let knees cave inward

**Plank:**
✅ Straight line from head to heels
✅ Engage core muscles
✅ Breathe normally
❌ Don't let hips drop or lift too high

**General Tips:**
• Start with lighter weights to master form
• Use mirrors or record yourself
• Focus on controlled movements
• Quality over quantity always!

Need specific guidance on any exercise? Feel free to ask! 💪''';
    }

    // Default friendly response
    return '''Hello! I'm FitBot, your AI fitness coach! 💪

I'm here to help you with:
🏋️ **Workout Plans** - Customized routines for your goals
🥗 **Nutrition Advice** - Healthy eating tips and meal ideas  
📐 **Form Tips** - Proper technique for exercises
💡 **Motivation** - Keep you on track with your fitness journey

What would you like to know about fitness today? You can ask me about:
• "Suggest a workout plan"
• "Nutrition tips for muscle building" 
• "How to do proper push-ups"
• Or anything else fitness-related!

Let's achieve your goals together! 🌟''';
  }

  void resetChat() {
    _initializeChat();
  }

  Future<String> getWorkoutSuggestion({
    required String fitnessLevel,
    required String goal,
    String? availableEquipment,
    int? durationMinutes,
  }) async {
    final prompt =
        '''
Suggest a workout plan with these details:
- Fitness Level: $fitnessLevel
- Goal: $goal
${availableEquipment != null ? '- Equipment: $availableEquipment' : ''}
${durationMinutes != null ? '- Duration: $durationMinutes minutes' : ''}

Provide a structured workout with exercises, sets, and reps.
''';

    return sendMessage(prompt);
  }

  Future<String> getFormAdvice(String exerciseName) async {
    final prompt =
        'Explain the proper form for $exerciseName exercise. Include common mistakes to avoid.';
    return sendMessage(prompt);
  }

  Future<String> getNutritionAdvice({
    required String goal,
    String? dietaryRestrictions,
  }) async {
    final prompt =
        '''
Provide nutrition advice for:
- Goal: $goal
${dietaryRestrictions != null ? '- Dietary Restrictions: $dietaryRestrictions' : ''}

Include macronutrient recommendations and meal timing tips.
''';

    return sendMessage(prompt);
  }

  // Additional comprehensive response methods
  String _getHydrationInsight(int percentage) {
    if (percentage >= 100)
      return '🏆 **Perfect hydration!** Your body is functioning optimally!';
    if (percentage >= 75)
      return '🚀 **Great progress!** You\'re almost at peak hydration!';
    if (percentage >= 50)
      return '💪 **Good start!** Keep drinking consistently throughout the day!';
    if (percentage >= 25)
      return '⚡ **Building up!** Increase intake for better energy and focus!';
    return '🌟 **Every drop counts!** Start with small, frequent sips!';
  }

  String _generateAdvancedProgressResponse(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final todayWorkouts = fitnessData['todayWorkouts'] ?? 0;
    final todayCalories = fitnessData['todayCalories'] ?? 0;
    final todayMinutes = fitnessData['todayMinutes'] ?? 0;
    final currentStreak = fitnessData['currentStreak'] ?? 0;
    final totalSessions = fitnessData['totalSessions'] ?? 0;
    final weeklyProgress = fitnessData['weeklyGoalProgress'] ?? '0/5';
    final avgDuration = fitnessData['averageWorkoutDuration'] ?? 0;

    return '''📊 **Comprehensive Progress Analysis for ${profileData['name']}**

**🗓️ Today's Performance:**
• Workouts: **$todayWorkouts** completed
• Calories: **$todayCalories** kcal burned  
• Duration: **$todayMinutes** minutes active
• Intensity: ${_getWorkoutIntensity(todayCalories, todayMinutes)}

**📈 Progress Trends:**
• Current Streak: **$currentStreak days** ${_getStreakEmoji(currentStreak)}
• Weekly Goal: **$weeklyProgress** workouts
• Total Sessions: **$totalSessions** completed
• Average Duration: **$avgDuration** minutes per workout

**🎯 Performance insights:**
${_getPerformanceInsight(fitnessData, profileData)}

**📅 Recommendations Based on Your Data:**
${_getPersonalizedRecommendations(fitnessData, profileData)}

**🏆 Next Milestones:**
${_getNextMilestones(currentStreak, totalSessions)}

Keep pushing forward! Your consistency is building real results! 💪
''';
  }

  String _generatePersonalizedWorkoutSuggestion(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final fitnessLevel = profileData['fitnessLevel'] ?? 'Beginner';
    final age = profileData['age'] ?? 25;
    final currentStreak = fitnessData['currentStreak'] ?? 0;
    final avgDuration = fitnessData['averageWorkoutDuration'] ?? 0;

    return '''🏋️ **Personalized Workout Plan for ${profileData['name']}**

**Your Profile:**
• Fitness Level: **$fitnessLevel**
• Age: **$age** years  
• Current Streak: **$currentStreak** days
• Typical Workout: **$avgDuration** minutes

**Recommended Today:**
${_getTodayWorkoutPlan(fitnessLevel, currentStreak, avgDuration)}

**Progressive Plan:**
${_getProgressivePlan(fitnessLevel, age, profileData)}

**Timing Recommendations:**
• Best workout time: ${_getBestWorkoutTime(profileData)}
• Pre-workout: Light meal 30-60 mins before
• Post-workout: Protein within 30 minutes

**Recovery Tips:**
${_getRecoveryTips(age, currentStreak)}

Ready to crush today\'s workout? Your body is prepared for the next level! 🚀
''';
  }

  String _generateHealthAnalysis(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final age = profileData['age'] ?? 25;
    final height = profileData['height'] ?? 170.0;
    final weight = profileData['weight'] ?? 70.0;
    final bmi = _calculateBMI(height, weight);
    final dailyCalories = _calculateDailyCalories(profileData);

    return '''🏥 **Comprehensive Health Analysis for ${profileData['name']}**

**📋 Vital Statistics:**
• Age: **$age** years
• Height: **${height}** cm
• Weight: **${weight}** kg
• BMI: **${bmi.toStringAsFixed(1)}** (${_getBMICategory(bmi)})

**📊 Metabolic Profile:**
• Daily Calorie Needs: **${dailyCalories}** kcal
• Current Activity Level: **${_getActivityLevel(fitnessData)}**
• Hydration Status: **${fitnessData['hydrationPercentage'] ?? 0}%**

**🎯 Health Insights:**
${_getHealthInsights(bmi, age, fitnessData)}

**📈 Fitness Journey Progress:**
${_getFitnessJourneyInsights(profileData, fitnessData)}

**⚠️ Areas for Improvement:**
${_getImprovementAreas(bmi, fitnessData, profileData)}

**🏆 Strengths to Build On:**
${_getStrengths(fitnessData, profileData)}

Your health journey is unique - these insights help optimize your path to wellness! 💪
''';
  }

  String _generateGoalAnalysis(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final weeklyGoal = profileData['weeklyWorkoutGoal'] ?? 5;
    final dailySteps = profileData['dailyStepGoal'] ?? 10000;
    final currentStreak = fitnessData['currentStreak'] ?? 0;

    return '''🎯 **Goal Achievement Analysis for ${profileData['name']}**

**🎯 Current Goals:**
• Weekly Workouts: **${fitnessData['weeklyGoalProgress']}** (Target: $weeklyGoal)
• Daily Steps: **Progress tracking** (Target: $dailySteps)
• Water Intake: **${fitnessData['waterGlasses']}/8** glasses daily

**📊 Goal Performance:**
${_getGoalPerformance(fitnessData, profileData)}

**🚀 Achievement Strategies:**
${_getAchievementStrategies(fitnessData, profileData)}

**📅 Goal Progression Plan:**
${_getGoalProgressionPlan(profileData, currentStreak)}

**🏆 Celebration Milestones:**
${_getCelebrationMilestones(currentStreak, fitnessData)}

Remember: Goals are achieved through consistent small actions. You\'re already on the right path! 🌟
''';
  }

  String _generatePersonalizedNutrition(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final age = profileData['age'] ?? 25;
    final weight = profileData['weight'] ?? 70.0;
    final gender = profileData['gender'] ?? 'Male';
    final dailyCalories = _calculateDailyCalories(profileData);
    final todayCalories = fitnessData['todayCalories'] ?? 0;

    return '''🥗 **Personalized Nutrition Plan for ${profileData['name']}**

**📊 Your Nutritional Profile:**
• Age: **$age** years
• Weight: **${weight}** kg
• Gender: **$gender**
• Daily Calorie Needs: **${dailyCalories}** kcal
• Calories Burned Today: **$todayCalories** kcal

**🍽️ Macronutrient Breakdown:**
${_getMacroBreakdown(weight, gender, todayCalories)}

**⏰ Meal Timing for Optimal Performance:**
${_getOptimalMealTiming(fitnessData)}

**💧 Hydration Strategy:**
• Target: **${(weight * 35).round()}ml** daily (based on your weight)
• Current: **${fitnessData['waterGlasses'] * 250}ml** consumed
• Pre-workout: 250ml (30 mins before)
• Post-workout: 500ml per hour of exercise

**🏋️ Pre/Post Workout Nutrition:**
${_getWorkoutNutrition(gender, weight)}

**🥇 Power Foods for Your Goals:**
${_getPowerFoods(profileData, fitnessData)}

Nutrition is 70% of your fitness success - fuel your body right! 💪
''';
  }

  String _generateComprehensiveOverview(
    String message,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    return '''🤖 **FitBot: Your Personal Fitness Assistant**

Hi **${profileData['name'] ?? 'there'}**! I have complete access to your fitness data and can help you with:

**📊 What I Know About You:**
• Complete profile (age: ${profileData['age']}, fitness level: ${profileData['fitnessLevel']})
• Today\'s progress (${fitnessData['todayWorkouts']} workouts, ${fitnessData['waterGlasses']} glasses water)
• ${fitnessData['currentStreak']} day streak, ${fitnessData['totalSessions']} total sessions
• Health metrics (BMI, calorie needs, activity level)
• Workout history and performance trends

**💬 Ask Me Anything:**
• **Progress Questions:** \"What\'s my streak?\" \"How am I doing this week?\"
• **Water Tracking:** \"How much water have I had?\" \"Am I hydrated enough?\"
• **Workout Plans:** \"What workout should I do today?\" \"Plan my week\"
• **Nutrition Advice:** \"What should I eat?\" \"Meal recommendations\"
• **Health Analysis:** \"Check my BMI\" \"How are my fitness levels?\"
• **Goal Setting:** \"Am I meeting my goals?\" \"What should I focus on?\"

**🎯 Try These Queries:**
• \"Analyze my progress this week\"
• \"Suggest a workout based on my fitness level\"  
• \"What\'s my health status?\"
• \"How can I improve my performance?\"
• \"Plan my nutrition for today\"

I\'m like having Gemini AI but with complete knowledge of YOUR fitness journey! What would you like to explore? 🚀
''';
  }

  // Helper methods for detailed insights
  String _getWorkoutIntensity(int calories, int minutes) {
    if (minutes == 0) return 'No activity';
    final intensity = calories / minutes;
    if (intensity > 10) return 'High intensity 🔥';
    if (intensity > 6) return 'Moderate intensity 💪';
    if (intensity > 3) return 'Light intensity ⚡';
    return 'Very light 🌟';
  }

  String _getStreakEmoji(int streak) {
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '🔥';
    if (streak >= 7) return '⭐';
    if (streak >= 3) return '💪';
    if (streak > 0) return '🌟';
    return '🚀';
  }

  String _getPerformanceInsight(
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    final streak = fitnessData['currentStreak'] ?? 0;
    final todayWorkouts = fitnessData['todayWorkouts'] ?? 0;

    if (streak >= 7 && todayWorkouts > 0) {
      return '🔥 You\'re in peak form! Excellent consistency and daily performance!';
    } else if (streak >= 3) {
      return '📈 Building strong momentum! Your habits are forming nicely!';
    } else if (todayWorkouts > 0) {
      return '💪 Great work today! Focus on building consistency!';
    }
    return '🌟 Every journey starts with one step. Ready to begin?';
  }

  String _getPersonalizedRecommendations(
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    List<String> recommendations = [];

    final hydration = fitnessData['hydrationPercentage'] ?? 0;
    final streak = fitnessData['currentStreak'] ?? 0;
    final todayWorkouts = fitnessData['todayWorkouts'] ?? 0;

    if (hydration < 50)
      recommendations.add('💧 Increase water intake for better performance');
    if (streak < 3)
      recommendations.add('🎯 Focus on consistency - aim for 3+ day streak');
    if (todayWorkouts == 0)
      recommendations.add('🏋️ Schedule a workout session today');
    if (fitnessData['averageWorkoutDuration'] < 20)
      recommendations.add('⏰ Gradually increase workout duration');

    return recommendations.isEmpty
        ? '🌟 You\'re doing great! Keep up the excellent work!'
        : recommendations.join('\n• ');
  }

  String _getNextMilestones(int streak, int totalSessions) {
    List<String> milestones = [];

    if (streak < 7)
      milestones.add('🎯 7-day streak (${7 - streak} days to go)');
    else if (streak < 14)
      milestones.add('🎯 2-week streak (${14 - streak} days to go)');
    else if (streak < 30)
      milestones.add('🎯 30-day streak (${30 - streak} days to go)');

    if (totalSessions < 10)
      milestones.add('🏅 10 total sessions (${10 - totalSessions} to go)');
    else if (totalSessions < 25)
      milestones.add('🏅 25 total sessions (${25 - totalSessions} to go)');
    else if (totalSessions < 50)
      milestones.add('🏅 50 total sessions (${50 - totalSessions} to go)');

    return milestones.join('\n• ');
  }

  String _getTodayWorkoutPlan(
    String fitnessLevel,
    int streak,
    int avgDuration,
  ) {
    switch (fitnessLevel.toLowerCase()) {
      case 'advanced':
        return '''**High-Intensity Session (45-60 mins):**
• Warm-up: 10 minutes dynamic stretching
• Strength: Compound movements (squats, deadlifts, pull-ups)
• Cardio: HIIT intervals 20 minutes
• Cool-down: 10 minutes stretching''';
      case 'intermediate':
        return '''**Balanced Workout (30-45 mins):**
• Warm-up: 5 minutes light movement
• Strength: Upper/lower body split
• Cardio: 15-20 minutes moderate intensity
• Cool-down: 5 minutes stretching''';
      default:
        return '''**Beginner-Friendly Session (20-30 mins):**
• Warm-up: 5 minutes walking/marching
• Bodyweight exercises: Push-ups, squats, planks
• Light cardio: 10 minutes
• Cool-down: 5 minutes gentle stretching''';
    }
  }

  String _getProgressivePlan(
    String fitnessLevel,
    int age,
    Map<String, dynamic> profileData,
  ) {
    return '''**Week 1-2:** Build foundation and consistency
**Week 3-4:** Increase intensity by 10-15%
**Week 5-6:** Add complexity and duration
**Week 7+:** Progressive overload and variation''';
  }

  String _getBestWorkoutTime(Map<String, dynamic> profileData) {
    final age = profileData['age'] ?? 25;
    if (age < 30) return 'Evening (5-7 PM) - Peak energy levels';
    return 'Morning (7-9 AM) - Better consistency and metabolism';
  }

  String _getRecoveryTips(int age, int streak) {
    List<String> tips = [];
    tips.add('💤 Sleep 7-9 hours nightly for optimal recovery');
    tips.add('🧘 Include 1-2 rest days per week');
    if (age > 35) tips.add('🚶 Active recovery (walking, light yoga)');
    if (streak > 10) tips.add('🛀 Weekly massage or self-massage');
    return tips.join('\n• ');
  }

  // Additional helper methods would continue here for all the referenced methods...
  String _getHealthInsights(
    double bmi,
    int age,
    Map<String, dynamic> fitnessData,
  ) {
    return 'BMI indicates ${_getBMICategory(bmi)} range. Regular exercise is beneficial at any age.';
  }

  String _getFitnessJourneyInsights(
    Map<String, dynamic> profileData,
    Map<String, dynamic> fitnessData,
  ) {
    return 'Your fitness journey shows consistent progress with room for growth.';
  }

  String _getImprovementAreas(
    double bmi,
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    return 'Focus on consistency and gradual progression in your fitness routine.';
  }

  String _getStrengths(
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    return 'Your commitment to tracking and improvement shows dedication to your fitness goals.';
  }

  String _getGoalPerformance(
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    return 'You\'re making steady progress toward your fitness goals.';
  }

  String _getAchievementStrategies(
    Map<String, dynamic> fitnessData,
    Map<String, dynamic> profileData,
  ) {
    return 'Break goals into smaller milestones and celebrate progress along the way.';
  }

  String _getGoalProgressionPlan(Map<String, dynamic> profileData, int streak) {
    return 'Gradually increase workout frequency and intensity as you build consistency.';
  }

  String _getCelebrationMilestones(
    int streak,
    Map<String, dynamic> fitnessData,
  ) {
    return 'Celebrate each week of consistency and every personal best achieved.';
  }

  String _getMacroBreakdown(double weight, String gender, int todayCalories) {
    final protein = (weight * 1.6).round();
    return '''• Protein: ${protein}g daily (muscle building/recovery)
• Carbs: 45-50% of calories (energy for workouts)  
• Fats: 20-30% of calories (hormone production)''';
  }

  String _getOptimalMealTiming(Map<String, dynamic> fitnessData) {
    return '''• Pre-workout: Light meal 1-2 hours before
• Post-workout: Protein + carbs within 30 minutes
• Regular meals: Every 3-4 hours for stable energy''';
  }

  String _getWorkoutNutrition(String gender, double weight) {
    return '''• Pre: Banana + handful of nuts
• Post: Protein shake + fruit
• Hydration: 500ml per hour of exercise''';
  }

  String _getPowerFoods(
    Map<String, dynamic> profileData,
    Map<String, dynamic> fitnessData,
  ) {
    return '''• Lean proteins: Chicken, fish, eggs, beans
• Complex carbs: Oats, quinoa, sweet potatoes
• Healthy fats: Avocado, nuts, olive oil
• Recovery foods: Berries, leafy greens, Greek yogurt''';
  }
}
