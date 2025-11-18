import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final users = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedRole = ''.obs;
  final searchQuery = ''.obs;

  // Filtered users based on search query
  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.value.isEmpty) {
      return users;
    }
    
    final query = searchQuery.value.toLowerCase();
    return users.where((user) {
      final name = (user['fullName'] ?? user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

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
      print('Error fetching users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      // No need to update role anymore as users collection is only for regular users
      // 'role' field is no longer used

      fetchUsers(); // Refresh data
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Delete from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Note: Deleting user from Firebase Auth requires Admin SDK
      // For now we only delete from Firestore

      fetchUsers(); // Refresh data
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': !currentStatus,
      });

      fetchUsers(); // Refresh data
    } catch (e) {
      print('Error toggling user status: $e');
    }
  }

  String getRoleName(String role) {
    // All users in 'users' collection are regular users
    return 'User';
  }
}
