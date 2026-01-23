import 'dart:io';
import 'dart:ui';
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
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background/Cover Image
                    Obx(() {
                      final coverUrl =
                          controller.userProfile.value?.coverImageUrl;
                      if (coverUrl != null && coverUrl.isNotEmpty) {
                        return Image.file(File(coverUrl), fit: BoxFit.cover);
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFF50C878),
                        ),
                      );
                    }),
                    // Edit button for cover image
                    if (controller.isEditMode.value)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: controller.pickBackgroundImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.wallpaper,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          _buildProfilePhoto(controller, profile),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
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

          final photoUrl = profile.photoUrl;
          ImageProvider? imageProvider;

          if (photoUrl != null) {
            // Check if it's a local file path or network URL
            if (photoUrl.startsWith('http://') ||
                photoUrl.startsWith('https://')) {
              imageProvider = CachedNetworkImageProvider(photoUrl);
            } else if (photoUrl.startsWith('/')) {
              // Local file path
              imageProvider = FileImage(File(photoUrl));
            }
          }

          return GestureDetector(
            onTap: imageProvider != null
                ? () {
                    // Show image in dialog with blur
                    Get.dialog(
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(20),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Center(
                                      child: photoUrl.startsWith('/')
                                          ? Image.file(
                                              File(photoUrl),
                                              fit: BoxFit.contain,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: photoUrl,
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    onPressed: () => Get.back(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      barrierColor: Colors.black54,
                    );
                  }
                : null,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Text(
                      profile.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90E2),
                      ),
                    )
                  : null,
            ),
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
                  color: const Color(0xFF4A90E2),
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
            const SizedBox(height: 12),
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

  /// Info card
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4A90E2)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// BMI card
  Widget _buildBMICard(profile) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.favorite, color: const Color(0xFF4A90E2), size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Mass Index',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.bmi!.toStringAsFixed(1)} - ${profile.bmiCategory}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
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
      },
    );
  }

  /// Text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          ),
        );
      },
    );
  }

  /// Gender selector
  Widget _buildGenderSelector(ProfileController controller) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedGender.value,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: const Icon(Icons.wc),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
      },
    );
  }

  /// Premium badge
  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF6B6B)],
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
            backgroundColor: const Color(0xFF4A90E2),
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
