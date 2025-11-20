import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/phone_auth_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PhoneAuthView extends GetView<PhoneAuthController> {
  const PhoneAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Phone Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            return controller.codeSent.value
                ? _buildOTPVerificationForm(context)
                : _buildPhoneInputForm(context);
          }),
        ),
      ),
    );
  }

  Widget _buildPhoneInputForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_android,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Text(
            'Enter Your Phone Number',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'We will send you a verification code',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Name Field (Optional)
          CustomTextField(
            label: 'Name (Optional)',
            hint: 'Enter your name',
            controller: controller.nameController,
            textCapitalization: TextCapitalization.words,
            prefixIcon: const Icon(Icons.person_outline),
          ),

          const SizedBox(height: 20),

          // Phone Number Field
          CustomTextField(
            label: 'Phone Number',
            hint: '01XXXXXXXXX',
            controller: controller.phoneController,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
          ),

          const SizedBox(height: 12),

          // Info Text
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enter 11 digit mobile number (e.g., 01712345678)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Send OTP Button
          Obx(
            () => CustomButton(
              text: 'Send OTP',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.sendOTP();
                }
              },
              isLoading: controller.isLoading.value,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOTPVerificationForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sms,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Text(
            'Enter Verification Code',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'We sent a code to ${controller.phoneController.text}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // OTP Input Field
          CustomTextField(
            label: 'Verification Code',
            hint: 'Enter 6-digit code',
            controller: controller.otpController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the code';
              }
              if (value.length != 6) {
                return 'Code must be 6 digits';
              }
              return null;
            },
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.lock_outline),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),

          const SizedBox(height: 20),

          // Resend OTP
          Center(
            child: Obx(() {
              if (controller.resendTimer.value > 0) {
                return Text(
                  'Resend code in ${controller.resendTimer.value}s',
                  style: TextStyle(color: Colors.grey[600]),
                );
              } else {
                return TextButton(
                  onPressed: controller.resendOTP,
                  child: const Text('Resend Code'),
                );
              }
            }),
          ),

          const SizedBox(height: 20),

          // Verify Button
          Obx(
            () => CustomButton(
              text: 'Verify & Continue',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.verifyOTP();
                }
              },
              isLoading: controller.isLoading.value,
            ),
          ),

          const SizedBox(height: 20),

          // Change Number
          TextButton(
            onPressed: () {
              controller.codeSent.value = false;
              controller.otpController.clear();
            },
            child: const Text('Change Phone Number'),
          ),
        ],
      ),
    );
  }
}
