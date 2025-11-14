import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../common/widgets/text_field.dart';
import '../../../../../common/widgets/button1.dart';
import '../../../../../common/widgets/location_picker.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && 
            controller.fullNameController.text.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Section
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: controller.pickProfileImage,
                          child: Stack(
                            children: [
                              Obx(() {
                                // Show selected image or existing profile photo
                                if (controller.profileImage.value != null) {
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundImage: FileImage(
                                      controller.profileImage.value!,
                                    ),
                                  );
                                } else if (controller.profileImageUrl.value != null) {
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(
                                      controller.profileImageUrl.value!,
                                    ),
                                  );
                                } else {
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.neutral300,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.neutral600,
                                    ),
                                  );
                                }
                              }),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change photo',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: controller.fullNameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: controller.phoneNumberController,
                    labelText: 'Phone Number',
                    hintText: 'Example: 08123456789',
                    prefixIcon: const Icon(Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhone,
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  Text(
                    'Gender',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedGender.value,
                            hint: Text(
                              'Select Gender',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.neutral600,
                              ),
                            ),
                            isExpanded: true,
                            items: controller.genderOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  controller.getGenderDisplay(value),
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              controller.selectedGender.value = newValue;
                            },
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Birth Date
                  Text(
                    'Birth Date',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => GestureDetector(
                        onTap: () => controller.selectBirthDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: AppColors.neutral600),
                              const SizedBox(width: 16),
                              Text(
                                controller.selectedDate.value != null
                                    ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                                    : 'Select Birth Date',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: controller.selectedDate.value != null
                                      ? Colors.black
                                      : AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Location Section
                  Text(
                    'Location',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Display address if available
                  Obx(() {
                    if (controller.address.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, 
                                    color: Colors.green.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selected Address:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.address.value,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.neutral700,
                              ),
                            ),
                            if (controller.city.value.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'City: ${controller.city.value}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.neutral600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            if (controller.latitude.value != null && 
                                controller.longitude.value != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Coordinates: ${controller.latitude.value!.toStringAsFixed(6)}, ${controller.longitude.value!.toStringAsFixed(6)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Map picker button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        GeoPoint? initialLocation;
                        if (controller.latitude.value != null && 
                            controller.longitude.value != null) {
                          initialLocation = GeoPoint(
                            controller.latitude.value!,
                            controller.longitude.value!,
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
                              'Location updated successfully',
                              snackPosition: SnackPosition.BOTTOM,
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
                              'Location saved but address lookup failed. You can enter the address manually.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: Text(
                        controller.address.value.isEmpty 
                            ? 'Select Location on Map'
                            : 'Change Location',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 32),

                  // Save Button
                  Obx(() => Button1(
                    text: 'SAVE CHANGES',
                    onPressed: controller.updateProfile,
                    isLoading: controller.isSaving.value,
                  )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
