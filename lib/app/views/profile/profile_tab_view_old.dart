import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../services/auth_service.dart';

class ProfileTabView extends GetView<HomeController> {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header
              Obx(() {
                final user = controller.userProfile.value;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      backgroundImage:
                          user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child:
                          user?.photoUrl == null ||
                              user?.photoUrl?.isEmpty == true
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // Stats Cards
              Obx(() {
                final user = controller.userProfile.value;
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Height',
                        user?.height != null ? '${user!.height} cm' : '--',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Weight',
                        user?.weight != null ? '${user!.weight} kg' : '--',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Age',
                        user?.age != null ? '${user!.age}' : '--',
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 32),

              // Menu Items
              _buildMenuItem('Edit Profile', Icons.edit, () {
                _showEditProfileDialog(context);
              }),
              _buildMenuItem('Fitness Goals', Icons.flag, () {
                _showFitnessGoalsDialog(context);
              }),
              _buildMenuItem('Achievements', Icons.emoji_events, () {
                Get.snackbar(
                  'Achievements',
                  'View your badges',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }),
              _buildMenuItem('Settings', Icons.settings, () {
                _showSettingsDialog(context);
              }),
              _buildMenuItem('Help & Support', Icons.help, () {
                Get.snackbar(
                  'Help & Support',
                  'Get help',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }),
              _buildMenuItem('About Us', Icons.info, () {
                _showAboutDialog(context);
              }),

              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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
                            onPressed: () async {
                              await authService.signOut();
                              Get.offAllNamed('/login');
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // App Version
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: controller.userProfile.value?.name,
    );
    final heightController = TextEditingController(
      text: controller.userProfile.value?.height?.toString() ?? '',
    );
    final weightController = TextEditingController(
      text: controller.userProfile.value?.weight?.toString() ?? '',
    );
    final ageController = TextEditingController(
      text: controller.userProfile.value?.age?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final userId = Get.find<AuthService>().currentUserId;
              if (userId != null) {
                await controller.userService.updateUserFields(userId, {
                  'name': nameController.text,
                  'height': int.tryParse(heightController.text),
                  'weight': int.tryParse(weightController.text),
                  'age': int.tryParse(ageController.text),
                });
                await controller.loadUserProfile();
                Get.back();
                Get.snackbar(
                  'Success',
                  'Profile updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFitnessGoalsDialog(BuildContext context) {
    final user = controller.userProfile.value;
    final weeklyGoalController = TextEditingController(
      text: user?.weeklyWorkoutGoal?.toString() ?? '5',
    );
    final dailyCaloriesController = TextEditingController(
      text: user?.dailyCalorieGoal?.toString() ?? '500',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fitness Goals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weeklyGoalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weekly Workout Goal (sessions)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dailyCaloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Calorie Burn Goal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_fire_department),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final userId = Get.find<AuthService>().currentUserId;
              if (userId != null) {
                await controller.userService.updateUserFields(userId, {
                  'weeklyWorkoutGoal': int.tryParse(weeklyGoalController.text),
                  'dailyCalorieGoal': int.tryParse(
                    dailyCaloriesController.text,
                  ),
                });
                await controller.loadUserProfile();
                Get.back();
                Get.snackbar(
                  'Success',
                  'Goals updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final user = controller.userProfile.value;
    bool notificationsEnabled = user?.notificationsEnabled ?? true;
    bool darkModeEnabled = user?.darkModeEnabled ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Workout reminders & updates'),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Coming soon'),
                value: darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    darkModeEnabled = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = Get.find<AuthService>().currentUserId;
                if (userId != null) {
                  await controller.userService.updateUserFields(userId, {
                    'notificationsEnabled': notificationsEnabled,
                    'darkModeEnabled': darkModeEnabled,
                  });
                  await controller.loadUserProfile();
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Settings updated successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FitTrack+'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Personal Fitness Companion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Built with Flutter & Firebase'),
            const SizedBox(height: 16),
            Text(
              '© 2025 FitTrack+',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
