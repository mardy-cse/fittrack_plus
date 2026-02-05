import 'package:flutter/material.dart';
import '../../widgets/water_body_tracker.dart';

/// Demo screen to showcase the WaterBodyTracker widget
class WaterBodyTrackerDemo extends StatefulWidget {
  const WaterBodyTrackerDemo({super.key});

  @override
  State<WaterBodyTrackerDemo> createState() => _WaterBodyTrackerDemoState();
}

class _WaterBodyTrackerDemoState extends State<WaterBodyTrackerDemo> {
  double _waterLevel = 0.5; // 50% filled

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Water Body Tracker'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                'Daily Water Intake',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Water percentage display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '${(_waterLevel * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                '${(_waterLevel * 2000).toInt()} / 2000 ml',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // Water Body Tracker Widget
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(30),
                  child: WaterBodyTracker(
                    waterLevel: _waterLevel,
                    width: 220,
                    height: 440,
                    bodyColor: isDarkMode
                        ? Colors.grey[400]!
                        : Colors.grey[700]!,
                    waterColorStart: const Color(0xFF1976D2),
                    waterColorEnd: const Color(0xFF42A5F5),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Slider to control water level
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust Water Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.blue.shade400,
                        inactiveTrackColor: Colors.blue.shade100,
                        thumbColor: Colors.blue.shade600,
                        overlayColor: Colors.blue.withOpacity(0.2),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _waterLevel,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: '${(_waterLevel * 100).toInt()}%',
                        onChanged: (value) {
                          setState(() {
                            _waterLevel = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Quick action buttons
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickButton(
                    context,
                    'Empty',
                    Icons.water_drop_outlined,
                    0.0,
                    Colors.grey,
                  ),
                  _buildQuickButton(
                    context,
                    '25%',
                    Icons.water_drop,
                    0.25,
                    Colors.lightBlue,
                  ),
                  _buildQuickButton(
                    context,
                    '50%',
                    Icons.water_drop,
                    0.5,
                    Colors.blue,
                  ),
                  _buildQuickButton(
                    context,
                    '75%',
                    Icons.water_drop,
                    0.75,
                    Colors.indigo,
                  ),
                  _buildQuickButton(
                    context,
                    'Full',
                    Icons.water_drop,
                    1.0,
                    Colors.deepPurple,
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    IconData icon,
    double level,
    Color color,
  ) {
    final isSelected = (_waterLevel - level).abs() < 0.01;

    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _waterLevel = level;
        });
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.3),
        foregroundColor: isSelected ? Colors.white : color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: isSelected ? 8 : 2,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }
}
