import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rx<User?> agar UI bisa bereaksi terhadap perubahan status login
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  User? get user => _firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    // Listener untuk perubahan status auth (login, logout)
    _firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Fungsi untuk Login
  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Ambil data user dari Firestore
      final uid = userCredential.user?.uid;
      if (uid != null) {
        final doc = await _firestore.collection('users').doc(uid).get();
        final name = doc.data()?['name'] ?? 'User';
        // Setelah login sukses, langsung ke home dan kirim nama user
        Get.offAllNamed(AppRoutes.userHome, arguments: {'name': name});
      } else {
        // Jika UID tidak ditemukan, tetap ke home tanpa nama
        Get.offAllNamed(AppRoutes.userHome);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Login Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Fungsi untuk Registrasi (Contoh)
  Future<void> signUp(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan informasi role ke Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': role, // 'user', 'shelter', 'admin'
          'created_at': Timestamp.now(),
        });
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Registrasi Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Fungsi untuk Logout
  Future<void> signOut() async {
  await _auth.signOut();
  Get.offAllNamed(AppRoutes.starter); // Kembali ke halaman starter setelah logout
  }

  // Fungsi untuk Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Reset Password",
        "Email reset password telah dikirim ke $email",
        snackPosition: SnackPosition.TOP,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Mengambil Role dari Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.get('role') as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}