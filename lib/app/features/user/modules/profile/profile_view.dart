import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ngepet/app/common/controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/user.dart' as app_user;
import '../../../../routes/app_routes.dart';
import '../../../../services/follower_service.dart';
import '../../../../common/widgets/lottie_loading.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FollowerService _followerService = FollowerService();
  
  final userData = Rxn<app_user.User>();
  final isLoading = true.obs;
  final followingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _listenToFollowingCount();
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

  void _listenToFollowingCount() {
    // Use stream for real-time updates
    _followerService.getFollowingCountStream().listen((count) {
      followingCount.value = count;
    });
  }

  void goToEditProfile() {
    Get.toNamed(AppRoutes.editProfile)?.then((_) {
      // Reload data after returning from edit
      _loadUserData();
    });
  }

  void goToAdoptionStatus() {
    Get.toNamed(AppRoutes.adoptionStatus);
  }

  void goToFollowing() {
    Get.toNamed('/following');
    // No need to reload, stream handles real-time updates
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
            return const Center(child: LottieLoading());
          }

          final user = controller.userData.value;
          if (user == null) {
            return const Center(
              child: Text('User data not found'),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                          child: user.profilePhoto != null
                              ? CachedNetworkImage(
                                  imageUrl: user.profilePhoto!,
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
                        user.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Location and phone removed from profile.
                      // (Location has been moved to Home view below the greeting.)
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Section 2: Option Menu (including Following count)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Following count as first menu item
                        _buildMenuItem(
                          icon: Icons.assignment,
                          title: 'My Adoption Requests',
                          onTap: controller.goToAdoptionStatus,
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: controller.goToFollowing,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.favorite, color: Colors.grey[700], size: 24),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Obx(() => Text(
                                      '${controller.followingCount.value} Following',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    )),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        _buildMenuItem(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: controller.goToEditProfile,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 4: Logout
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      textColor: Colors.red,
                      onTap: () => _showLogoutDialog(context),
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
    Color textColor = Colors.black87,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[700], size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
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
          'Are you sure you want to logout from your account?',
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
            onPressed: () async {
              Get.back();
              await Get.find<AuthController>().signOut();
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
