import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize controller (services already initialized in main.dart)
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
