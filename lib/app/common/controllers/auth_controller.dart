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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Ambil data dari Firestore
      final uid = userCredential.user?.uid;
      if (uid != null) {
        // Check in admins collection first
        final adminDoc = await _firestore.collection('admins').doc(uid).get();
        
        if (adminDoc.exists) {
          final data = adminDoc.data();
          final name = data?['name'] ?? 'Admin';
          
          print('🔍 Login - Admin Name: $name');
          print('✅ Redirecting to Admin Home');
          Get.offAllNamed(AppRoutes.adminHome, arguments: {'name': name});
          return;
        }

        // Check in users collection
        final userDoc = await _firestore.collection('users').doc(uid).get();
        
        if (userDoc.exists) {
          final data = userDoc.data();
          final name = data?['name'] ?? 'User';

          print('🔍 Login - User Name: $name');
          print('✅ Redirecting to User Home');
          Get.offAllNamed(AppRoutes.userHome, arguments: {'name': name});
          return;
        }

        // Check in shelters collection
        final shelterDoc = await _firestore.collection('shelters').doc(uid).get();
        
        if (shelterDoc.exists) {
          final data = shelterDoc.data();
          final name = data?['shelterName'] ?? 'Shelter';
          final verificationStatus = data?['verificationStatus'];
          
          print('🔍 Login - Shelter Name: $name');
          print('🔍 Login - Verification Status: $verificationStatus');

          // Check verification status
          if (verificationStatus == 'approved') {
            print('✅ Redirecting to Shelter Home');
            Get.offAllNamed(AppRoutes.shelterHome, arguments: {'name': name});
          } else {
            // If pending or rejected, redirect to verification page
            print('⚠️ Shelter not verified, redirecting to Verification');
            Get.offAllNamed(AppRoutes.verification);
          }
          return;
        }

        // If not found in any collection, default to user home
        print('⚠️ User not found in any collection, redirecting to User Home');
        Get.offAllNamed(AppRoutes.userHome);
      } else {
        // Jika UID tidak ditemukan, default ke user home
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

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
    Get.offAllNamed(
      AppRoutes.starter,
    ); // Kembali ke halaman starter setelah logout
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
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('role') as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
