import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/controllers/auth_controller.dart'; // Import AuthController

class LoginController extends GetxController {
  // Controller untuk input field
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State untuk menampilkan/menyembunyikan password
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  // Dapatkan instance AuthController yang sudah di-manage oleh GetX
  final AuthController authController = Get.find<AuthController>();

  // Method yang akan dipanggil saat tombol login ditekan
  Future<void> login() async {
    if (isLoading.value) return;
    
    // Validasi sederhana
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan Password tidak boleh kosong",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isLoading.value = true;
    
    // Tampilkan feedback bahwa sistem sedang memproses
    Get.snackbar(
      "Mohon Tunggu",
      "Sedang memproses login...",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      showProgressIndicator: true,
    );

    try {
      // Panggil fungsi signIn dari AuthController
      await authController.signIn(emailController.text, passwordController.text);
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk lupa password
  Future<void> forgotPassword() async {
    if (isLoading.value) return;
    
    if (emailController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Masukkan email terlebih dahulu",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    
    Get.snackbar(
      "Mohon Tunggu",
      "Mengirim email reset password...",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      showProgressIndicator: true,
    );
    
    try {
      await authController.resetPassword(emailController.text);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
