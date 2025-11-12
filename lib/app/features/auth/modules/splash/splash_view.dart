import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu sebentar untuk menampilkan splash
    await Future.delayed(const Duration(seconds: 2));

    // Periksa apakah user sudah login
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 Splash - Current User: ${user?.uid}');

    if (user != null) {
      // User sudah login, cek di koleksi admins terlebih dahulu
      try {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          final data = adminDoc.data();
          final name = data?['name'] ?? 'Admin';

          print('🔍 Splash - Admin Name: $name');
          print('✅ Redirecting to Admin Home');
          Get.offAllNamed(AppRoutes.adminHome, arguments: {'name': name});
          return;
        }

        // Check in users collection
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final name = data?['name'] ?? 'User';

          print('🔍 Splash - User Name: $name');
          print('✅ Redirecting to User Home');
          Get.offAllNamed(AppRoutes.userHome, arguments: {'name': name});
          return;
        }

        // Jika tidak ada di admins dan users, cek di shelters collection
        final shelterDoc = await FirebaseFirestore.instance
            .collection('shelters')
            .doc(user.uid)
            .get();

        if (shelterDoc.exists) {
          final data = shelterDoc.data();
          final name = data?['shelterName'] ?? 'Shelter';
          final verificationStatus = data?['verificationStatus'];

          print('🔍 Splash - Shelter Name: $name');
          print('🔍 Splash - Verification Status: $verificationStatus');

          // Check verification status
          if (verificationStatus == 'approved') {
            print('✅ Redirecting to Shelter Home');
            Get.offAllNamed(AppRoutes.shelterHome, arguments: {'name': name});
          } else {
            // If pending or rejected, redirect to verification page
            print('⚠️ Shelter not verified, redirecting to Verification');
            Get.offAllNamed(AppRoutes.verification);
          }
          return;
        }

        // Tidak ada di ketiga collection, ke starter
        print('❌ User not found in any collection, redirecting to Starter');
        Get.offAllNamed(AppRoutes.starter);
      } catch (e) {
        print('❌ Error fetching user data: $e');
        // Jika gagal ambil data, ke starter
        Get.offAllNamed(AppRoutes.starter);
      }
    } else {
      print('❌ No user logged in, redirecting to Starter');
      // User belum login, ke starter
      Get.offAllNamed(AppRoutes.starter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_ngepet.png',
                width: 400,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 100,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
              SizedBox(height: 32),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[500]!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
