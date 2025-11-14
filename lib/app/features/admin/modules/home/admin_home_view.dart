import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_colors.dart';
import 'admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => controller.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                'Welcome, Admin!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage users and verify shelters',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 32),

              // Menu Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      icon: Icons.people,
                      title: 'Manage Users',
                      description: 'CRUD & Change Role',
                      color: AppColors.primary,
                      onTap: () => Get.toNamed('/admin/user-management'),
                    ),
                    _buildMenuCard(
                      icon: Icons.store,
                      title: 'Shelter Verification',
                      description: 'Manage Submissions',
                      color: AppColors.green700,
                      onTap: () => Get.toNamed('/admin/shelter-verification'),
                    ),
                    _buildMenuCard(
                      icon: Icons.pets,
                      title: 'Total Pets',
                      description: 'View Statistics',
                      color: AppColors.green500,
                      onTap: () {
                        // TODO: Navigate to statistics
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.event,
                      title: 'Total Events',
                      description: 'View Statistics',
                      color: Colors.orange,
                      onTap: () {
                        // TODO: Navigate to events statistics
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.neutral500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
