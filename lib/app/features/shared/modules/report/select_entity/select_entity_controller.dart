import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../models/enums.dart';

class SelectEntityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final entityType = EntityType.user.obs; // user or shelter
  final entities = <Map<String, dynamic>>[].obs;
  final filteredEntities = <Map<String, dynamic>>[].obs;
  
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Get entity type from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['entityType'] != null) {
      entityType.value = args['entityType'] as EntityType;
    }
    loadEntities();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load users or shelters based on entity type
  Future<void> loadEntities() async {
    try {
      isLoading.value = true;
      final currentUserId = _auth.currentUser?.uid;
      
      if (entityType.value == EntityType.user) {
        // Load users
        final snapshot = await _firestore.collection('users').get();
        entities.value = snapshot.docs
            .where((doc) => doc.id != currentUserId) // Exclude current user
            .map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['fullName'] ?? 'Unknown User',
            'email': data['email'] ?? '',
            'photoUrl': data['profilePhoto'],
            'city': data['city'],
          };
        }).toList();
      } else if (entityType.value == EntityType.shelter) {
        // Load shelters
        final snapshot = await _firestore.collection('shelters').get();
        entities.value = snapshot.docs
            .where((doc) => doc.id != currentUserId) // Exclude current shelter
            .map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['shelterName'] ?? 'Unknown Shelter',
            'email': data['shelterEmail'] ?? '',
            'photoUrl': data['shelterPhoto'],
            'city': data['city'],
          };
        }).toList();
      }
      
      filteredEntities.value = entities;
    } catch (e) {
      print('Error loading entities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter entities based on search query
  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (value.trim().isEmpty) {
      filteredEntities.value = entities;
    } else {
      final query = value.toLowerCase();
      filteredEntities.value = entities.where((entity) {
        final name = (entity['name'] as String).toLowerCase();
        final email = (entity['email'] as String).toLowerCase();
        final city = (entity['city'] as String?)?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query) || city.contains(query);
      }).toList();
    }
  }

  /// Navigate to report form with selected entity
  void selectEntity(Map<String, dynamic> entity) {
    Get.toNamed(
      '/report-form',
      arguments: {
        'reportedId': entity['id'],
        'reportedName': entity['name'],
        'entityType': entityType.value,
      },
    );
  }
}
