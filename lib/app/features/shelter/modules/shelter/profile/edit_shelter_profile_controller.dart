import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../config/imgbb_config.dart';

class EditShelterProfileController extends GetxController {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final shelterNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final isLoading = false.obs;
  final isSaving = false.obs;
  final profileImage = Rxn<File>();
  final profileImageUrl = Rxn<String>();
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();
  final address = ''.obs;
  final city = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadShelterData();
  }

  @override
  void onClose() {
    shelterNameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Load shelter data from Firestore
  Future<void> _loadShelterData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('shelters').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        
        shelterNameController.text = data['shelterName'] ?? '';
        descriptionController.text = data['description'] ?? '';
        phoneController.text = data['phone'] ?? '';
        address.value = data['address'] ?? '';
        city.value = data['city'] ?? '';
        
        profileImageUrl.value = data['profilePhotoUrl'];
        
        if (data['geoPoint'] != null) {
          final geoPoint = data['geoPoint'] as GeoPoint;
          latitude.value = geoPoint.latitude;
          longitude.value = geoPoint.longitude;
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load data: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick image from gallery
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        profileImage.value = File(image.path);
        Get.snackbar(
          "Success",
          "Shelter profile photo selected",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to select photo: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Upload profile image to ImgBB
  Future<String?> _uploadProfileImage() async {
    if (profileImage.value == null) return profileImageUrl.value;

    if (!ImgBBConfig.isConfigured) {
      Get.snackbar(
        "Error",
        "ImgBB API key not configured",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return profileImageUrl.value;
    }

    try {
      final bytes = await profileImage.value!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(ImgBBConfig.uploadEndpoint),
        body: {
          'key': ImgBBConfig.apiKey,
          'image': base64Image,
          'name': 'shelter_profile_${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['url'];
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      Get.snackbar(
        "Error",
        "Failed to upload photo: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return profileImageUrl.value;
    }
  }

  // Reverse geocoding - Convert coordinates to address using Nominatim (OpenStreetMap)
  Future<void> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1'
      );
      
      final response = await http.get(
        url,
        headers: {'User-Agent': 'ngepet-app/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract address components
        final addressData = data['address'] as Map<String, dynamic>?;
        
        if (addressData != null) {
          // Build full address
          List<String> addressParts = [];
          
          // Road/street
          if (addressData['road'] != null) {
            addressParts.add(addressData['road']);
          }
          
          // Suburb/neighbourhood
          if (addressData['suburb'] != null) {
            addressParts.add(addressData['suburb']);
          } else if (addressData['neighbourhood'] != null) {
            addressParts.add(addressData['neighbourhood']);
          }
          
          // City/town/village
          String? cityName;
          if (addressData['city'] != null) {
            cityName = addressData['city'];
          } else if (addressData['town'] != null) {
            cityName = addressData['town'];
          } else if (addressData['village'] != null) {
            cityName = addressData['village'];
          } else if (addressData['municipality'] != null) {
            cityName = addressData['municipality'];
          }
          
          // State/province
          if (addressData['state'] != null) {
            addressParts.add(addressData['state']);
          }
          
          // Country
          if (addressData['country'] != null) {
            addressParts.add(addressData['country']);
          }
          
          address.value = addressParts.join(', ');
          city.value = cityName ?? '';
          
          Get.snackbar(
            "Success",
            "Address filled automatically",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      Get.snackbar(
        "Info",
        "Cannot fill address automatically. Please fill manually if needed.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Update shelter profile
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Error",
        "Please complete the form correctly",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error",
        "You must login first",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;

      // Upload profile image if selected
      String? imageUrl = await _uploadProfileImage();

      // Prepare GeoPoint if coordinates are set
      GeoPoint? geoPoint;
      if (latitude.value != null && longitude.value != null) {
        geoPoint = GeoPoint(latitude.value!, longitude.value!);
      }

      // Update shelter data in Firestore
      await _firestore.collection('shelters').doc(user.uid).update({
        'shelterName': shelterNameController.text.trim(),
        'description': descriptionController.text.trim().isEmpty 
            ? null 
            : descriptionController.text.trim(),
        'phone': phoneController.text.trim(),
        'emailShelter': user.email,
        'address': address.value.isEmpty ? null : address.value,
        'city': city.value.isEmpty ? null : city.value,
        'profilePhotoUrl': imageUrl,
        'geoPoint': geoPoint,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      isSaving.value = false;

      // Navigate back to shelter home first
      Get.back();
      
      // Then show success notification
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        "Success",
        "Shelter profile has been updated",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isSaving.value = false;
      
      Get.snackbar(
        "Error",
        "Failed to update profile: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Validators
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[\d\s\+\-\(\)]+$').hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }
}
