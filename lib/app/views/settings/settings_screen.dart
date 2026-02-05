import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Selection
          _buildSettingsSection('Appearance', [
            _buildSettingsTile(
              'Theme Selection',
              'Choose app theme',
              Icons.palette,
              Colors.purple,
              () {
                _showComingSoon('Theme Selection');
              },
              trailing: Text(
                'System',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            _buildSettingsTile(
              'Language',
              'Select app language',
              Icons.language,
              Colors.blue,
              () {
                _showComingSoon('Language Selection');
              },
              trailing: Text(
                'English',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Notifications & Sound
          _buildSettingsSection('Notifications & Sound', [
            _buildSettingsTile(
              'Notifications',
              'App notification settings',
              Icons.notifications,
              Colors.orange,
              () {
                _showComingSoon('Notification Settings');
              },
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  _showComingSoon('Notification Toggle');
                },
                activeColor: Colors.green,
              ),
            ),
            _buildSettingsTile(
              'Sound & Vibration',
              'Audio and haptic feedback',
              Icons.volume_up,
              Colors.green,
              () {
                _showComingSoon('Sound & Vibration Settings');
              },
            ),
          ]),

          const SizedBox(height: 32),

          // App Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: isDark ? Colors.white : Colors.black87,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'FitTrack Plus',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Get.theme.primaryColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Get.theme.brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: Get.theme.brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }
}
