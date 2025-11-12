import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../routes/app_routes.dart';

class VerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final shelterNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();
  final legalNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;
  final verificationStatus = Rx<String?>(null);
  final rejectionReason = Rx<String?>(null);
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isExistingUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    final user = _auth.currentUser;
    isExistingUser.value = user != null;
    
    if (user != null) {
      emailController.text = user.email ?? '';
      checkVerificationStatus();
    }
  }

  @override
  void onClose() {
    shelterNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    legalNumberController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Check current verification status
  Future<void> checkVerificationStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check in shelters collection first
      final shelterDoc = await _firestore.collection('shelters').doc(user.uid).get();
      
      if (shelterDoc.exists) {
        final data = shelterDoc.data()!;
        verificationStatus.value = data['verificationStatus'];
        
        if (verificationStatus.value == 'rejected') {
          rejectionReason.value = data['rejectionReason'];
        } else if (verificationStatus.value == 'pending') {
          // Load existing data
          shelterNameController.text = data['shelterName'] ?? '';
          addressController.text = data['address'] ?? '';
          phoneController.text = data['phone'] ?? '';
          legalNumberController.text = data['legalNumber'] ?? '';
          descriptionController.text = data['description'] ?? '';
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }
  }

  // Submit verification request
  Future<void> submitVerification() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      
      User? user = _auth.currentUser;
      
      // If user is not logged in, create a new account first
      if (user == null) {
        // Validate password fields for new registration
        if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
          Get.snackbar(
            "Error",
            "Password dan konfirmasi password wajib diisi",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
        
        if (passwordController.text != confirmPasswordController.text) {
          Get.snackbar(
            "Error",
            "Password dan konfirmasi password tidak sama",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
        
        // Create new Firebase Auth account
        try {
          Get.snackbar(
            "Mohon Tunggu",
            "Membuat akun shelter...",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            showProgressIndicator: true,
          );
          
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
          
          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          String msg = e.message ?? 'Terjadi kesalahan';
          if (e.code == 'email-already-in-use') {
            msg = 'Email sudah terdaftar. Silakan login terlebih dahulu.';
          } else if (e.code == 'weak-password') {
            msg = 'Password terlalu lemah. Minimal 6 karakter.';
          }
          Get.snackbar(
            "Pendaftaran Gagal",
            msg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      }
      
      if (user == null) {
        Get.snackbar(
          "Error",
          "Gagal membuat akun. Silakan coba lagi.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // Create or update shelter document in shelters collection
      Get.snackbar(
        "Mohon Tunggu",
        "Mengirim pengajuan verifikasi...",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );
      
      await _firestore.collection('shelters').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'shelterName': shelterNameController.text.trim(),
        'address': addressController.text.trim(),
        'legalNumber': legalNumberController.text.trim(),
        'phone': phoneController.text.trim(),
        'description': descriptionController.text.trim(),
        'verificationStatus': 'pending',
        'isVerified': false,
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'rejectionReason': FieldValue.delete(), // Hapus alasan penolakan sebelumnya jika ada
      }, SetOptions(merge: true));

      Get.snackbar(
        "Berhasil Dikirim",
        "Pengajuan verifikasi shelter Anda telah dikirim dan akan diproses dalam 1-3 hari kerja",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Update local state
      verificationStatus.value = 'pending';
      rejectionReason.value = null;
      isExistingUser.value = true;

      // Reload the page to show status
      await Future.delayed(const Duration(seconds: 1));
      checkVerificationStatus();
      
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengirim pengajuan: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Validation methods
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  // Navigation method
  void goToShelterHome() {
    Get.offAllNamed(AppRoutes.shelterHome);
  }

  void backToStarter() {
    Get.offAllNamed(AppRoutes.starter);
  }
}
