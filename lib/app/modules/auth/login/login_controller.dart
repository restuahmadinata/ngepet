import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Import AuthController

class LoginController extends GetxController {
  // Controller untuk input field
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State untuk menampilkan/menyembunyikan password
  var isPasswordHidden = true.obs;

  // Dapatkan instance AuthController yang sudah di-manage oleh GetX
  final AuthController authController = Get.find<AuthController>();

  // Method yang akan dipanggil saat tombol login ditekan
  void login() {
    // Validasi sederhana
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan Password tidak boleh kosong",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Panggil fungsi signIn dari AuthController
    authController.signIn(emailController.text, passwordController.text);
  }

  // Method untuk lupa password
  void forgotPassword() {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Masukkan email terlebih dahulu",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    authController.resetPassword(emailController.text);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}