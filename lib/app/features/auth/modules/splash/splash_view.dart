import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _isConnectionError = false;
  bool _isLoadingRetry = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoadingRetry = true;
    });

    // Tunggu sebentar untuk menampilkan splash (simulasi loading awal)
    await Future.delayed(const Duration(seconds: 2));

    // Cek koneksi internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Double check dengan lookup jika perlu, tapi untuk simpelnya pakai connectivity_plus dulu
      // Atau bisa tambah delay dikit
      setState(() {
        _isConnectionError = true;
        _isLoadingRetry = false;
      });
      return;
    }

    setState(() {
      _isConnectionError = false;
    });

    // Periksa apakah user sudah login

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
          final name = data?['adminName'] ?? 'Admin';

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
          final name = data?['fullName'] ?? 'User';
          final accountStatus = data?['accountStatus'] ?? 'active';

          print('🔍 Splash - User Name: $name');
          print('🔍 Splash - Account Status: $accountStatus');

          // Check if user is suspended
          if (accountStatus == 'suspended') {
            print(
              '⚠️ User is suspended, redirecting to Suspended Account Page',
            );
            Get.offAllNamed(AppRoutes.suspendedAccount);
            return;
          }

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
          final accountStatus = data?['accountStatus'] ?? 'active';

          print('🔍 Splash - Shelter Name: $name');
          print('🔍 Splash - Verification Status: $verificationStatus');
          print('🔍 Splash - Account Status: $accountStatus');

          // Check if shelter is suspended
          if (accountStatus == 'suspended') {
            print(
              '⚠️ Shelter is suspended, redirecting to Suspended Account Page',
            );
            Get.offAllNamed(AppRoutes.suspendedAccount);
            return;
          }

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
          child: _isConnectionError
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 32),
                      Button1(
                        text: 'Retry',
                        onPressed: _checkAuthStatus,
                        isLoading: _isLoadingRetry,
                      ),
                    ],
                  ),
                )
              : Column(
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
                    const SizedBox(height: 32),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[500]!,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
