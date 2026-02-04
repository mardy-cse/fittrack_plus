import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF1A1F3A),
              const Color(0xFF2D1B4E),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Progress indicator
              _buildProgressIndicator(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Obx(() {
                    switch (controller.currentStep.value) {
                      case 0:
                        return _buildAgeStep();
                      case 1:
                        return _buildGenderStep();
                      case 2:
                        return _buildHeightStep();
                      case 3:
                        return _buildWeightStep();
                      default:
                        return _buildAgeStep();
                    }
                  }),
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: controller.skipForNow,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Obx(() {
      final progress = (controller.currentStep.value + 1) / 4;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${controller.currentStep.value + 1} of 4',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF667EEA),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Age Step
  Widget _buildAgeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),

        // Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.3),
                  const Color(0xFF764BA2).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.cake_outlined,
              size: 60,
              color: Color(0xFF667EEA),
            ),
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          'How old are you?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'This helps us personalize your fitness plan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.6),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 60),

        // Age Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller.ageController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              hintText: '25',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 24),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  'years',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 20,
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  // Gender Step
  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),

        // Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.3),
                  const Color(0xFF764BA2).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              size: 60,
              color: Color(0xFF667EEA),
            ),
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          'What\'s your gender?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'We use this to calculate your daily calorie needs',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.6),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 60),

        // Gender options
        Obx(
          () => Column(
            children: controller.genderOptions.map((gender) {
              final isSelected = controller.selectedGender.value == gender;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => controller.selectGender(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.2),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getGenderIcon(gender),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          gender,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'Male':
        return Icons.male;
      case 'Female':
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  // Height Step
  Widget _buildHeightStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),

        // Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.3),
                  const Color(0xFF764BA2).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.height, size: 60, color: Color(0xFF667EEA)),
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          'What\'s your height?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'This helps us track your BMI and progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.6),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 60),

        // Height Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller.heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            decoration: InputDecoration(
              hintText: '170',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 24),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  'cm',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 20,
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  // Weight Step
  Widget _buildWeightStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),

        // Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.3),
                  const Color(0xFF764BA2).withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              size: 60,
              color: Color(0xFF667EEA),
            ),
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          'What\'s your weight?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'We\'ll track your progress towards your goals',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.6),
            height: 1.6,
          ),
        ),

        const SizedBox(height: 60),

        // Weight Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: controller.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            decoration: InputDecoration(
              hintText: '70',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 24),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 20,
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E27).withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Obx(() {
        final isFirstStep = controller.currentStep.value == 0;
        final isLastStep = controller.currentStep.value == 3;

        return Row(
          children: [
            // Back button
            if (!isFirstStep)
              Expanded(
                child: _buildOutlineButton(
                  text: 'Back',
                  onPressed: controller.previousStep,
                  icon: Icons.arrow_back,
                ),
              ),

            if (!isFirstStep) const SizedBox(width: 16),

            // Next/Complete button
            Expanded(
              flex: isFirstStep ? 1 : 1,
              child: Obx(
                () => _buildPremiumButton(
                  text: isLastStep ? 'Complete' : 'Next',
                  onPressed: controller.nextStep,
                  isLoading: controller.isLoading.value,
                  icon: isLastStep ? Icons.check : Icons.arrow_forward,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPremiumButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
    IconData? icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
