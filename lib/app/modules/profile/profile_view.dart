import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ngepet/app/controllers/auth_controller.dart';
import 'package:ngepet/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileController extends GetxController {}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final String userName = _getFullName();
    final String profileImageUrl = 'https://randomuser.me/api/portraits/women/1.jpg'; // Dummy image
    final int followingCount = 42; // Dummy following count
    final String userLocation = 'Jakarta, Indonesia'; // Dummy location

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Section 1: Profile Info
                Column(
                  children: [
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: profileImageUrl,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.people, color: Colors.grey, size: 48),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.people),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 20, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          userLocation,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$followingCount Following',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Section 2: Option Menu
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.neutral400, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.edit,
                        title: 'Edit Profil',
                        onTap: () {
                          // Handle edit profile
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info,
                        title: 'Tentang Kami',
                        onTap: () {
                          // Handle about us
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.assignment,
                        title: 'Status Pengajuan Adopsi',
                        onTap: () {
                          // Handle adoption status
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: Logout
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.neutral400, width: 1),
                  ),
                  child: _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    textColor: Colors.red,
                    onTap: () async {
                      await Get.find<AuthController>().signOut();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: AppColors.neutral400),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutral400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getFullName() {
    final args = Get.arguments;
    final name = args != null && args['name'] != null
        ? args['name'] as String
        : 'User';
    return name;
  }
}
