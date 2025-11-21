import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/profile_controller.dart';

/// Profile screen for viewing and editing user profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.userProfile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.userProfile.value;
        if (profile == null) {
          return const Center(child: Text('No profile data'));
        }

        return CustomScrollView(
          slivers: [
            // App Bar with profile photo
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              actions: [
                if (!controller.isEditMode.value)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: controller.toggleEditMode,
                  ),
                if (controller.isEditMode.value)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.toggleEditMode,
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  controller.isEditMode.value ? 'Edit Profile' : 'Profile',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildProfilePhoto(controller, profile),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Section
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    _buildBasicInfoFields(controller),

                    const SizedBox(height: 32),

                    // Health Info Section
                    _buildSectionTitle('Health Information'),
                    const SizedBox(height: 16),
                    _buildHealthInfoFields(controller),

                    const SizedBox(height: 32),

                    // Goals Section
                    _buildSectionTitle('Daily Goals'),
                    const SizedBox(height: 16),
                    _buildGoalsFields(controller),

                    const SizedBox(height: 32),

                    // Notifications Section
                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 16),
                    _buildNotificationSettings(controller, context),

                    const SizedBox(height: 32),

                    // Premium Badge (if applicable)
                    if (profile.isPremium == true) _buildPremiumBadge(),

                    const SizedBox(height: 32),

                    // Action Buttons
                    if (controller.isEditMode.value)
                      _buildSaveButton(controller)
                    else
                      _buildLogoutButton(controller),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Profile photo with edit button
  Widget _buildProfilePhoto(ProfileController controller, profile) {
    return Stack(
      children: [
        Obx(() {
          if (controller.isUploadingPhoto.value) {
            return const CircleAvatar(
              radius: 50,
              child: CircularProgressIndicator(),
            );
          }

          return CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: profile.photoUrl != null
                ? CachedNetworkImageProvider(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null
                ? Text(
                    profile.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  )
                : null,
          );
        }),
        if (controller.isEditMode.value)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickAndUploadPhoto,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Basic info fields
  Widget _buildBasicInfoFields(ProfileController controller) {
    return Obx(() {
      if (!controller.isEditMode.value) {
        return Column(
          children: [
            _buildInfoCard(
              'Name',
              controller.userProfile.value!.name,
              Icons.person,
            ),
            _buildInfoCard(
              'Email',
              controller.userProfile.value!.email,
              Icons.email,
            ),
          ],
        );
      }

      return Column(
        children: [
          _buildTextField(
            controller: controller.nameController,
            label: 'Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Email',
            controller.userProfile.value!.email,
            Icons.email,
          ),
        ],
      );
    });
  }

  /// Health info fields
  Widget _buildHealthInfoFields(ProfileController controller) {
    return Obx(() {
      if (!controller.isEditMode.value) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Age',
                    '${controller.userProfile.value!.age ?? 'Not set'} yrs',
                    Icons.cake,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Gender',
                    controller.userProfile.value!.gender ?? 'Not set',
                    Icons.wc,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Height',
                    '${controller.userProfile.value!.height ?? 'Not set'} cm',
                    Icons.height,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Weight',
                    '${controller.userProfile.value!.weight ?? 'Not set'} kg',
                    Icons.monitor_weight,
                  ),
                ),
              ],
            ),
            if (controller.userProfile.value!.bmi != null) ...[
              const SizedBox(height: 16),
              _buildBMICard(controller.userProfile.value!),
            ],
          ],
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.ageController,
                  label: 'Age',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderSelector(controller)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.heightController,
                  label: 'Height (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: controller.weightController,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Goals fields
  Widget _buildGoalsFields(ProfileController controller) {
    return Obx(() {
      if (!controller.isEditMode.value) {
        return _buildInfoCard(
          'Daily Step Goal',
          '${controller.userProfile.value!.dailyStepGoal ?? 10000} steps',
          Icons.directions_walk,
        );
      }

      return _buildTextField(
        controller: controller.stepGoalController,
        label: 'Daily Step Goal',
        icon: Icons.directions_walk,
        keyboardType: TextInputType.number,
      );
    });
  }

  /// Notification settings
  Widget _buildNotificationSettings(
    ProfileController controller,
    BuildContext context,
  ) {
    return Obx(
      () => Column(
        children: [
          // Enable/Disable Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Enable Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
                  activeColor: Colors.purple,
                ),
              ],
            ),
          ),

          if (controller.notificationsEnabled.value) ...[
            const SizedBox(height: 16),

            // Workout Reminder
            _buildReminderCard(
              title: 'Workout Reminder',
              icon: Icons.fitness_center,
              time: controller.formatTime(
                controller.workoutReminderHour.value,
                controller.workoutReminderMinute.value,
              ),
              color: Colors.blue,
              onTap: () => controller.pickWorkoutReminderTime(context),
            ),

            const SizedBox(height: 16),

            // Water Reminder
            _buildReminderCard(
              title: 'Water Reminder',
              icon: Icons.water_drop,
              time: controller.formatTime(
                controller.waterReminderHour.value,
                controller.waterReminderMinute.value,
              ),
              color: Colors.cyan,
              onTap: () => controller.pickWaterReminderTime(context),
            ),

            const SizedBox(height: 16),

            // Test Notification Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.testNotification,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Test Now'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.purple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.checkPendingNotifications,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Check Pending'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Help info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Note: Scheduled notifications work best when battery optimization is disabled for this app in Settings.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Reminder card
  Widget _buildReminderCard({
    required String title,
    required IconData icon,
    required String time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.access_time, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  /// Info card
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purple.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BMI card
  Widget _buildBMICard(profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Body Mass Index',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.bmi!.toStringAsFixed(1)} - ${profile.bmiCategory}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /// Gender selector
  Widget _buildGenderSelector(ProfileController controller) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedGender.value,
        decoration: InputDecoration(
          labelText: 'Gender',
          prefixIcon: const Icon(Icons.wc),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: ['Male', 'Female', 'Other'].map((gender) {
          return DropdownMenuItem(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.selectedGender.value = value;
          }
        },
      ),
    );
  }

  /// Premium badge
  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.star, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enjoy all premium features',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Save button
  Widget _buildSaveButton(ProfileController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  /// Logout button
  Widget _buildLogoutButton(ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
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
                  onPressed: () {
                    Get.back();
                    controller.logout();
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
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
