import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final users = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      // Only fetch users collection (not shelters)
      final snapshot = await _firestore.collection('users').get();
      users.value = snapshot.docs.map((doc) {
        return {'uid': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      // Tidak perlu update role lagi karena users hanya untuk user biasa
      // Field 'role' sudah tidak digunakan
      
      Get.snackbar(
        'Info',
        'User sudah berada di koleksi yang tepat',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchUsers(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah role: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Hapus dari Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Note: Menghapus user dari Firebase Auth memerlukan Admin SDK
      // Untuk saat ini kita hanya hapus dari Firestore

      Get.snackbar(
        'Sukses',
        'User berhasil dihapus dari database',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchUsers(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': !currentStatus,
      });

      Get.snackbar(
        'Sukses',
        currentStatus ? 'User dinonaktifkan' : 'User diaktifkan',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchUsers(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String getRoleName(String role) {
    // All users in 'users' collection are regular users
    return 'User';
  }
}
