import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        'Failed to fetch user data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      // No need to update role anymore as users collection is only for regular users
      // 'role' field is no longer used
      
      Get.snackbar(
        'Info',
        'User is already in the correct collection',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchUsers(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change role: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Delete from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Note: Deleting user from Firebase Auth requires Admin SDK
      // For now we only delete from Firestore

      Get.snackbar(
        'Success',
        'User successfully deleted from database',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchUsers(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete user: $e',
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
        'Success',
        currentStatus ? 'User deactivated' : 'User activated',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchUsers(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String getRoleName(String role) {
    // All users in 'users' collection are regular users
    return 'User';
  }
}
