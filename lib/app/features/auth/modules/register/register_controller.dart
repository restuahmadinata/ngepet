import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController extends GetxController {
  // Controller untuk input field
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State untuk menampilkan/menyembunyikan password
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  // Method yang akan dipanggil saat tombol register ditekan
  Future<void> register() async {
    if (isLoading.value) return;
    
    // Validasi field kosong
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    // Validasi format email
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    // Validasi panjang nama
    if (nameController.text.trim().length < 3) {
      Get.snackbar(
        "Error",
        "Name must be at least 3 characters long",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    // Validasi panjang password
    if (passwordController.text.length < 6) {
      Get.snackbar(
        "Error",
        "Password must be at least 6 characters long",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    // Validasi password match
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Password and confirm password do not match",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    isLoading.value = true;
    
    try {
      // Register ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Simpan data user ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'userId': userCredential.user!.uid,
            'fullName': nameController.text.trim(),
            'email': emailController.text.trim(),
            'accountStatus': 'active',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Tampilkan success message
      Get.snackbar(
        "Success",
        "Registration successful! Welcome, ${nameController.text.trim()}!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );

      // Langsung masuk ke halaman userHome, kirim nama user
      Get.offAllNamed(
        '/user-home',
        arguments: {'name': nameController.text.trim()},
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already registered. Please login instead.';
          break;
        case 'invalid-email':
          msg = 'Invalid email address format.';
          break;
        case 'operation-not-allowed':
          msg = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          msg = 'Password is too weak. Please use a stronger password.';
          break;
        case 'network-request-failed':
          msg = 'Network error. Please check your internet connection.';
          break;
        default:
          msg = e.message ?? 'Registration failed. Please try again.';
      }
      Get.snackbar(
        "Registration Failed",
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        "An unexpected error occurred. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
