import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  var currentIndex = 2.obs; // Default to Home (index 2)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Location shown below greeting on the Home app bar
  final userLocation = ''.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserLocation();
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
