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
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Password and confirm password do not match",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

      // Langsung masuk ke halaman userHome, kirim nama user
      Get.offAllNamed(
        '/user-home',
        arguments: {'name': nameController.text.trim()},
      );
      Get.snackbar(
        "Success",
        "Registration successful! Welcome!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'An error occurred';
      if (e.code == 'email-already-in-use') {
        msg = 'Email already registered';
      }
      Get.snackbar(
        "Registration Failed",
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
