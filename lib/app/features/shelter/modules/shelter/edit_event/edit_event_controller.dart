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

class EditEventController extends GetxController {
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
  final selectedStatus = 'upcoming'.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  
  // Image management
  final existingImageUrls = <String>[].obs;
  final newImages = <File>[].obs;
  final removedImageUrls = <String>[].obs;

  // Event ID
  String? eventId;

  // Options
  final statusOptions = ['upcoming', 'ongoing', 'completed', 'cancelled'];

  @override
  void onInit() {
    super.onInit();
    
    // Get eventId from arguments
    if (Get.arguments != null) {
      eventId = Get.arguments.toString();
      loadEventData();
    } else {
      print('Error: Event ID not found');
      Get.back();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }

  /// Load existing event data from Firestore
  Future<void> loadEventData() async {
    if (eventId == null) return;

    try {
      isLoading.value = true;

      final doc = await _firestore.collection('events').doc(eventId).get();

      if (!doc.exists) {
        print('Error: Event not found');
        Get.back();
        return;
      }

      final data = doc.data()!;
      
      // Populate form fields
      titleController.text = data['eventTitle']?.toString() ?? '';
      descriptionController.text = data['eventDescription']?.toString() ?? '';
      locationController.text = data['location']?.toString() ?? '';
      dateController.text = data['eventDate']?.toString() ?? '';
      timeController.text = data['eventTime']?.toString() ?? '';
      
      selectedStatus.value = data['eventStatus']?.toString() ?? 'upcoming';
      
      // Parse date if available
      if (data['eventDate'] != null) {
        try {
          final dateParts = data['eventDate'].toString().split('/');
          if (dateParts.length == 3) {
            selectedDate.value = DateTime(
              int.parse(dateParts[2]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[0]), // day
            );
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
      
      // Load existing images
      if (data['imageUrls'] != null && data['imageUrls'] is List) {
        existingImageUrls.value = (data['imageUrls'] as List)
            .map((e) => e.toString())
            .toList();
      }
    } catch (e) {
      print('Error loading event data: $e');
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

  /// Remove existing image
  void removeExistingImage(String url) {
    existingImageUrls.remove(url);
    removedImageUrls.add(url);
  }

  /// Remove new image
  void removeNewImage(int index) {
    newImages.removeAt(index);
  }

  /// Date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  /// Time picker
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

        // Compress image before upload (70% quality)
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
            'name': 'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}_$i',
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

    if (selectedDate.value == null) {
      print('Error: Event date not selected');
      return;
    }

    if (eventId == null) return;

    final user = _auth.currentUser;
    if (user == null) {
      print('Error: User not logged in');
      return;
    }

    try {
      isSaving.value = true;

      // Upload new images
      List<String> newUploadedUrls = [];
      if (newImages.isNotEmpty) {
        newUploadedUrls = await _uploadNewImages();
      }

      // Combine existing and newly uploaded images
      final allImageUrls = [
        ...existingImageUrls,
        ...newUploadedUrls,
      ];

      // If no images, add placeholder
      if (allImageUrls.isEmpty) {
        allImageUrls.add('https://via.placeholder.com/400x200?text=Event');
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

      // Update event document
      await _firestore.collection('events').doc(eventId).update({
        'eventTitle': titleController.text.trim(),
        'eventDescription': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'eventDate': dateController.text,
        'eventTime': timeController.text,
        'dateTime': Timestamp.fromDate(eventDateTime),
        'eventStatus': selectedStatus.value,
        'imageUrls': allImageUrls,
        'updatedAt': Timestamp.now(),
      });

      // Navigate back to manage events
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
