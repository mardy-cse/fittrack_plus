import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/progress_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize ProgressController first since HomeController depends on it
    Get.lazyPut<ProgressController>(() => ProgressController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}
