import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
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

  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  int _currentSlide = 0;

  final List<Map<String, dynamic>> _measurementSlides = [
    {
      'image':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
      'overlay': [
        Color(0xFF667eea).withOpacity(0.7),
        Color(0xFF764ba2).withOpacity(0.7),
      ],
      'title': 'Track Progress',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&q=80',
      'overlay': [
        Color(0xFF11998e).withOpacity(0.7),
        Color(0xFF38ef7d).withOpacity(0.7),
      ],
      'title': 'Body Measurements',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&q=80',
      'overlay': [
        Color(0xFFee0979).withOpacity(0.7),
        Color(0xFFff6a00).withOpacity(0.7),
      ],
      'title': 'Fitness Goals',
    },
    {
      'image':
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&q=80',
      'overlay': [
        Color(0xFF4facfe).withOpacity(0.7),
        Color(0xFF00f2fe).withOpacity(0.7),
      ],
      'title': 'Body Transformation',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMeasurements();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    measurements.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentSlide < _measurementSlides.length - 1) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
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
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Slider Header
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  // PageView with background images
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSlide = index;
                      });
                    },
                    itemCount: _measurementSlides.length,
                    itemBuilder: (context, index) {
                      final slide = _measurementSlides[index];
                      final overlayColors = (slide['overlay'] as List)
                          .cast<Color>();
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(slide['image'] as String),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: overlayColors,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Static content overlay
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.straighten, size: 70, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'Body Measurements',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black45),
                              Shadow(blurRadius: 20, color: Colors.black26),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Track your body progress',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Slide indicators
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _measurementSlides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentSlide == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentSlide == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
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
                          helperText: key == 'Weight'
                              ? 'From your profile'
                              : null,
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
                            final value = double.tryParse(
                              controller.text.trim(),
                            );
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
                              content: Text(
                                'Please enter at least one measurement',
                              ),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
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
