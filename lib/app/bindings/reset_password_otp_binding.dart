import 'package:get/get.dart';
import '../controllers/reset_password_otp_controller.dart';

class ResetPasswordOTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordOTPController>(
      () => ResetPasswordOTPController(),
    );
  }
}
