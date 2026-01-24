import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bmi_record.dart';
import '../services/bmi_storage_service.dart';

class BMIController extends GetxController {
  final BMIStorageService _storageService = Get.find<BMIStorageService>();

  // Form controllers
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Observable variables
  final Rx<BMIRecord?> currentRecord = Rx<BMIRecord?>(null);
  final RxList<BMIRecord> history = <BMIRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxString trend = ''.obs;

  // Slider values
  final RxDouble heightSlider = 170.0.obs;
  final RxDouble weightSlider = 70.0.obs;

  // Chart data
  final RxList<double> weightHistory = <double>[].obs;
  final RxList<double> bmiHistory = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    
    // Sync sliders with text fields
    heightSlider.listen((value) {
      heightController.text = value.toInt().toString();
    });
    weightSlider.listen((value) {
      weightController.text = value.toInt().toString();
    });
  }

  @override
  void onClose() {
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }

  // Calculate BMI
  Future<void> calculateBMI() async {
    try {
      final height = heightSlider.value;
      final weight = weightSlider.value;

      // Calculate BMI
      final bmi = BMIRecord.calculateBMI(height, weight);
      final category = BMIRecord.getBMICategory(bmi);

      // Create record
      final record = BMIRecord(
        height: height,
        weight: weight,
        bmi: bmi,
        category: category,
        date: DateTime.now(),
      );

      // Save record
      await _storageService.saveBMIRecord(record);

      // Update current record
      currentRecord.value = record;

      // Reload history
      await loadHistory();

      // Show success with personalized message
      Get.snackbar(
        'BMI Calculated! 🎯',
        'Your BMI is ${bmi.toStringAsFixed(1)} ($category)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to calculate BMI',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load history
  Future<void> loadHistory() async {
    try {
      isLoading.value = true;

      final records = await _storageService.loadBMIHistory();
      history.value = records;

      // Load latest record
      if (records.isNotEmpty) {
        currentRecord.value = records.first;
      }

      // Load chart data
      weightHistory.value = await _storageService.getWeightHistory();
      bmiHistory.value = await _storageService.getBMIHistory();

      // Get trend
      trend.value = await _storageService.getBMITrend();
    } catch (e) {
      debugPrint('Error loading BMI history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    try {
      await _storageService.clearHistory();
      history.clear();
      currentRecord.value = null;
      weightHistory.clear();
      bmiHistory.clear();
      trend.value = '';

      Get.snackbar(
        'History Cleared',
        'All BMI records have been deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear history',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Pre-fill from profile data
  void prefillFromProfile({
    double? height,
    double? weight,
    int? age,
    String? gender,
  }) {
    if (height != null) {
      heightSlider.value = height;
      heightController.text = height.toInt().toString();
    }
    if (weight != null) {
      weightSlider.value = weight;
      weightController.text = weight.toInt().toString();
    }
  }

  // Get BMI color
  Color getBMIColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get trend icon
  IconData getTrendIcon() {
    switch (trend.value) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.help_outline;
    }
  }

  // Get trend color
  Color getTrendColor() {
    switch (trend.value) {
      case 'increasing':
        return Colors.red;
      case 'decreasing':
        return Colors.green;
      case 'stable':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
