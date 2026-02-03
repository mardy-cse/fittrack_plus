import 'package:get/get.dart';
import '../controllers/email_link_auth_controller.dart';

class EmailLinkAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailLinkAuthController>(() => EmailLinkAuthController());
  }
}
