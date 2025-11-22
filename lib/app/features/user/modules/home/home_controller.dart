import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../common/controllers/search_controller.dart' as search;

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Location shown below greeting on the Home app bar
  final userLocation = ''.obs;
  
  // Search functionality for home page
  final searchController = Get.put(search.SearchController(), tag: 'home');
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserLocation();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchController.updateSearchQuery(value);
    if (value.trim().isNotEmpty) {
      searchController.searchAll(); // Search both pets and events
    }
  }

  Future<void> _loadUserLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Prefer city for short display; fallback to address
        final city = (data['city'] as String?)?.trim();
        final address = (data['address'] as String?)?.trim();
        if (city != null && city.isNotEmpty) {
          userLocation.value = city;
        } else if (address != null && address.isNotEmpty) {
          userLocation.value = address;
        } else {
          userLocation.value = 'Location not set';
        }
      }
    } catch (e) {
      print('Error loading user location: $e');
    }
  }
}
