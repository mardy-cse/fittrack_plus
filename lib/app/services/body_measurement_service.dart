import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/body_measurement.dart';

class BodyMeasurementService extends GetxService {
  final GetStorage _storage = GetStorage();
  static const String _key = 'body_measurements_history';
  static const int _maxEntries = 50;

  // Initialize service
  Future<BodyMeasurementService> init() async {
    await GetStorage.init();
    return this;
  }

  // Save body measurement
  Future<void> saveMeasurement(BodyMeasurement measurement) async {
    try {
      final history = await loadHistory();

      // Add new record at the beginning
      history.insert(0, measurement);

      // Keep only last 50 entries
      if (history.length > _maxEntries) {
        history.removeRange(_maxEntries, history.length);
      }

      // Convert to JSON and save
      final jsonList = history.map((r) => r.toJson()).toList();
      await _storage.write(_key, jsonList);

      debugPrint('✅ Body measurement saved successfully');
    } catch (e) {
      debugPrint('Error saving body measurement: $e');
      rethrow;
    }
  }

  // Load measurement history
  Future<List<BodyMeasurement>> loadHistory() async {
    try {
      final jsonList = _storage.read<List>(_key);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList
          .map((json) => BodyMeasurement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading body measurement history: $e');
      return [];
    }
  }

  // Get latest measurement
  Future<BodyMeasurement?> getLatestMeasurement() async {
    try {
      final history = await loadHistory();
      return history.isNotEmpty ? history.first : null;
    } catch (e) {
      debugPrint('Error getting latest measurement: $e');
      return null;
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      await _storage.remove(_key);
    } catch (e) {
      debugPrint('Error clearing history: $e');
      rethrow;
    }
  }
}
