import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> suspendUser(
    String uid,
    DateTime startDate,
    DateTime endDate,
    String reason,
  ) async {
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Create suspension record
      final suspensionRef = await _firestore.collection('suspensions').add({
        'userId': uid,
        'adminId': adminId,
        'reason': reason,
        'suspensionStart': Timestamp.fromDate(startDate),
        'suspensionEnd': Timestamp.fromDate(endDate),
        'status': 'active',
        'liftedBy': null,
        'liftedAt': null,
        'liftReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update suspension ID
      await suspensionRef.update({
        'suspensionId': suspensionRef.id,
      });

      // Update user's account status
      await _firestore.collection('users').doc(uid).update({
        'accountStatus': 'suspended',
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ User suspended successfully');

      fetchUsers(); // Refresh data
    } catch (e) {
      print('Error suspending user: $e');
    }
  }

  Future<void> liftSuspension(String uid, String userName) async {
    try {
      final adminId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Find active suspension for this user
      final suspensionQuery = await _firestore
          .collection('suspensions')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .get();

      if (suspensionQuery.docs.isEmpty) {
        print('No active suspension found for this user');
        return;
      }

      // Update suspension status
      for (var doc in suspensionQuery.docs) {
        await doc.reference.update({
          'status': 'lifted',
          'liftedBy': adminId,
          'liftedAt': FieldValue.serverTimestamp(),
          'liftReason': 'Lifted by admin',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update user's account status
      await _firestore.collection('users').doc(uid).update({
        'accountStatus': 'active',
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Suspension lifted for "$userName"');

      fetchUsers(); // Refresh data
    } catch (e) {
      print('Error lifting suspension: $e');
    }
  }

  String getRoleName(String role) {
    // All users in 'users' collection are regular users
    return 'User';
  }
}
