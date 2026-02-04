import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/email_otp_controller.dart';

class EmailOTPView extends GetView<EmailOTPController> {
  const EmailOTPView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon with glassmorphism effect
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
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
                      Icons.mark_email_read_rounded,
                      size: 50,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Obx(
                  () => Text(
                    'We sent a 6-digit OTP to\n${controller.email.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => _buildOTPField(context, index),
                  ),
                ),

                const SizedBox(height: 50),

                // Verify Button
                Obx(
                  () => _buildPremiumButton(
                    text: 'Verify & Create Account',
                    onPressed: controller.verifyOTP,
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 32),

                // Resend OTP
                Obx(() {
                  if (controller.canResend.value) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive OTP?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: controller.isResending.value
                              ? null
                              : controller.resendOTP,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            controller.isResending.value
                                ? 'Resending...'
                                : 'Resend',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667EEA),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        'Resend OTP in ${controller.remainingTime.value}s',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    );
                  }
                }),

                const SizedBox(height: 24),

                // Clear Button
                TextButton(
                  onPressed: controller.clearOTP,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build individual OTP field with glassmorphism
  Widget _buildOTPField(BuildContext context, int index) {
    return AnimatedBuilder(
      animation: controller.otpFocusNodes[index],
      builder: (context, child) {
        final isFocused = controller.otpFocusNodes[index].hasFocus;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF667EEA).withOpacity(0.8)
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? const Color(0xFF667EEA).withOpacity(0.3)
                    : Colors.transparent,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextField(
            controller: controller.otpControllers[index],
            focusNode: controller.otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            autofocus: index == 0,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              filled: false,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            onChanged: (value) {
              controller.onOTPChanged(index, value);
            },
          ),
        );
      },
    );
  }

  // Premium gradient button
  Widget _buildPremiumButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
