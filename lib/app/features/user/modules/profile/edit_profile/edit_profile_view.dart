import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../common/widgets/lottie_loading.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/back-icon.svg',
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            width: 24,
            height: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value && 
            controller.fullNameController.text.isEmpty) {
          return const Center(child: LottieLoading());
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
                          child: Obx(() {
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
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
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
                                  value,
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
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.transparent,
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

                  // Location
                  Obx(() => Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
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
                                      LottieLoading(width: 80, height: 80),
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
                      icon: const Icon(Icons.map, color: Colors.black),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          controller.address.value.isEmpty ? 'Select Location on Map' : controller.address.value,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: controller.address.value.isEmpty ? AppColors.neutral500 : Colors.black,
                            fontWeight: FontWeight.w400,
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
