import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../config/imgbb_config.dart';
import '../../../../../routes/app_routes.dart';
import '../home/shelter_home_controller.dart';

class AddPetController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final selectedGender = 'Jantan'.obs;
  final selectedType = 'Anjing'.obs;
  final isLoading = false.obs;
  final selectedImages = <File>[].obs;

  // Gender options
  final genderOptions = ['Jantan', 'Betina'];
  final typeOptions = ['Anjing', 'Kucing', 'Kelinci', 'Lainnya'];

  @override
  void onInit() {
    super.onInit();
    _loadShelterAddress();
  }

  @override
  void onClose() {
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load shelter address automatically
  Future<void> _loadShelterAddress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final shelterDoc = await _firestore
          .collection('shelters')
          .doc(user.uid)
          .get();

      if (shelterDoc.exists) {
        final shelterData = shelterDoc.data();
        final address = shelterData?['address'] ?? '';
        final city = shelterData?['city'] ?? '';
        
        // Set location from shelter address
        if (address.isNotEmpty) {
          locationController.text = address;
        } else if (city.isNotEmpty) {
          locationController.text = city;
        }
      }
    } catch (e) {
      print('Error loading shelter address: $e');
    }
  }

  // Pick images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      if (images.isNotEmpty) {
        selectedImages.value = images.map((image) => File(image.path)).toList();
        Get.snackbar(
          "Berhasil",
          "${images.length} foto dipilih",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memilih foto: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove image from selection
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // Upload images to ImgBB and save to subcollection photos
  Future<List<String>> _uploadImagesToSubcollection(String petId) async {
    List<String> uploadedUrls = [];
    
    // Check if API key is configured
    if (!ImgBBConfig.isConfigured) {
      Get.snackbar(
        "Error",
        "ImgBB API key belum dikonfigurasi. Silakan cek file imgbb_config.dart",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return uploadedUrls;
    }

    for (int i = 0; i < selectedImages.length; i++) {
      try {
        final File image = selectedImages[i];

        // Read image as base64
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Upload to ImgBB
        final response = await http.post(
          Uri.parse(ImgBBConfig.uploadEndpoint),
          body: {
            'key': ImgBBConfig.apiKey,
            'image': base64Image,
            'name': 'pet_${petId}_$i',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final String imageUrl = data['data']['url'];
          
          // Add to list
          uploadedUrls.add(imageUrl);
          
          // Save to subcollection
          await _firestore
              .collection('pets')
              .doc(petId)
              .collection('photos')
              .add({
            'url': imageUrl,
            'isPrimary': i == 0, // First image is primary
            'order': i,
            'uploadedAt': FieldValue.serverTimestamp(),
          });
          
          print('Debug - Image $i uploaded to subcollection: $imageUrl');
        } else {
          print(
            'Error uploading image $i: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }
    
    return uploadedUrls;
  }

  // Submit pet data
  Future<void> submitPet() async {
    print('Debug - submitPet called');

    if (!formKey.currentState!.validate()) {
      print('Debug - Form validation failed');
      return;
    }

    print('Debug - Form validation passed');
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error",
        "Anda harus login sebagai shelter terlebih dahulu",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get shelter information from shelters collection
      final shelterDoc = await _firestore
          .collection('shelters')
          .doc(user.uid)
          .get();

      if (!shelterDoc.exists) {
        Get.snackbar(
          "Error",
          "Data shelter tidak ditemukan. Silakan daftar sebagai shelter terlebih dahulu.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final shelterData = shelterDoc.data();
      final verificationStatus = shelterData?['verificationStatus'];

      print('Debug - Shelter UID: ${user.uid}');
      print('Debug - Verification Status: $verificationStatus');
      print('Debug - Shelter Data: $shelterData');

      if (verificationStatus != 'approved') {
        Get.snackbar(
          "Error",
          "Shelter Anda belum diverifikasi. Status: $verificationStatus",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final shelterName = shelterData?['shelterName'] ?? 'Shelter';

      // Add pet to Firestore (with imageUrls array - will be updated after upload)
      print('Debug - Adding pet to Firestore...');
      final docRef = await _firestore.collection('pets').add({
        'name': nameController.text.trim(),
        'breed': breedController.text.trim(),
        'age': ageController.text.trim(),
        'location': locationController.text.trim(),
        'description': descriptionController.text.trim(),
        'gender': selectedGender.value,
        'type': selectedType.value,
        'status': 'available',
        'shelterId': user.uid,
        'shelterName': shelterName,
        'imageUrls': [], // Initialize empty array, will be updated after upload
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      print('Debug - Pet added with ID: ${docRef.id}');

      // Upload images to subcollection and update imageUrls array
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        print('Debug - Uploading ${selectedImages.length} images to subcollection...');
        imageUrls = await _uploadImagesToSubcollection(docRef.id);
        
        // Update pet document with imageUrls array
        if (imageUrls.isNotEmpty) {
          await docRef.update({
            'imageUrls': imageUrls,
            'updatedAt': Timestamp.now(),
          });
          print('Debug - Updated pet document with ${imageUrls.length} image URLs');
        }
      } else {
        // Add placeholder photo
        final placeholderUrl = 'https://via.placeholder.com/300x300?text=${selectedType.value}';
        imageUrls = [placeholderUrl];
        
        // Add to subcollection
        await docRef.collection('photos').add({
          'url': placeholderUrl,
          'isPrimary': true,
          'order': 0,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
        
        // Update pet document with placeholder
        await docRef.update({
          'imageUrls': imageUrls,
          'updatedAt': Timestamp.now(),
        });
        print('Debug - Added placeholder image');
      }

      Get.snackbar(
        "Berhasil",
        "Hewan '${nameController.text.trim()}' berhasil ditambahkan ke daftar adopsi",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      print('Debug - Success message shown, clearing form and navigating to shelter home');
      
      // Clear form
      _clearForm();
      
      // Navigate back to shelter home and refresh data
      Get.offAllNamed(AppRoutes.shelterHome);
      
      // Refresh shelter home data
      try {
        final shelterHomeController = Get.find<ShelterHomeController>();
        await shelterHomeController.refreshData();
      } catch (e) {
        print('Debug - Could not refresh shelter home: $e');
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menambahkan hewan: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    nameController.clear();
    breedController.clear();
    ageController.clear();
    locationController.clear();
    descriptionController.clear();
    selectedGender.value = 'Jantan';
    selectedType.value = 'Anjing';
    selectedImages.clear();
  }

  // Validation methods
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Umur wajib diisi';
    }
    // Allow formats like "2 tahun", "6 bulan", etc.
    if (!RegExp(
      r'^.+(tahun|bulan|minggu).*$',
      caseSensitive: false,
    ).hasMatch(value)) {
      return 'Format umur tidak valid (contoh: 2 tahun, 6 bulan)';
    }
    return null;
  }
}
