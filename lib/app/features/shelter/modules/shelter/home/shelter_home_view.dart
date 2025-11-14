import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_colors.dart';
import 'shelter_home_controller.dart';

class ShelterHomeView extends GetView<ShelterHomeController> {
  const ShelterHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shelter Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome,',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      controller.shelterName.value,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistics cards
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'My Pets',
                        controller.petCount.value.toString(),
                        Icons.pets,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'My Events',
                        controller.eventCount.value.toString(),
                        Icons.event,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Adoption Requests',
                        controller.adoptionRequestCount.value.toString(),
                        Icons.assignment,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick actions section
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      'Add Pet',
                      Icons.add_circle,
                      AppColors.primary,
                      controller.goToAddPet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      'Add Event',
                      Icons.event_note,
                      Colors.purple,
                      controller.goToAddEvent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Profile section
              Text(
                'Shelter Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                'Edit Shelter Profile',
                'Update your shelter information and data',
                Icons.edit,
                Colors.blue,
                controller.goToEditProfile,
              ),
              const SizedBox(height: 32),

              // Main menu section
              Text(
                'Manage Data',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Menu items
              _buildMenuCard(
                'Manage My Pets',
                'View, edit, and delete pet data you uploaded',
                Icons.pets,
                AppColors.primary,
                controller.goToManagePets,
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                'Manage My Events',
                'View, edit, and delete events you created',
                Icons.event,
                Colors.purple,
                controller.goToManageEvents,
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                'Review Adoption Requests',
                'Manage adoption requests for your pets',
                Icons.assignment_turned_in,
                Colors.orange,
                controller.goToAdoptionRequests,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout from your shelter account?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}