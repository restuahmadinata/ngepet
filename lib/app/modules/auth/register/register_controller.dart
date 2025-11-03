import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
	// Controller untuk input field
	final nameController = TextEditingController();
	final emailController = TextEditingController();
	final passwordController = TextEditingController();
	final confirmPasswordController = TextEditingController();

	// State untuk menampilkan/menyembunyikan password
	var isPasswordHidden = true.obs;
	var isConfirmPasswordHidden = true.obs;

	// Method yang akan dipanggil saat tombol register ditekan
	void register() {
		// Validasi sederhana (bisa dikembangkan)
		if (nameController.text.isEmpty ||
				emailController.text.isEmpty ||
				passwordController.text.isEmpty ||
				confirmPasswordController.text.isEmpty) {
			Get.snackbar(
				"Error",
				"Semua field wajib diisi",
				snackPosition: SnackPosition.BOTTOM,
				backgroundColor: Colors.red,
				colorText: Colors.white,
			);
			return;
		}
		if (passwordController.text != confirmPasswordController.text) {
			Get.snackbar(
				"Error",
				"Password dan konfirmasi password tidak sama",
				snackPosition: SnackPosition.BOTTOM,
				backgroundColor: Colors.red,
				colorText: Colors.white,
			);
			return;
		}

		// Di sini Anda bisa menambahkan logika register ke Firebase Auth
		// Contoh:
		// try {
		//   await FirebaseAuth.instance.createUserWithEmailAndPassword(
		//     email: emailController.text,
		//     password: passwordController.text,
		//   );
		//   Get.offAllNamed('/home');
		// } on FirebaseAuthException catch (e) {
		//   Get.snackbar("Register Gagal", e.message ?? "Terjadi kesalahan");
		// }

		// Untuk sekarang, hanya print ke konsol
		print("Nama: ${nameController.text}");
		print("Email: ${emailController.text}");
		print("Password: ${passwordController.text}");

		Get.snackbar(
			"Berhasil",
			"Register diproses (cek konsol untuk data)",
			snackPosition: SnackPosition.BOTTOM,
			backgroundColor: Colors.green,
			colorText: Colors.white,
		);
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
