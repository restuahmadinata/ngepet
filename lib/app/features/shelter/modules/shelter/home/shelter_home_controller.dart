import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../common/controllers/auth_controller.dart';

class ShelterHomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final shelterName = ''.obs;
  final petCount = 0.obs;
  final eventCount = 0.obs;
  final adoptionRequestCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadShelterData();
    _loadStats();
  }

  @override
  void onReady() {
    super.onReady();
    // Reload data when page is ready (useful when returning from add pet/event)
    refreshData();
  }

  // Load shelter basic data
  Future<void> _loadShelterData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get shelter name from shelters collection
      final shelterDoc = await _firestore.collection('shelters').doc(user.uid).get();
      if (shelterDoc.exists) {
        final data = shelterDoc.data();
        shelterName.value = data?['shelterName'] ?? 'Shelter';
      }
    } catch (e) {
      print('Error loading shelter data: $e');
    }
  }

  // Load dashboard statistics
  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Count pets owned by this shelter
      final petsQuery = await _firestore
          .collection('pets')
          .where('shelterId', isEqualTo: user.uid)
          .get();
      petCount.value = petsQuery.docs.length;

      // Count events created by this shelter
      final eventsQuery = await _firestore
          .collection('events')
          .where('shelterId', isEqualTo: user.uid)
          .get();
      eventCount.value = eventsQuery.docs.length;

      // Count pending adoption requests for this shelter's pets
      final adoptionQuery = await _firestore
          .collection('adoption_requests')
          .where('shelterId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();
      adoptionRequestCount.value = adoptionQuery.docs.length;
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  // Navigation methods
  void goToManagePets() {
    // TODO: Implement manage pets page
    Get.snackbar("Info", "Fitur kelola hewan sedang dalam pengembangan");
  }

  void goToManageEvents() {
    // TODO: Implement manage events page
    Get.snackbar("Info", "Fitur kelola event sedang dalam pengembangan");
  }

  void goToAdoptionRequests() {
    // TODO: Implement adoption requests page
    Get.snackbar("Info", "Fitur pengajuan adopsi sedang dalam pengembangan");
  }

  void goToAddPet() {
    Get.toNamed('/shelter/add-pet');
  }

  void goToAddEvent() {
    Get.toNamed('/shelter/add-event');
  }

  // Logout
  Future<void> logout() async {
    await Get.find<AuthController>().signOut();
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([_loadShelterData(), _loadStats()]);
  }
}
