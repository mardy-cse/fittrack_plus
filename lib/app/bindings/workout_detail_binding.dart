import 'package:get/get.dart';
import '../controllers/workout_detail_controller.dart';

class WorkoutDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutDetailController>(
      () => WorkoutDetailController(),
      fenix: true,
    );
  }
}
