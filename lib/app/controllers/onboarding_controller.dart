import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final storage = GetStorage();

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void skipOnboarding() {
    storage.write('onboarding_completed', true);
    Get.offAllNamed('/login');
  }

  void completeOnboarding() {
    storage.write('onboarding_completed', true);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
