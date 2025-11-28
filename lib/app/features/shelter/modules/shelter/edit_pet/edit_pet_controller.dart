import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../../config/imgbb_config.dart';
import '../../../../../models/enums.dart';

class EditPetController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final nameController = TextEditingController();
  // Breed selection
  final selectedBreed = Rxn<dynamic>(); // Will hold DogBreed, CatBreed, RabbitBreed, etc.
  final ageController = TextEditingController();
  final descriptionController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final selectedGender = 'Male'.obs;
  final selectedType = 'Dog'.obs;

  void onTypeChanged(String newType) {
    selectedType.value = newType;
    selectedBreed.value = null;
  }
  final selectedStatus = 'available'.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  
  // Image management
  final existingImageUrls = <String>[].obs; // URLs from Firestore
  final newImages = <File>[].obs; // Newly selected local files
  final removedImageUrls = <String>[].obs; // URLs marked for deletion

  // Pet ID
  String? petId;

  // Options
  final genderOptions = ['Male', 'Female'];
  final typeOptions = PetCategory.values.map((e) => e.value).toList();

  // Breed options (dynamic)
  List<String> get breedOptions {
    switch (selectedType.value) {
      case 'Dog':
        return DogBreed.allValues;
      case 'Cat':
        return CatBreed.allValues;
      case 'Rabbit':
        return RabbitBreed.allValues;
      case 'Bird':
        return BirdBreed.allValues;
      case 'Hamster':
        return HamsterBreed.allValues;
      case 'Guinea Pig':
        return GuineaPigBreed.allValues;
      case 'Fish':
        return FishBreed.allValues;
      case 'Turtle':
        return TurtleBreed.allValues;
      default:
        return ['Other'];
    }
  }
  final statusOptions = ['available', 'pending', 'adopted'];

  @override
  void onInit() {
    super.onInit();
    
    // Get petId from arguments
    if (Get.arguments != null) {
      petId = Get.arguments.toString();
      loadPetData();
    } else {
      print('Error: Pet ID not found');
      Get.back();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Load existing pet data from Firestore
  Future<void> loadPetData() async {
    if (petId == null) return;

    try {
      isLoading.value = true;

      final doc = await _firestore.collection('pets').doc(petId).get();

      if (!doc.exists) {
        print('Error: Pet not found');
        Get.back();
        return;
      }

      final data = doc.data()!;
      
      // Populate form fields
      nameController.text = data['petName']?.toString() ?? '';
      // Parse breed from string to enum
      final breedStr = data['breed']?.toString() ?? '';
      switch (selectedType.value) {
        case 'Dog':
          selectedBreed.value = DogBreed.fromString(breedStr);
          break;
        case 'Cat':
          selectedBreed.value = CatBreed.fromString(breedStr);
          break;
        case 'Rabbit':
          selectedBreed.value = RabbitBreed.fromString(breedStr);
          break;
        default:
          selectedBreed.value = null;
      }
      ageController.text = data['ageMonths']?.toString() ?? '';
      descriptionController.text = data['description']?.toString() ?? '';
      
      selectedGender.value = data['gender']?.toString() ?? 'Male';
      selectedType.value = data['category']?.toString() ?? 'Dog';
      selectedStatus.value = data['adoptionStatus']?.toString() ?? 'available';
      
      // Load existing images
      if (data['imageUrls'] != null && data['imageUrls'] is List) {
        existingImageUrls.value = (data['imageUrls'] as List)
            .map((e) => e.toString())
            .toList();
      }
    } catch (e) {
      print('Error loading pet data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick new images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      if (images.isNotEmpty) {
        newImages.addAll(images.map((image) => File(image.path)));
      }
    } catch (e) {
      print('Error selecting photos: $e');
    }
  }

  /// Remove existing image (mark for deletion)
  void removeExistingImage(String url) {
    existingImageUrls.remove(url);
    removedImageUrls.add(url);
  }

  /// Remove new image (before upload)
  void removeNewImage(int index) {
    newImages.removeAt(index);
  }

  /// Upload new images to ImgBB
  Future<List<String>> _uploadNewImages() async {
    List<String> uploadedUrls = [];
    
    if (!ImgBBConfig.isConfigured) {
      print('Error: ImgBB API key not configured');
      return uploadedUrls;
    }

    for (int i = 0; i < newImages.length; i++) {
      try {
        final File image = newImages[i];

        // Compress image before upload (70% quality, max 800px)
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          image.absolute.path,
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );

        if (compressedBytes == null) {
          print('Error: Failed to compress image $i');
          continue;
        }

        final base64Image = base64Encode(compressedBytes);
        
        print('Image $i: ${image.lengthSync()} bytes -> ${compressedBytes.length} bytes');

        final response = await http.post(
          Uri.parse(ImgBBConfig.uploadEndpoint),
          body: {
            'key': ImgBBConfig.apiKey,
            'image': base64Image,
            'name': 'pet_${petId}_${DateTime.now().millisecondsSinceEpoch}_$i',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final String imageUrl = data['data']['url'];
          uploadedUrls.add(imageUrl);
        } else {
          print('Error uploading image $i: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }
    
    return uploadedUrls;
  }

  /// Save changes to Firestore
  Future<void> saveChanges() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (petId == null) return;

    final user = _auth.currentUser;
    if (user == null) {
      print('Error: User not logged in');
      return;
    }

    try {
      isSaving.value = true;

      final age = int.tryParse(ageController.text.trim());
      if (age == null || age <= 0) {
        Get.snackbar(
          "Error",
          "Invalid age value",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Upload new images
      List<String> newUploadedUrls = [];
      if (newImages.isNotEmpty) {
        newUploadedUrls = await _uploadNewImages();
      }

      // Combine existing (not removed) and newly uploaded images
      final allImageUrls = [
        ...existingImageUrls,
        ...newUploadedUrls,
      ];

      // If no images at all, add placeholder
      if (allImageUrls.isEmpty) {
        allImageUrls.add('https://via.placeholder.com/300x300?text=${selectedType.value}');
      }

      // Update pet document
      await _firestore.collection('pets').doc(petId).update({
        'petName': nameController.text.trim(),
        'breed': selectedBreed.value?.value ?? 'Other',
        'ageMonths': age,
        'description': descriptionController.text.trim(),
        'gender': selectedGender.value,
        'category': selectedType.value,
        'adoptionStatus': selectedStatus.value,
        'imageUrls': allImageUrls,
        'updatedAt': Timestamp.now(),
      });

      // Navigate back to manage pets
      Get.back(result: true);
    } catch (e) {
      print('Error saving changes: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Validation methods
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateBreed(dynamic value) {
    if (value == null) {
      return 'Breed is required';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    // Accept only numeric values for months
    final ageValue = int.tryParse(value.trim());
    if (ageValue == null || ageValue <= 0) {
      return 'Please enter a valid number (example: 24 for 24 months)';
    }
    return null;
  }
}
