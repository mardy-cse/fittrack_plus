import 'package:get/get.dart';
import '../controllers/email_otp_controller.dart';

class EmailOTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailOTPController>(() => EmailOTPController(), fenix: true);
  }
}
