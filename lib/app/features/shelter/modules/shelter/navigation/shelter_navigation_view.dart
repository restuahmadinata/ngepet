import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
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
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(Get.context!).primaryColor
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
