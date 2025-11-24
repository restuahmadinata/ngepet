import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../common/widgets/text_field.dart';
import '../../../../../common/widgets/button1.dart';
import '../../../../../common/widgets/button2.dart';
import '../../../../../common/widgets/location_picker.dart';
import '../../../../../theme/app_colors.dart';
import 'add_event_controller.dart';

class AddEventView extends GetView<AddEventController> {
  const AddEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Event',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, color: Colors.purple[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Create a community event to encourage adoption or other activities.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.purple[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image picker section
                  Text(
                    'Event Photos',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Selected images preview
                  Obx(
                    () => controller.selectedImages.isEmpty
                        ? GestureDetector(
                            onTap: () => controller.pickImages(),
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.neutral400,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[50],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: AppColors.neutral500,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select Event Photos',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.neutral600,
                                    ),
                                  ),
                                  Text(
                                    'You can select multiple photos',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 150,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: index == 0
                                                  ? AppColors.primary
                                                  : AppColors.neutral300,
                                              width: index == 0 ? 2 : 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              controller.selectedImages[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        if (index == 0)
                                          Positioned(
                                            top: 4,
                                            left: 4,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Thumbnail',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 4,
                                          right: 12,
                                          child: GestureDetector(
                                            onTap: () =>
                                                controller.removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${controller.selectedImages.length} photos selected. The first photo will be the thumbnail.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.neutral600,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => controller.pickImages(),
                                    icon: const Icon(
                                      Icons.add_photo_alternate,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Select More',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Event title
                  CustomTextField(
                    controller: controller.titleController,
                    labelText: 'Event Title *',
                    hintText: 'Example: Adoption Day Jakarta',
                    prefixIcon: const Icon(Icons.title),
                    validator: controller.validateTitle,
                  ),
                  const SizedBox(height: 16),

                  // Event description
                  CustomTextField(
                    controller: controller.descriptionController,
                    labelText: 'Event Description *',
                    hintText:
                        'Explain event details, purpose, and other important information',
                    prefixIcon: const Icon(Icons.description),
                    validator: controller.validateDescription,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Event location
                  Obx(() => Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        GeoPoint? initialLocation;
                        if (controller.latitude.value != 0.0 && controller.longitude.value != 0.0) {
                          initialLocation = GeoPoint(
                            controller.latitude.value,
                            controller.longitude.value,
                          );
                        }

                        final result = await Get.to(() => LocationPickerView(
                          initialLocation: initialLocation,
                        ));

                        if (result != null && result is GeoPoint) {
                          controller.latitude.value = result.latitude;
                          controller.longitude.value = result.longitude;

                          // Show loading indicator while reverse geocoding
                          Get.dialog(
                            const Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Getting address...'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            barrierDismissible: false,
                          );

                          // Reverse geocode to get address
                          try {
                            await controller.reverseGeocode(
                              result.latitude,
                              result.longitude,
                            );

                            // Close loading dialog
                            Get.back();

                            // Show success message
                            Get.snackbar(
                              'Success',
                              'Location selected successfully',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          } catch (e) {
                            // Close loading dialog
                            Get.back();

                            // Show error but keep the coordinates
                            Get.snackbar(
                              'Warning',
                              'Location saved but address lookup failed. You can try again.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.map, color: AppColors.neutral600),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          controller.address.value.isEmpty
                              ? 'Select Location on Map *'
                              : controller.address.value,
                          style: GoogleFonts.poppins(
                            color: controller.address.value.isEmpty
                                ? AppColors.neutral500
                                : Colors.black,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),

                  // Event date
                  CustomTextField(
                    controller: controller.dateController,
                    labelText: 'Event Date *',
                    hintText: 'Select event date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    readOnly: true,
                    onTap: () => controller.selectDate(context),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Event time (optional)
                  CustomTextField(
                    controller: controller.timeController,
                    labelText: 'Event Time (Optional)',
                    hintText: 'Select event time',
                    prefixIcon: const Icon(Icons.access_time),
                    readOnly: true,
                    onTap: () => controller.selectTime(context),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  Obx(() => Button1(
                    text: 'Create Event',
                    onPressed: () => controller.submitEvent(),
                    isLoading: controller.isLoading.value,
                  )),
                  const SizedBox(height: 16),

                  // Cancel button
                  Button2(
                    text: 'Cancel',
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
