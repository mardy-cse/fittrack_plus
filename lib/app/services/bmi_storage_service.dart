import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/bmi_record.dart';

class BMIStorageService extends GetxService {
  final GetStorage _storage = GetStorage();
  static const String _key = 'bmi_history';
  static const int _maxEntries = 10;

  // Initialize service
  Future<BMIStorageService> init() async {
    await GetStorage.init();
    return this;
  }

  // Save BMI record
  Future<void> saveBMIRecord(BMIRecord record) async {
    try {
      final history = await loadBMIHistory();

      // Add new record at the beginning
      history.insert(0, record);

      // Keep only last 10 entries
      if (history.length > _maxEntries) {
        history.removeRange(_maxEntries, history.length);
      }

      // Convert to JSON and save
      final jsonList = history.map((r) => r.toJson()).toList();
      await _storage.write(_key, jsonList);
    } catch (e) {
      print('Error saving BMI record: $e');
      rethrow;
    }
  }

  // Load BMI history
  Future<List<BMIRecord>> loadBMIHistory() async {
    try {
      final jsonList = _storage.read<List>(_key);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList
          .map((json) => BMIRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading BMI history: $e');
      return [];
    }
  }

  // Get latest BMI record
  Future<BMIRecord?> getLatestRecord() async {
    try {
      final history = await loadBMIHistory();
      return history.isNotEmpty ? history.first : null;
    } catch (e) {
      print('Error getting latest record: $e');
      return null;
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      await _storage.remove(_key);
    } catch (e) {
      print('Error clearing history: $e');
      rethrow;
    }
  }

  // Get BMI trend (increasing, decreasing, stable)
  Future<String> getBMITrend() async {
    try {
      final history = await loadBMIHistory();

      if (history.length < 2) {
        return 'insufficient_data';
      }

      final latest = history[0].bmi;
      final previous = history[1].bmi;

      if (latest > previous + 0.5) {
        return 'increasing';
      } else if (latest < previous - 0.5) {
        return 'decreasing';
      } else {
        return 'stable';
      }
    } catch (e) {
      return 'unknown';
    }
  }

  // Get weight history for chart
  Future<List<double>> getWeightHistory() async {
    try {
      final history = await loadBMIHistory();
      return history.map((r) => r.weight).toList().reversed.toList();
    } catch (e) {
      return [];
    }
  }

  // Get BMI history for chart
  Future<List<double>> getBMIHistory() async {
    try {
      final history = await loadBMIHistory();
      return history.map((r) => r.bmi).toList().reversed.toList();
    } catch (e) {
      return [];
    }
  }
}
