import 'package:get/get.dart';
import '../controllers/start_workout_controller.dart';

class StartWorkoutBinding extends Bindings {
  @override
  void dependencies() {
    // StartWorkoutController (WorkoutLogService already initialized in main.dart)
    Get.lazyPut<StartWorkoutController>(
      () => StartWorkoutController(),
      fenix: true,
    );
  }
}
