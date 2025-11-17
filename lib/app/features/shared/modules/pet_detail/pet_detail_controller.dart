import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final hasApplied = false.obs;
  final isLoading = true.obs;
  String? applicationId;

  Future<void> checkApplicationStatus(String petId) async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        hasApplied.value = false;
        return;
      }

      // Check if user has already applied for this pet
      final querySnapshot = await _firestore
          .collection('adoption_applications')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        hasApplied.value = true;
        applicationId = querySnapshot.docs.first.id;
        print('✅ User has already applied for this pet');
      } else {
        hasApplied.value = false;
        applicationId = null;
        print('✅ User has not applied for this pet');
      }
    } catch (e) {
      print('❌ Error checking application status: $e');
      hasApplied.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
