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
						"Semua field wajib diisi",
						snackPosition: SnackPosition.TOP,
						backgroundColor: Colors.red,
						colorText: Colors.white,
					);
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
					return;
				}

				isLoading.value = true;
				Get.snackbar(
					"Mohon tunggu",
					"Sedang memproses registrasi...",
					snackPosition: SnackPosition.TOP,
					backgroundColor: Colors.blue,
					colorText: Colors.white,
					duration: const Duration(seconds: 2),
				);
				try {
					// Register ke Firebase Auth
					UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
						email: emailController.text.trim(),
						password: passwordController.text.trim(),
					);

					// Simpan data user ke Firestore
					await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
						'uid': userCredential.user!.uid,
						'name': nameController.text.trim(),
						'email': emailController.text.trim(),
						'role': 'user',
						'createdAt': FieldValue.serverTimestamp(),
					});

					// Langsung masuk ke halaman userHome, kirim nama user
					Get.offAllNamed('/user-home', arguments: {
						'name': nameController.text.trim(),
					});
					Get.snackbar(
						"Berhasil",
						"Registrasi berhasil! Selamat datang!",
						snackPosition: SnackPosition.TOP,
						backgroundColor: Colors.green,
						colorText: Colors.white,
					);
				} on FirebaseAuthException catch (e) {
					String msg = e.message ?? 'Terjadi kesalahan';
					if (e.code == 'email-already-in-use') {
						msg = 'Email sudah terdaftar';
					}
					Get.snackbar(
						"Register Gagal",
						msg,
						snackPosition: SnackPosition.TOP,
						backgroundColor: Colors.red,
						colorText: Colors.white,
					);
				} catch (e) {
					Get.snackbar(
						"Register Gagal",
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
