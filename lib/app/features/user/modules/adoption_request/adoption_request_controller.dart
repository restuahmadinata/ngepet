import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/adoption_request.dart';

class AdoptionRequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  
  // Form controllers
  final adoptionReasonController = TextEditingController();
  final petExperienceController = TextEditingController();
  final familyMembersController = TextEditingController();
  final environmentDescriptionController = TextEditingController();
  
  // Form selections
  final selectedResidenceStatus = 'own_house'.obs;
  final hasYard = false.obs;
  
  final isLoading = false.obs;
  
  // Pet data passed from previous screen
  late Map<String, dynamic> petData;
  
  @override
  void onInit() {
    super.onInit();
    petData = Get.arguments as Map<String, dynamic>;
  }
  
  @override
  void onClose() {
    adoptionReasonController.dispose();
    petExperienceController.dispose();
    familyMembersController.dispose();
    environmentDescriptionController.dispose();
    super.onClose();
  }
  
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
  
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
  
  Future<void> submitAdoptionRequest() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'You must be logged in to submit an adoption request',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      final petId = petData['petId'] ?? petData['id'] ?? '';
      final shelterId = petData['shelterId'] ?? '';
      
      print('🐾 Submitting adoption request:');
      print('   User ID: ${user.uid}');
      print('   Pet ID: $petId');
      print('   Shelter ID: $shelterId');
      
      if (petId.isEmpty || shelterId.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid pet data. Pet ID: $petId, Shelter ID: $shelterId',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Check if user already has a pending request for this pet
      final existingRequest = await _firestore
          .collection('adoption_applications')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: user.uid)
          .where('applicationStatus', whereIn: ['pending', 'approved'])
          .get();
      
      if (existingRequest.docs.isNotEmpty) {
        Get.snackbar(
          'Already Applied',
          'You have already submitted an adoption request for this pet',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      // Create adoption request
      final request = AdoptionRequest(
        applicationId: '', // Will be set by Firestore
        petId: petId,
        userId: user.uid,
        shelterId: shelterId,
        adoptionReason: adoptionReasonController.text.trim(),
        petExperience: petExperienceController.text.trim(),
        residenceStatus: selectedResidenceStatus.value,
        hasYard: hasYard.value,
        familyMembers: int.parse(familyMembersController.text.trim()),
        environmentDescription: environmentDescriptionController.text.trim(),
        applicationStatus: 'pending',
        requestStatus: 'pending',
        requestDate: DateTime.now(),
        surveyStatus: 'not_started',
        handoverStatus: 'not_started',
        applicationDate: DateTime.now(),
      );
      
      print('📝 Request data to be saved:');
      print(request.toMap());
      
      // Save to Firestore
      final docRef = await _firestore
          .collection('adoption_applications')
          .add(request.toMap());
      
      print('✅ Adoption request saved with ID: ${docRef.id}');
      
      // Show success and navigate back
      Get.back(); // Close adoption form
      Get.snackbar(
        'Success',
        'Adoption request submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e, stackTrace) {
      print('❌ Error submitting adoption request: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to submit adoption request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
