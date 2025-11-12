import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../config/imgbb_config.dart';
import '../../../../../models/user.dart' as app_user;

class EditProfileController extends GetxController {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final isLoading = false.obs;
  final isSaving = false.obs;
  final selectedGender = Rxn<String>();
  final selectedDate = Rxn<DateTime>();
  final profileImage = Rxn<File>();
  final profileImageUrl = Rxn<String>();
  final latitude = Rxn<double>();
  final longitude = Rxn<double>();
  final address = ''.obs;
  final city = ''.obs;

  final genderOptions = ['male', 'female', 'other'];

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final userData = app_user.User.fromFirestore(doc);
        
        fullNameController.text = userData.namaLengkap;
        phoneNumberController.text = userData.noTelepon ?? '';
        address.value = userData.alamat ?? '';
        city.value = userData.kota ?? '';
        
        selectedGender.value = userData.jenisKelamin;
        selectedDate.value = userData.tanggalLahir;
        profileImageUrl.value = userData.fotoProfil;
        
        // Load latitude and longitude if available
        final data = doc.data();
        if (data != null) {
          if (data['latitude'] != null) {
            latitude.value = (data['latitude'] as num).toDouble();
          }
          if (data['longitude'] != null) {
            longitude.value = (data['longitude'] as num).toDouble();
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat data: ${e.toString()}",
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
          "Berhasil",
          "Foto profil dipilih",
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

  // Select birth date
  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orange,
            colorScheme: const ColorScheme.light(primary: Colors.orange),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // Upload profile image to ImgBB
  Future<String?> _uploadProfileImage() async {
    if (profileImage.value == null) return profileImageUrl.value;

    if (!ImgBBConfig.isConfigured) {
      Get.snackbar(
        "Error",
        "ImgBB API key belum dikonfigurasi",
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
          'name': 'profile_${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}',
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
        "Gagal upload foto: ${e.toString()}",
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
            "Berhasil",
            "Alamat berhasil diisi otomatis",
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
        "Tidak dapat mengisi alamat otomatis. Silakan isi manual jika diperlukan.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Update profile
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Error",
        "Mohon lengkapi form dengan benar",
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
        "Anda harus login terlebih dahulu",
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

      // Update user data in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'namaLengkap': fullNameController.text.trim(),
        'noTelepon': phoneNumberController.text.trim().isEmpty 
            ? null 
            : phoneNumberController.text.trim(),
        'alamat': address.value.isEmpty ? null : address.value,
        'kota': city.value.isEmpty ? null : city.value,
        'latitude': latitude.value,
        'longitude': longitude.value,
        'jenisKelamin': selectedGender.value,
        'tanggalLahir': selectedDate.value != null 
            ? Timestamp.fromDate(selectedDate.value!) 
            : null,
        'fotoProfil': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      isSaving.value = false;

      // Navigate back to profile page first
      Get.back();
      
      // Then show success notification
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        "Berhasil",
        "Profil berhasil diperbarui",
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
        "Gagal memperbarui profil: ${e.toString()}",
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
      return 'Field ini wajib diisi';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (!RegExp(r'^[\d\s\+\-\(\)]+$').hasMatch(value)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  // Format display for gender
  String getGenderDisplay(String gender) {
    switch (gender) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      case 'other':
        return 'Lainnya';
      default:
        return gender;
    }
  }
}
