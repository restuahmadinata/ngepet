import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final shelterNameController = TextEditingController();
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

  @override
  void onInit() {
    super.onInit();
    checkVerificationStatus();
  }

  @override
  void onClose() {
    shelterNameController.dispose();
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
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        verificationStatus.value = data['verificationStatus'];
        
        if (verificationStatus.value == 'rejected') {
          rejectionReason.value = data['rejectionReason'];
        } else if (verificationStatus.value == 'pending') {
          // Load existing data
          shelterNameController.text = data['shelterName'] ?? '';
          addressController.text = data['shelterAddress'] ?? '';
          phoneController.text = data['shelterPhone'] ?? '';
          legalNumberController.text = data['shelterLegalNumber'] ?? '';
          descriptionController.text = data['shelterDescription'] ?? '';
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

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error",
        "Anda harus login terlebih dahulu",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Update user document with shelter verification data
      await _firestore.collection('users').doc(user.uid).update({
        'shelterName': shelterNameController.text.trim(),
        'shelterAddress': addressController.text.trim(),
        'shelterLegalNumber': legalNumberController.text.trim(),
        'shelterPhone': phoneController.text.trim(),
        'shelterDescription': descriptionController.text.trim(),
        'verificationStatus': 'pending',
        'role': 'shelter',
        'isVerified': false,
        'submittedAt': FieldValue.serverTimestamp(),
        'rejectionReason': FieldValue.delete(), // Hapus alasan penolakan sebelumnya jika ada
      });

      Get.snackbar(
        "Berhasil Dikirim",
        "Pengajuan verifikasi Anda telah dikirim dan akan diproses dalam 1-3 hari kerja",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Update local state
      verificationStatus.value = 'pending';
      rejectionReason.value = null;

      // Go back to profile
      Get.back();
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
}
