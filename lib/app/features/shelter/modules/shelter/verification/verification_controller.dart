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

class VerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final shelterNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();
  final legalNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;
  final verificationStatus = Rx<String?>(null);
  final rejectionReason = Rx<String?>(null);
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isExistingUser = false.obs;
  
  // Location data
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();
  final city = ''.obs;
  final address = ''.obs; // Add reactive address variable
  
  // Profile photo
  final profileImage = Rxn<File>();
  final profileImageUrl = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    final user = _auth.currentUser;
    isExistingUser.value = user != null;
    
    if (user != null) {
      emailController.text = user.email ?? '';
      checkVerificationStatus();
    }
  }

  @override
  void onClose() {
    shelterNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    legalNumberController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Check current verification status
  Future<void> checkVerificationStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check in shelters collection first
      final shelterDoc = await _firestore.collection('shelters').doc(user.uid).get();
      
      if (shelterDoc.exists) {
        final data = shelterDoc.data()!;
        verificationStatus.value = data['verificationStatus'];
        
        if (verificationStatus.value == 'rejected') {
          rejectionReason.value = data['rejectionReason'];
        } else if (verificationStatus.value == 'pending') {
          // Load existing data
          shelterNameController.text = data['shelterName'] ?? '';
          addressController.text = data['address'] ?? '';
          address.value = data['address'] ?? ''; // Load into reactive variable
          phoneController.text = data['shelterPhone'] ?? '';
          legalNumberController.text = data['legalNumber'] ?? '';
          descriptionController.text = data['description'] ?? '';
          profileImageUrl.value = data['shelterPhoto'];
          city.value = data['city'] ?? '';
          
          // Load location if available
          if (data['geoPoint'] != null) {
            final geoPoint = data['geoPoint'] as GeoPoint;
            latitude.value = geoPoint.latitude;
            longitude.value = geoPoint.longitude;
          }
        }
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }
  }

  // Submit verification request
  Future<void> submitVerification() async {
    print('🔍 DEBUG: submitVerification called');
    
    if (!formKey.currentState!.validate()) {
      print('❌ DEBUG: Form validation failed');
      Get.snackbar(
        "Validation Error",
        "Please fill all required fields correctly",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    print('✅ DEBUG: Form validation passed');

    // Validate location is selected
    if (latitude.value == null || longitude.value == null) {
      print('❌ DEBUG: Location not selected');
      Get.snackbar(
        "Error",
        "Shelter location must be selected. Please select location on the map.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    print('✅ DEBUG: Location validated - Lat: ${latitude.value}, Lng: ${longitude.value}');    
    print('✅ DEBUG: Location validated - Lat: ${latitude.value}, Lng: ${longitude.value}');

    try {
      print('🔄 DEBUG: Starting submission process...');
      isLoading.value = true;
      
      User? user = _auth.currentUser;
      print('👤 DEBUG: Current user: ${user?.email ?? "Not logged in"}');
      
      // If user is not logged in, create a new account first
      if (user == null) {
        print('🆕 DEBUG: Creating new user account...');
        // Validate password fields for new registration
        if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
          print('❌ DEBUG: Password fields empty');
          Get.snackbar(
            "Error",
            "Password and confirm password are required",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
        
        if (passwordController.text != confirmPasswordController.text) {
          print('❌ DEBUG: Passwords do not match');
          Get.snackbar(
            "Error",
            "Password and confirm password do not match",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
        
        // Create new Firebase Auth account
        try {
          print('🔐 DEBUG: Creating Firebase Auth account...');
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
          
          user = userCredential.user;
          print('✅ DEBUG: Firebase Auth account created - UID: ${user?.uid}');
        } on FirebaseAuthException catch (e) {
          print('❌ DEBUG: Firebase Auth error: ${e.code} - ${e.message}');
          String msg = e.message ?? 'An error occurred';
          if (e.code == 'email-already-in-use') {
            msg = 'Email already registered. Please login first.';
          } else if (e.code == 'weak-password') {
            msg = 'Password is too weak. Minimum 6 characters.';
          }
          Get.snackbar(
            "Registration Failed",
            msg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      }
      
      if (user == null) {
        print('❌ DEBUG: User is still null after auth check');
        Get.snackbar(
          "Error",
          "Failed to create account. Please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      print('📸 DEBUG: Uploading profile photo...');
      // Upload profile photo if selected
      String? photoUrl = await _uploadProfileImage();
      print('📸 DEBUG: Photo URL: ${photoUrl ?? "No photo"}');

      // Prepare GeoPoint if coordinates are set
      GeoPoint? geoPoint;
      if (latitude.value != null && longitude.value != null) {
        geoPoint = GeoPoint(latitude.value!, longitude.value!);
        print('📍 DEBUG: GeoPoint created: ${geoPoint.latitude}, ${geoPoint.longitude}');
      }

      print('💾 DEBUG: Saving to Firestore...');
      // Create or update shelter document in shelters collection
      await _firestore.collection('shelters').doc(user.uid).set({
        'shelterId': user.uid,
        'uid': user.uid,
        'shelterEmail': user.email,
        'emailShelter': user.email,
        'shelterName': shelterNameController.text.trim(),
        'address': addressController.text.trim(),
        'city': city.value.isEmpty ? null : city.value,
        'geoPoint': geoPoint,
        'legalNumber': legalNumberController.text.trim(),
        'shelterPhone': phoneController.text.trim(),
        'description': descriptionController.text.trim(),
        'shelterPhoto': photoUrl,
        'verificationStatus': 'pending',
        'isVerified': false,
        'submittedAt': FieldValue.serverTimestamp(),
        'verificationDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'rejectionReason': FieldValue.delete(), // Delete previous rejection reason if any
      }, SetOptions(merge: true));

      print('✅ DEBUG: Successfully saved to Firestore');
      
      Get.snackbar(
        "Successfully Submitted",
        "Your shelter verification request has been sent and will be processed within 1-3 business days",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Update local state
      verificationStatus.value = 'pending';
      rejectionReason.value = null;
      isExistingUser.value = true;

      print('🔄 DEBUG: Reloading verification status...');
      // Reload the page to show status
      await Future.delayed(const Duration(seconds: 1));
      checkVerificationStatus();
      
    } catch (e) {
      print('❌ DEBUG: Error during submission: $e');
      print('❌ DEBUG: Stack trace: ${StackTrace.current}');
      Get.snackbar(
        "Error",
        "Failed to submit request: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      print('🏁 DEBUG: Submission process complete');
      isLoading.value = false;
    }
  }

  // Pick profile image from gallery
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
        snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return profileImageUrl.value;
    }
  }

  // Reverse geocoding - Convert coordinates to address using Nominatim (OpenStreetMap)
  Future<void> reverseGeocode(double lat, double lng) async {
    print('🗺️ DEBUG: Starting reverse geocode for: $lat, $lng');
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1'
      );
      
      print('🌐 DEBUG: Fetching address from Nominatim...');
      final response = await http.get(
        url,
        headers: {'User-Agent': 'ngepet-app/1.0'},
      ).timeout(const Duration(seconds: 10));

      print('📡 DEBUG: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📍 DEBUG: Address data received: ${data['display_name']}');
        
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
          
          addressController.text = addressParts.join(', ');
          address.value = addressParts.join(', '); // Update reactive variable
          city.value = cityName ?? '';
          
          print('✅ DEBUG: Address filled: ${addressController.text}');
          print('✅ DEBUG: City: ${city.value}');
        } else {
          throw Exception('No address data in response');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ DEBUG: Error reverse geocoding: $e');
      // Set fallback values
      addressController.text = 'Location selected';
      address.value = 'Location selected';
      city.value = '';
      // Rethrow to let caller handle the error
      rethrow;
    }
  }

  // Validation methods
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }

  // Navigation method
  void goToShelterHome() {
    Get.offAllNamed(AppRoutes.shelterHome);
  }

  void backToStarter() {
    Get.offAllNamed(AppRoutes.starter);
  }
}
