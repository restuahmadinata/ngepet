import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShelterAdoptionManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final adoptionRequests = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdoptionRequests();
  }

  Future<void> loadAdoptionRequests() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔍 Loading adoption requests for shelter: ${user.uid}');

      // Get all adoption requests for this shelter
      // Remove orderBy to avoid index issues - we'll sort in memory
      final querySnapshot = await _firestore
          .collection('adoption_applications')
          .where('shelterId', isEqualTo: user.uid)
          .get();

      print('📊 Found ${querySnapshot.docs.length} adoption requests');

      adoptionRequests.clear();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        print('📝 Processing request: ${doc.id}');

        // Fetch pet details
        if (data['petId'] != null) {
          try {
            final petDoc =
                await _firestore.collection('pets').doc(data['petId']).get();
            if (petDoc.exists) {
              data['petData'] = petDoc.data();
              print('✅ Pet data loaded: ${petDoc.data()?['petName']}');
            } else {
              print('⚠️ Pet not found: ${data['petId']}');
            }
          } catch (e) {
            print('❌ Error loading pet: $e');
          }
        }

        // Fetch user details
        if (data['userId'] != null) {
          try {
            final userDoc =
                await _firestore.collection('users').doc(data['userId']).get();
            if (userDoc.exists) {
              data['userData'] = userDoc.data();
              print('✅ User data loaded: ${userDoc.data()?['fullName']}');
            } else {
              print('⚠️ User not found: ${data['userId']}');
            }
          } catch (e) {
            print('❌ Error loading user: $e');
          }
        }

        adoptionRequests.add(data);
      }

      // Sort in memory by application date (newest first)
      adoptionRequests.sort((a, b) {
        final aDate = a['applicationDate'] as Timestamp?;
        final bDate = b['applicationDate'] as Timestamp?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      print('✅ Total adoption requests loaded: ${adoptionRequests.length}');
    } catch (e, stackTrace) {
      print('❌ Error loading adoption requests: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load adoption requests: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? notes,
  }) async {
    try {
      // Get the adoption request to retrieve petId
      final requestDoc = await _firestore
          .collection('adoption_applications')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) {
        throw Exception('Adoption request not found');
      }
      
      final petId = requestDoc.data()?['petId'];
      
      // Update adoption request
      await _firestore.collection('adoption_applications').doc(requestId).update({
        'requestStatus': status,
        'requestProcessedDate': FieldValue.serverTimestamp(),
        'requestNotes': notes,
        'surveyStatus': status == 'approved' ? 'pending' : 'not_started',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update pet status based on request approval/rejection
      if (petId != null) {
        if (status == 'approved') {
          // When approved, set pet status to 'pending' (reserved for this adopter)
          await _firestore.collection('pets').doc(petId).update({
            'adoptionStatus': 'pending',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Pet status updated to pending');
        } else if (status == 'rejected') {
          // When rejected, set pet status back to 'available'
          await _firestore.collection('pets').doc(petId).update({
            'adoptionStatus': 'available',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Pet status reverted to available');
        }
      }

      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Request ${status == 'approved' ? 'approved' : 'rejected'} successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadAdoptionRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateSurveyStatus({
    required String requestId,
    required String status,
    String? notes,
  }) async {
    try {
      // Get the adoption request to retrieve petId
      final requestDoc = await _firestore
          .collection('adoption_applications')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) {
        throw Exception('Adoption request not found');
      }
      
      final petId = requestDoc.data()?['petId'];
      
      // Update survey status
      await _firestore.collection('adoption_applications').doc(requestId).update({
        'surveyStatus': status,
        'surveyCompletedDate': FieldValue.serverTimestamp(),
        'surveyNotes': notes,
        'handoverStatus': status == 'approved' ? 'pending' : 'not_started',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update pet status based on survey approval/rejection
      if (petId != null && status == 'rejected') {
        // When survey is rejected, set pet status back to 'available'
        await _firestore.collection('pets').doc(petId).update({
          'adoptionStatus': 'available',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Pet status reverted to available due to survey rejection');
      }

      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Survey ${status == 'approved' ? 'approved' : 'rejected'} successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadAdoptionRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update survey: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateHandoverStatus({
    required String requestId,
    required String petId,
    String? notes,
  }) async {
    try {
      // Update handover status
      await _firestore.collection('adoption_applications').doc(requestId).update({
        'handoverStatus': 'completed',
        'handoverCompletedDate': FieldValue.serverTimestamp(),
        'handoverNotes': notes,
        'applicationStatus': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update pet status to adopted
      await _firestore.collection('pets').doc(petId).update({
        'adoptionStatus': 'adopted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Handover completed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadAdoptionRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete handover: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
