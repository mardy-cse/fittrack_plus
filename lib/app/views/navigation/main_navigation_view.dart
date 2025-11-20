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
    return Scaffold(
      body: Obx(() => _getPage(controller.currentNavIndex.value)),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentNavIndex.value,
          onDestinationSelected: controller.changeNavIndex,
          elevation: 8,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
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
