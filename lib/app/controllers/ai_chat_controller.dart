import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class AiChatController extends GetxController {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _addWelcomeMessage() {
    messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Hello! I'm FitBot, your AI fitness coach. How can I help you achieve your fitness goals today? 💪",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);
    messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Add loading indicator
    isLoading.value = true;
    final loadingMessage = ChatMessage(
      id: 'loading',
      text: 'Typing...',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    messages.add(loadingMessage);
    _scrollToBottom();

    try {
      // Get AI response
      final response = await _geminiService.sendMessage(text);

      // Remove loading message
      messages.removeWhere((msg) => msg.id == 'loading');

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.add(aiMessage);
    } catch (e) {
      // Remove loading message
      messages.removeWhere((msg) => msg.id == 'loading');

      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.add(errorMessage);
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    messages.clear();
    _geminiService.resetChat();
    _addWelcomeMessage();
  }

  Future<void> getWorkoutSuggestion() async {
    messageController.text = 'Suggest a beginner-friendly full body workout for 30 minutes';
    await sendMessage();
  }

  Future<void> getFormAdvice(String exercise) async {
    messageController.text = 'What is the proper form for $exercise?';
    await sendMessage();
  }

  Future<void> getNutritionAdvice() async {
    messageController.text = 'Give me nutrition advice for building muscle';
    await sendMessage();
  }
}
