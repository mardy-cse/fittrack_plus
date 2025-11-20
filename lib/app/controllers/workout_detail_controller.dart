import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../views/workout/workout_detail_view.dart';

class WorkoutDetailController extends GetxController {
  final WorkoutService _workoutService = Get.find<WorkoutService>();

  // Observable variables
  final Rx<Workout?> workout = Rx<Workout?>(null);
  final RxList<Workout> relatedWorkouts = <Workout>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isVideoLoading = true.obs;

  // Video player
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void onInit() {
    super.onInit();
    // Get workout from arguments
    final args = Get.arguments;
    if (args is Workout) {
      workout.value = args;
      loadRelatedWorkouts();
      if (workout.value?.videoUrl.isNotEmpty ?? false) {
        initializeVideoPlayer();
      }
    }
  }

  @override
  void onClose() {
    disposeVideoPlayer();
    super.onClose();
  }

  // Initialize video player
  Future<void> initializeVideoPlayer() async {
    if (workout.value?.videoUrl.isEmpty ?? true) return;

    try {
      isVideoLoading.value = true;

      // For demo purposes, using a sample video URL
      // Replace with actual workout.value!.videoUrl in production
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
      );

      await videoPlayerController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Video unavailable',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      isVideoLoading.value = false;
    } catch (e) {
      print('Error initializing video: $e');
      isVideoLoading.value = false;
    }
  }

  // Dispose video player
  void disposeVideoPlayer() {
    chewieController?.dispose();
    videoPlayerController?.dispose();
  }

  // Load related workouts
  Future<void> loadRelatedWorkouts() async {
    if (workout.value == null) return;

    try {
      isLoading.value = true;

      // Get workouts with same level or category
      final allWorkouts = await _workoutService.getAllWorkouts();

      relatedWorkouts.value = allWorkouts
          .where((w) =>
              w.id != workout.value!.id &&
              (w.level == workout.value!.level ||
                  w.category == workout.value!.category))
          .take(5)
          .toList();
    } catch (e) {
      print('Error loading related workouts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start workout
  void startWorkout() {
    Get.snackbar(
      'Starting Workout',
      'Starting ${workout.value?.title}...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to workout session screen
  }

  // Navigate to related workout
  void openRelatedWorkout(Workout relatedWorkout) {
    // Dispose current video
    disposeVideoPlayer();

    // Navigate to new workout detail
    Get.off(
      () => const WorkoutDetailView(),
      arguments: relatedWorkout,
    );
  }
}
