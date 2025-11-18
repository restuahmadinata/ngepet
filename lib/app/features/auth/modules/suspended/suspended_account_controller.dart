import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuspendedAccountController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final activeSuspension = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    loadSuspensionDetails();
  }

  Future<void> loadSuspensionDetails() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        return;
      }

      // Get active suspension for current user
      final suspensionQuery = await _firestore
          .collection('suspensions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (suspensionQuery.docs.isNotEmpty) {
        activeSuspension.value = suspensionQuery.docs.first.data();
      }
    } catch (e) {
      print('Error loading suspension details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
