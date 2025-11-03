import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Controller untuk input field
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State untuk menampilkan/menyembunyikan password
  var isPasswordHidden = true.obs;

  // Method yang akan dipanggil saat tombol login ditekan
  void login() {
    // Validasi sederhana (bisa Anda kembangkan)
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan Password tidak boleh kosong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Di sini Anda akan menambahkan logika untuk login dengan Firebase Auth
    // Contoh:
    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: emailController.text,
    //     password: passwordController.text,
    //   );
    //   Get.offAllNamed('/home'); // Arahkan ke halaman utama setelah berhasil
    // } on FirebaseAuthException catch (e) {
    //   Get.snackbar("Login Gagal", e.message ?? "Terjadi kesalahan");
    // }

    // Untuk sekarang, kita hanya print datanya ke konsol
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");

     Get.snackbar(
        "Berhasil",
        "Login diproses (cek konsol untuk data)",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
  }

  // Membersihkan controller saat halaman ditutup untuk menghindari memory leak
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}