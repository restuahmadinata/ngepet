import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../config/imgbb_config.dart';

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
  void onClose() {
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.onClose();
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

  // Upload images to ImgBB (GRATIS!)
  Future<List<String>> _uploadImages(String petId) async {
    List<String> imageUrls = [];

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
      return imageUrls;
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
          imageUrls.add(imageUrl);
          print('Debug - Image $i uploaded: $imageUrl');
        } else {
          print(
            'Error uploading image $i: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }

    return imageUrls;
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

      // Get shelter information and verify role
      final shelterDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!shelterDoc.exists) {
        Get.snackbar(
          "Error",
          "Data user tidak ditemukan di database",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final shelterData = shelterDoc.data();
      final userRole = shelterData?['role'];

      print('Debug - User UID: ${user.uid}');
      print('Debug - User Role: $userRole');
      print('Debug - Shelter Data: $shelterData');

      if (userRole != 'shelter') {
        Get.snackbar(
          "Error",
          "Akses ditolak. Hanya shelter yang dapat menambah hewan. Role Anda: $userRole",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final shelterName =
          shelterData?['shelterName'] ?? shelterData?['name'] ?? 'Shelter';

      // Add pet to Firestore
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
        'imageUrls': [], // Will be updated after upload
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      print('Debug - Pet added with ID: ${docRef.id}');

      // Upload images if any
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        print('Debug - Uploading ${selectedImages.length} images...');
        imageUrls = await _uploadImages(docRef.id);
        print('Debug - Images uploaded: ${imageUrls.length}');

        // Update pet document with image URLs
        await docRef.update({'imageUrls': imageUrls});
      } else {
        // Use placeholder if no images
        imageUrls = [
          'https://via.placeholder.com/300x300?text=${selectedType.value}',
        ];
        await docRef.update({'imageUrls': imageUrls});
      }

      Get.snackbar(
        "Berhasil",
        "Data hewan berhasil ditambahkan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('Debug - Success message shown, clearing form and navigating back');
      // Clear form and go back
      _clearForm();
      Get.back();
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
