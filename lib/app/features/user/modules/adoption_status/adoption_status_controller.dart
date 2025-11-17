import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionStatusController extends GetxController {
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

      print('🔍 Loading adoption requests for user: ${user.uid}');

      // Get all adoption requests for current user
      // Remove orderBy to avoid index issues - we'll sort in memory
      final querySnapshot = await _firestore
          .collection('adoption_applications')
          .where('userId', isEqualTo: user.uid)
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

        // Fetch shelter details
        if (data['shelterId'] != null) {
          try {
            final shelterDoc = await _firestore
                .collection('shelters')
                .doc(data['shelterId'])
                .get();
            if (shelterDoc.exists) {
              data['shelterData'] = shelterDoc.data();
              print('✅ Shelter data loaded: ${shelterDoc.data()?['shelterName']}');
            } else {
              print('⚠️ Shelter not found: ${data['shelterId']}');
            }
          } catch (e) {
            print('❌ Error loading shelter: $e');
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

  void viewRequestDetail(Map<String, dynamic> request) {
    // Navigate to detailed view (we'll create this next)
    Get.toNamed('/adoption-detail', arguments: request);
  }
}
