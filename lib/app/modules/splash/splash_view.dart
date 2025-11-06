import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/app_routes.dart';


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
    if (user != null) {
      // User sudah login, ambil nama dari Firestore
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final name = doc.data()?['name'] ?? 'User';
        // Ke home dengan nama user
        Get.offAllNamed(AppRoutes.userHome, arguments: {'name': name});
      } catch (e) {
        // Jika gagal ambil nama, tetap ke home tanpa nama
        Get.offAllNamed(AppRoutes.userHome);
      }
    } else {
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
