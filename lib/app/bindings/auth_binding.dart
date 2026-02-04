import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use put with permanent: true to keep controller alive across login/signup navigation
    // Only create if it doesn't exist yet
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}
