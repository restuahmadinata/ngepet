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
import '../../../../../routes/app_routes.dart';
import '../home/shelter_home_controller.dart';

class AddEventController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final isLoading = false.obs;
  final selectedImages = <File>[].obs;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }

  // Pick images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      if (images.isNotEmpty) {
        selectedImages.value = images.map((image) => File(image.path)).toList();
        Get.snackbar(
          "Success",
          "${images.length} photos selected",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to select photos: ${e.toString()}",
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
  Future<List<String>> _uploadImages(String eventId) async {
    List<String> imageUrls = [];

    // Check if API key is configured
    if (!ImgBBConfig.isConfigured) {
      Get.snackbar(
        "Error",
        "ImgBB API key not configured. Please check imgbb_config.dart file",
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

        // Upload to ImgBB
        final response = await http.post(
          Uri.parse(ImgBBConfig.uploadEndpoint),
          body: {
            'key': ImgBBConfig.apiKey,
            'image': base64Image,
            'name': 'event_${eventId}_$i',
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

  // Date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  // Time picker
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      selectedTime.value = picked;
      timeController.text = picked.format(context);
    }
  }

  // Submit event data
  Future<void> submitEvent() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        "Error",
        "Please select event date",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error",
        "You must login as a shelter first",
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
          "Shelter data not found. Please register as a shelter first.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final shelterData = shelterDoc.data();
      final verificationStatus = shelterData?['verificationStatus'];
      final shelterName = shelterData?['shelterName'] ?? 'Shelter';

      if (verificationStatus != 'approved') {
        Get.snackbar(
          "Error",
          "Your shelter is not verified yet. Status: $verificationStatus",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Combine date and time
      DateTime eventDateTime = selectedDate.value!;
      if (selectedTime.value != null) {
        eventDateTime = DateTime(
          selectedDate.value!.year,
          selectedDate.value!.month,
          selectedDate.value!.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );
      }

      // Add event to Firestore
      final docRef = await _firestore.collection('events').add({
        'eventTitle': titleController.text.trim(),
        'eventDescription': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'eventDate':
            '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}',
        'eventTime': selectedTime.value != null ? timeController.text : '',
        'dateTime': Timestamp.fromDate(eventDateTime),
        'shelterName': shelterName,
        'shelterId': user.uid,
        'imageUrls': [], // Will be updated after upload
        'eventStatus': 'upcoming',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Upload images if any
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages(docRef.id);

        // Update event document with image URLs
        await docRef.update({'imageUrls': imageUrls});
      } else {
        // Use placeholder if no images
        imageUrls = ['https://via.placeholder.com/400x200?text=Event'];
        await docRef.update({'imageUrls': imageUrls});
      }

      Get.snackbar(
        "Success",
        "Event '${titleController.text.trim()}' has been added",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

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
        "Failed to add event: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    dateController.clear();
    timeController.clear();
    selectedDate.value = null;
    selectedTime.value = null;
    selectedImages.clear();
  }

  // Validation methods
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Event title is required';
    }
    if (value.length < 5) {
      return 'Event title must be at least 5 characters';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Event description is required';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }
}
