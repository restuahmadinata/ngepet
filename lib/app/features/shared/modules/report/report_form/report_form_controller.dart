import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../../models/enums.dart';
import '../../../../../services/report_service.dart';
import '../../../../../config/imgbb_config.dart';
import '../report_timeline/report_timeline_view.dart';

class ReportFormController extends GetxController {
  final ReportService _reportService = ReportService();
  final ImagePicker _picker = ImagePicker();
  
  final isLoading = false.obs;
  final reportedId = ''.obs;
  final reportedName = ''.obs;
  final entityType = EntityType.user.obs;
  final selectedViolationCategory = Rxn<ViolationCategory>();
  final evidenceImages = <File>[].obs;
  
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      reportedId.value = args['reportedId'] ?? '';
      reportedName.value = args['reportedName'] ?? '';
      entityType.value = args['entityType'] ?? EntityType.user;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  /// Pick images from gallery
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        evidenceImages.addAll(images.map((xFile) => File(xFile.path)));
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        evidenceImages.add(File(image.path));
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  /// Remove image at index
  void removeImage(int index) {
    evidenceImages.removeAt(index);
  }

  /// Upload images to ImgBB
  Future<List<String>> _uploadEvidenceImages() async {
    if (evidenceImages.isEmpty) return [];

    List<String> imageUrls = [];

    for (var imageFile in evidenceImages) {
      try {
        // Compress image
        final compressedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 70,
        );

        if (compressedImage == null) continue;

        // Convert to base64
        final base64Image = base64Encode(compressedImage);

        // Upload to ImgBB
        final response = await http.post(
          Uri.parse(ImgBBConfig.uploadEndpoint),
          body: {
            'key': ImgBBConfig.apiKey,
            'image': base64Image,
          },
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final imageUrl = jsonResponse['data']['url'];
          imageUrls.add(imageUrl);
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  /// Submit the report
  Future<void> submitReport() async {
    if (!formKey.currentState!.validate()) return;
    
    if (selectedViolationCategory.value == null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please select a violation category.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Upload evidence images first
      List<String> evidenceUrls = [];
      if (evidenceImages.isNotEmpty) {
        evidenceUrls = await _uploadEvidenceImages();
      }

      final reportId = await _reportService.submitReport(
        reportedId: reportedId.value,
        entityType: entityType.value,
        violationCategory: selectedViolationCategory.value!,
        reportDescription: descriptionController.text.trim(),
        incidentLocation: locationController.text.trim().isEmpty 
            ? null 
            : locationController.text.trim(),
        evidenceAttachments: evidenceUrls.isNotEmpty ? evidenceUrls : null,
      );

      if (reportId != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Report Submitted'),
            content: const Text(
              'Your report has been submitted successfully. Our admin team will review it soon.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  // Navigate to timeline with new report
                  Get.off(() => ReportTimelineView(), arguments: {
                    'reportId': reportId,
                    'entityType': entityType.value,
                    'reportedId': reportedId.value,
                    'reportedName': reportedName.value,
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Failed to submit report. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error submitting report: $e');
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
