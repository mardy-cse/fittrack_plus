import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
// import '../../controllers/steps_controller.dart'; // Disabled for emulator
// import '../../widgets/steps_card.dart'; // Disabled for emulator

class HomeTabView extends GetView<HomeController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                controller.getUserName(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: CustomScrollView(
          slivers: [

              // Daily Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Steps',
                                    controller.todaySteps.value.toString(),
                                    Icons.directions_walk,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Calories',
                                    '${controller.todayCalories.value}',
                                    Icons.local_fire_department,
                                    Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    'Workouts',
                                    controller.todayWorkouts.value.toString(),
                                    Icons.fitness_center,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            if (controller.currentStreak.value > 0) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF1C1C1E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B6B).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Color(0xFFFF6B6B),
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${controller.currentStreak.value} Day Streak',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Great work! Keep it up',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Steps Counter Card (Disabled for emulator - works on real device)
              // const SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 16),
              //     child: StepsCard(),
              //   ),
              // ),

              // Level Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Workout Levels',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildLevelChip('All'),
                              const SizedBox(width: 8),
                              _buildLevelChip('Beginner'),
                              const SizedBox(width: 8),
                              _buildLevelChip('Intermediate'),
                              const SizedBox(width: 8),
                              _buildLevelChip('Advanced'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recommended Workouts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Workout Grid
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.filteredWorkouts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No workouts available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final workout = controller.filteredWorkouts[index];
                      return _buildWorkoutCard(context, workout);
                    }, childCount: controller.filteredWorkouts.length),
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      // Floating Action Button (Disabled for emulator - for steps testing)
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     final stepsController = Get.find<StepsController>();
      //     stepsController.addManualSteps(100);
      //     Get.snackbar(
      //       '✅ Steps Added',
      //       '+100 steps added for testing',
      //       snackPosition: SnackPosition.BOTTOM,
      //       duration: const Duration(seconds: 2),
      //       backgroundColor: Colors.green,
      //       colorText: Colors.white,
      //     );
      //   },
      //   icon: const Icon(Icons.add),
      //   label: const Text('Add Steps'),
      //   backgroundColor: Colors.blue,
      // ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    // Samsung Health style: circular progress with centered content
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 4,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChip(String level) {
    final isSelected = controller.selectedLevel.value == level;
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => controller.filterByLevel(level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90E2)
              : (isDark ? const Color(0xFF2C2C2E) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
        ),
        child: Text(
          level,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[300] : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, workout) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to workout details with hero animation
          Get.toNamed('/workout-detail', arguments: workout);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Image with Hero Animation
            Expanded(
              child: Hero(
                tag: 'workout-${workout.id}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: workout.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(workout.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: workout.imageUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Workout Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.duration} min',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workout.calories} cal',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(workout.level).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      workout.level,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(workout.level),
                      ),
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

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A90E2),
                  const Color(0xFF50C878),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                  controller.getUserName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const SizedBox(height: 4),
                Text(
                  controller.getGreeting(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: const Color(0xFF4A90E2)),
            title: Text('Home', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person, color: const Color(0xFF4A90E2)),
            title: Text('Profile', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile tab
            },
          ),
          ListTile(
            leading: Icon(Icons.fitness_center, color: const Color(0xFF4A90E2)),
            title: Text('Workouts', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to workouts tab
            },
          ),
          ListTile(
            leading: Icon(Icons.trending_up, color: const Color(0xFF4A90E2)),
            title: Text('Progress', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to progress tab
            },
          ),
          ListTile(
            leading: Icon(Icons.build, color: const Color(0xFF4A90E2)),
            title: Text('Tools', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              // Navigate to tools tab
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            title: Text('Settings', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            title: Text('Help & Support', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Handle logout
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        // TODO: Implement logout
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
