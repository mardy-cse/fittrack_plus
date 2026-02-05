import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/home_controller.dart';
import 'calorie_goal_tracking_screen.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  int _currentSlide = 0;

  // Move these variables to state level
  TextEditingController? ageController;
  TextEditingController? weightController;
  TextEditingController? heightController;
  final gender = 'male'.obs;
  final activityLevel = 'moderate'.obs;
  final calorieResult = ''.obs;
  final calculatedCalories = 0.obs;

  final List<Map<String, dynamic>> _calorieSlides = [
    {
      'image': 'assets/images/calorie/healthy_nutrition.jpg',
      'overlay': [
        Color(0xFFFF6B6B).withOpacity(0.7),
        Color(0xFFFFE66D).withOpacity(0.7),
      ],
      'title': 'Healthy Nutrition',
    },
    {
      'image': 'assets/images/calorie/fresh_nutritious.jpg',
      'overlay': [
        Color(0xFF06beb6).withOpacity(0.7),
        Color(0xFF48b1bf).withOpacity(0.7),
      ],
      'title': 'Fresh & Nutritious',
    },
    {
      'image': 'assets/images/calorie/balanced_diet.jpg',
      'overlay': [
        Color(0xFFa8edea).withOpacity(0.7),
        Color(0xFFfed6e3).withOpacity(0.7),
      ],
      'title': 'Balanced Diet',
    },
    {
      'image': 'assets/images/calorie/meal_planning.jpg',
      'overlay': [
        Color(0xFFffecd2).withOpacity(0.7),
        Color(0xFFfcb69f).withOpacity(0.7),
      ],
      'title': 'Meal Planning',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers in initState
    final controller = Get.find<HomeController>();
    final user = controller.userProfile.value;

    ageController = TextEditingController(text: user?.age?.toString() ?? '');
    weightController = TextEditingController(
      text: user?.weight?.toInt().toString() ?? '',
    );
    heightController = TextEditingController(
      text: user?.height?.toInt().toString() ?? '',
    );
    gender.value = user?.gender?.toLowerCase() ?? 'male';

    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    ageController?.dispose();
    weightController?.dispose();
    heightController?.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentSlide < _calorieSlides.length - 1) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : const Color(0xFFFFA726),
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => calculatedCalories.value > 0
                ? IconButton(
                    icon: const Icon(Icons.track_changes),
                    tooltip: 'Set Goal',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalorieGoalTrackingScreen(
                            dailyCalories: calculatedCalories.value,
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
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
                    itemCount: _calorieSlides.length,
                    itemBuilder: (context, index) {
                      final slide = _calorieSlides[index];
                      final overlayColors = (slide['overlay'] as List)
                          .cast<Color>();
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(slide['image'] as String),
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
                        Icon(Icons.restaurant, size: 70, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'Calorie Calculator',
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
                          'Calculate your daily calorie needs',
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
                        _calorieSlides.length,
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
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: gender.value,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Female'),
                        ),
                      ],
                      onChanged: (value) => gender.value = value!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: activityLevel.value,
                      decoration: const InputDecoration(
                        labelText: 'Activity Level',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_run),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'sedentary',
                          child: Text('Sedentary (little/no exercise)'),
                        ),
                        DropdownMenuItem(
                          value: 'light',
                          child: Text('Light (1-3 days/week)'),
                        ),
                        DropdownMenuItem(
                          value: 'moderate',
                          child: Text('Moderate (3-5 days/week)'),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active (6-7 days/week)'),
                        ),
                        DropdownMenuItem(
                          value: 'very_active',
                          child: Text('Very Active (twice per day)'),
                        ),
                      ],
                      onChanged: (value) => activityLevel.value = value!,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final age = double.tryParse(ageController?.text ?? '');
                        final weight = double.tryParse(
                          weightController?.text ?? '',
                        );
                        final height = double.tryParse(
                          heightController?.text ?? '',
                        );

                        if (age != null && weight != null && height != null) {
                          // Mifflin-St Jeor Equation
                          double bmr;
                          if (gender.value == 'male') {
                            bmr =
                                (10 * weight) + (6.25 * height) - (5 * age) + 5;
                          } else {
                            bmr =
                                (10 * weight) +
                                (6.25 * height) -
                                (5 * age) -
                                161;
                          }

                          // Activity multiplier
                          double multiplier;
                          switch (activityLevel.value) {
                            case 'sedentary':
                              multiplier = 1.2;
                              break;
                            case 'light':
                              multiplier = 1.375;
                              break;
                            case 'moderate':
                              multiplier = 1.55;
                              break;
                            case 'active':
                              multiplier = 1.725;
                              break;
                            case 'very_active':
                              multiplier = 1.9;
                              break;
                            default:
                              multiplier = 1.55;
                          }

                          final tdee = bmr * multiplier;
                          calculatedCalories.value = tdee.toInt();
                          calorieResult.value = '${tdee.toInt()} kcal/day';
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please fill all fields correctly',
                            snackPosition: SnackPosition.BOTTOM,
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
                        'Calculate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => calorieResult.value.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Daily Calorie Needs',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  calorieResult.value,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                const Text(
                                  'To lose weight: -500 kcal/day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'To gain weight: +500 kcal/day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CalorieGoalTrackingScreen(
                                                dailyCalories:
                                                    calculatedCalories.value,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A90E2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(Icons.track_changes),
                                    label: const Text(
                                      'Set Weight Goal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
