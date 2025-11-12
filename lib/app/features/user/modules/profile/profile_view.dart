import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ngepet/app/common/controllers/auth_controller.dart';
import 'package:ngepet/app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/user.dart' as app_user;
import '../../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final userData = Rxn<app_user.User>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        userData.value = app_user.User.fromFirestore(doc);
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToEditProfile() {
    Get.toNamed(AppRoutes.editProfile)?.then((_) {
      // Reload data after returning from edit
      _loadUserData();
    });
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.userData.value;
          if (user == null) {
            return const Center(
              child: Text('Data user tidak ditemukan'),
            );
          }

          return Center(
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
                          child: user.fotoProfil != null
                              ? CachedNetworkImage(
                                  imageUrl: user.fotoProfil!,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 180,
                                    height: 180,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person, size: 48),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 90,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.namaLengkap,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user.alamat != null && user.alamat!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                user.alamat!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (user.noTelepon != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              user.noTelepon!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          onTap: controller.goToEditProfile,
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
          );
        }),
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.neutral400, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
