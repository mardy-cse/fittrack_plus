import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../home/home_tab_view.dart';
import '../progress/progress_tab_view.dart';
import '../tools/tools_tab_view.dart';
import '../profile/profile_tab_view.dart';

class MainNavigationView extends GetView<HomeController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Obx(() => _getPage(controller.currentNavIndex.value)),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: controller.currentNavIndex.value == 0,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up_rounded,
                    label: 'Progress',
                    index: 1,
                    isSelected: controller.currentNavIndex.value == 1,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.fitness_center_outlined,
                    selectedIcon: Icons.fitness_center_rounded,
                    label: 'Tools',
                    index: 2,
                    isSelected: controller.currentNavIndex.value == 2,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    isSelected: controller.currentNavIndex.value == 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF4A90E2); // Samsung Health blue
    
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeNavIndex(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 2),
            // Samsung Health style indicator dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeTabView();
      case 1:
        return const ProgressTabView();
      case 2:
        return const ToolsTabView();
      case 3:
        return const ProfileTabView();
      default:
        return const HomeTabView();
    }
  }
}
