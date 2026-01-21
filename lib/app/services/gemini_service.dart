import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyDIjJRxGZ4v8cpG9Qc98JMOGA42XXNj6X8'; // TODO: Replace with your actual API key
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
      systemInstruction: Content.text(
        '''You are an expert AI fitness coach named "FitBot". You provide:
- Personalized workout advice
- Exercise form tips and corrections
- Nutrition guidance
- Motivation and encouragement
- Injury prevention tips
- Progress tracking insights

Keep responses concise, friendly, and actionable. Always prioritize user safety and recommend consulting healthcare professionals for medical concerns.''',
      ),
    );
    _initializeChat();
  }

  void _initializeChat() {
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw Exception('Empty response from AI');
      }

      return text;
    } catch (e) {
      debugPrint('Error sending message to Gemini: $e');
      if (e.toString().contains('API_KEY')) {
        return 'Error: Please configure your Gemini API key in the GeminiService.';
      }
      return 'Sorry, I encountered an error. Please try again.';
    }
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
}
