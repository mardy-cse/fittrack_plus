import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../services/body_measurement_service.dart';
import '../../models/body_measurement.dart';
import 'body_measurement_trends_screen.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  final _service = Get.put(BodyMeasurementService());
  late Map<String, TextEditingController> measurements;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMeasurements();
  }

  Future<void> _initializeMeasurements() async {
    final controller = Get.find<HomeController>();
    final user = controller.userProfile.value;

    // Load latest measurements
    final latest = await _service.getLatestMeasurement();

    measurements = {
      'Weight': TextEditingController(
        text:
            latest?.weight?.toStringAsFixed(0) ??
            user?.weight?.toInt().toString() ??
            '',
      ),
      'Chest': TextEditingController(
        text: latest?.chest?.toStringAsFixed(0) ?? '',
      ),
      'Waist': TextEditingController(
        text: latest?.waist?.toStringAsFixed(0) ?? '',
      ),
      'Hips': TextEditingController(
        text: latest?.hips?.toStringAsFixed(0) ?? '',
      ),
      'Biceps': TextEditingController(
        text: latest?.biceps?.toStringAsFixed(0) ?? '',
      ),
      'Thighs': TextEditingController(
        text: latest?.thighs?.toStringAsFixed(0) ?? '',
      ),
      'Calves': TextEditingController(
        text: latest?.calves?.toStringAsFixed(0) ?? '',
      ),
    };

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    measurements.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = {
      'Weight': Icons.monitor_weight,
      'Chest': Icons.fitness_center,
      'Waist': Icons.straighten,
      'Hips': Icons.accessibility_new,
      'Biceps': Icons.sports_gymnastics,
      'Thighs': Icons.directions_walk,
      'Calves': Icons.sports_martial_arts,
    };

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Body Measurements'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : const Color(0xFF50C878),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'View Trends',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BodyMeasurementTrendsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.straighten, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            // Quick Stats Card
            FutureBuilder<List<BodyMeasurement>>(
              future: _service.loadHistory(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.length >= 2) {
                  return _buildQuickStatsCard(snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Track your body progress',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ...measurements.keys.map((key) {
              final unit = key == 'Weight' ? 'kg' : 'cm';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: measurements[key],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '$key ($unit)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(icons[key], color: Colors.white),
                    helperText: key == 'Weight' ? 'From your profile' : null,
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  debugPrint('Save Measurements button pressed');

                  bool hasData = false;
                  final data = <String, double>{};

                  measurements.forEach((key, controller) {
                    if (controller.text.trim().isNotEmpty) {
                      hasData = true;
                      final value = double.tryParse(controller.text.trim());
                      if (value != null) {
                        data[key] = value;
                        debugPrint('$key: $value');
                      }
                    }
                  });

                  if (hasData) {
                    debugPrint('Saving measurements: $data');

                    // Create measurement object
                    final measurement = BodyMeasurement(
                      date: DateTime.now(),
                      weight: data['Weight'],
                      chest: data['Chest'],
                      waist: data['Waist'],
                      hips: data['Hips'],
                      biceps: data['Biceps'],
                      thighs: data['Thighs'],
                      calves: data['Calves'],
                    );

                    // Save to storage
                    try {
                      await _service.saveMeasurement(measurement);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Saved! ✓ Measurements saved successfully',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Error saving: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter at least one measurement'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Measurements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Measure at the same time each week for accurate tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(List<BodyMeasurement> history) {
    final latest = history[0];
    final previous = history[1];

    final weightChange = (latest.weight ?? 0) - (previous.weight ?? 0);
    final waistChange = (latest.waist ?? 0) - (previous.waist ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50C878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Since Last Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BodyMeasurementTrendsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.insights, color: Colors.white, size: 18),
                label: const Text(
                  'View All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Weight',
                  weightChange,
                  'kg',
                  weightChange < 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  'Waist',
                  waistChange,
                  'cm',
                  waistChange < 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String label,
    double change,
    String unit,
    bool isImprovement,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isImprovement ? Icons.trending_down : Icons.trending_up,
                color: isImprovement ? Colors.greenAccent : Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  color: isImprovement
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
