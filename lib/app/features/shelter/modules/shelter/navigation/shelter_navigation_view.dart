import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/shelter_dashboard_view.dart';
import '../manage/shelter_manage_view.dart';
import '../profile/shelter_profile_view.dart';
import 'shelter_navigation_controller.dart';

class ShelterNavigationView extends GetView<ShelterNavigationController> {
  const ShelterNavigationView({super.key});

  final List<Widget> _pages = const [
    ShelterDashboardView(),
    ShelterManageView(),
    ShelterProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      return Scaffold(
        extendBody: true,
        body: _pages[currentIndex],
        bottomNavigationBar: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard,
                label: 'Dashboard',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.inventory,
                label: 'Manage',
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person,
                label: 'Profile',
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.changePage(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(Get.context!).primaryColor
                      : Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
