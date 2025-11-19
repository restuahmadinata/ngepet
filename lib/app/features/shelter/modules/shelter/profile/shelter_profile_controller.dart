import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../common/controllers/auth_controller.dart';

class ShelterProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final shelterName = ''.obs;
  final shelterPhoto = Rxn<String>();
  final city = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadShelterData();
  }

  Future<void> _loadShelterData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final shelterDoc = await _firestore.collection('shelters').doc(user.uid).get();
      if (shelterDoc.exists) {
        final data = shelterDoc.data();
        shelterName.value = data?['shelterName'] ?? 'Shelter';
        shelterPhoto.value = data?['shelterPhoto'];
        city.value = data?['city'] ?? '';
      }
    } catch (e) {
      print('Error loading shelter data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToFollowers() {
    Get.toNamed('/shelter/followers');
  }

  void goToEditProfile() {
    Get.toNamed('/shelter/edit-profile')?.then((_) => _loadShelterData());
  }

  Future<void> logout() async {
    await Get.find<AuthController>().signOut();
  }
}
