import 'package:get/get.dart';
import '../controllers/profile_setup_controller.dart';

class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSetupController>(() => ProfileSetupController());
  }
}
