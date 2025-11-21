import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bmi_record.dart';
import '../services/bmi_storage_service.dart';

class BMIController extends GetxController {
  final BMIStorageService _storageService = Get.find<BMIStorageService>();

  // Form controllers
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  // Observable variables
  final RxString selectedGender = 'male'.obs;
  final Rx<BMIRecord?> currentRecord = Rx<BMIRecord?>(null);
  final RxList<BMIRecord> history = <BMIRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxString trend = ''.obs;

  // Chart data
  final RxList<double> weightHistory = <double>[].obs;
  final RxList<double> bmiHistory = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  @override
  void onClose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.onClose();
  }

  // Calculate BMI
  Future<void> calculateBMI() async {
    // Validate inputs
    if (heightController.text.isEmpty ||
        weightController.text.isEmpty ||
        ageController.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final height = double.parse(heightController.text);
      final weight = double.parse(weightController.text);
      final age = int.parse(ageController.text);

      // Validate ranges
      if (height < 50 || height > 300) {
        Get.snackbar(
          'Invalid Height',
          'Height must be between 50-300 cm',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (weight < 10 || weight > 500) {
        Get.snackbar(
          'Invalid Weight',
          'Weight must be between 10-500 kg',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (age < 1 || age > 150) {
        Get.snackbar(
          'Invalid Age',
          'Age must be between 1-150 years',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Calculate BMI
      final bmi = BMIRecord.calculateBMI(height, weight);
      final category = BMIRecord.getBMICategory(bmi);

      // Create record
      final record = BMIRecord(
        height: height,
        weight: weight,
        age: age,
        gender: selectedGender.value,
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

      // Show success
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
        'Invalid input. Please enter valid numbers.',
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
      print('Error loading BMI history: $e');
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
      heightController.text = height.toInt().toString();
    }
    if (weight != null) {
      weightController.text = weight.toInt().toString();
    }
    if (age != null) {
      ageController.text = age.toString();
    }
    if (gender != null) {
      selectedGender.value = gender.toLowerCase();
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
