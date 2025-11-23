import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils/image_debug_helper.dart';

class ManagePetsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final isLoading = true.obs;
  final pets = <Map<String, dynamic>>[].obs;
  final filteredPets = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final deletingPetId = ''.obs; // Track which pet is being deleted

  @override
  void onInit() {
    super.onInit();
    loadPets();
  }

  /// Load all pets created by this shelter
  Future<void> loadPets() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user == null) {
        return;
      }

      final querySnapshot = await _firestore
          .collection('pets')
          .where('shelterId', isEqualTo: user.uid)
          .where('adoptionStatus', whereIn: ['available', 'pending'])
          .orderBy('createdAt', descending: true)
          .get();

      pets.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'petId': doc.id,
          ...data,
        };
      }).toList();

      filteredPets.value = pets;
    } catch (e) {
      print('Error loading pets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search pets by name
  void searchPets(String query) {
    searchQuery.value = query.toLowerCase();
    
    if (query.isEmpty) {
      filteredPets.value = pets;
    } else {
      filteredPets.value = pets.where((pet) {
        final name = (pet['petName'] ?? '').toString().toLowerCase();
        final breed = (pet['breed'] ?? '').toString().toLowerCase();
        final category = (pet['category'] ?? '').toString().toLowerCase();
        
        return name.contains(searchQuery.value) ||
               breed.contains(searchQuery.value) ||
               category.contains(searchQuery.value);
      }).toList();
    }
  }

  /// Navigate to edit pet page
  void editPet(String petId) async {
    final result = await Get.toNamed(
      AppRoutes.shelterEditPet,
      arguments: petId,
    );
    
    // Refresh list if edit was successful
    if (result == true) {
      await loadPets();
    }
  }

  /// Delete pet directly without confirmation
  Future<void> deletePet(String petId, String petName) async {
    await _performDelete(petId, petName);
  }

  /// Perform the actual deletion
  Future<void> _performDelete(String petId, String petName) async {
    try {
      // Set deleting state
      deletingPetId.value = petId;

      // Delete pet document
      await _firestore.collection('pets').doc(petId).delete();

      // Delete photos subcollection (if exists)
      try {
        final photosSnapshot = await _firestore
            .collection('pets')
            .doc(petId)
            .collection('photos')
            .get();
        
        for (var doc in photosSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error deleting photos: $e');
      }

      // Reload pets
      await loadPets();
    } catch (e) {
      print('Error deleting pet: $e');
    } finally {
      // Clear deleting state
      deletingPetId.value = '';
    }
  }

  /// Navigate to add new pet
  void addNewPet() {
    Get.toNamed(AppRoutes.shelterAddPet);
  }

  /// Refresh pets list
  Future<void> refreshPets() async {
    await loadPets();
  }

  /// Debug image loading issues
  Future<void> debugImages() async {
    print('🔍 Starting image debug...');
    await ImageDebugHelper.debugAllPets();
  }

  /// Fix image structure in database
  Future<void> fixImageStructure() async {
    print('🔧 Fixing image structure...');
    await ImageDebugHelper.fixAllPetsImageStructure();
    await loadPets(); // Reload after fix
    print('✅ Fix complete, reloaded pets');
  }
}
