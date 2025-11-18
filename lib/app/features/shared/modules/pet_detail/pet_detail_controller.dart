import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final hasApplied = false.obs;
  final isLoading = true.obs;
  // Removed requestStatus and applicationStatus fields
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
  final doc = querySnapshot.docs.first;
        hasApplied.value = true;
        applicationId = doc.id;
  // We only track whether user has applied; detailed status view is in Adoption Status screen.
        print('✅ User has already applied for this pet');
      } else {
        hasApplied.value = false;
        applicationId = null;
  // Resetting status values isn't necessary here
        print('✅ User has not applied for this pet');
      }
    } catch (e) {
      print('❌ Error checking application status: $e');
      hasApplied.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel logic should only be handled via AdoptionStatusController to keep UI flows consistent.
}
