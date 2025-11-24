import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../common/widgets/text_field.dart';
import '../../../../../common/widgets/button1.dart';
import '../../../../../common/widgets/button2.dart';
import '../../../../../common/widgets/location_picker.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../common/widgets/lottie_loading.dart';
import 'verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shelter Verification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        // Show approved notification if status is approved
        if (controller.verificationStatus.value == 'approved') {
          return _buildApprovedNotification();
        }

        // Show rejection notification if status is rejected
        if (controller.verificationStatus.value == 'rejected') {
          return _buildRejectionNotification();
        }

        // Show pending status if already submitted
        if (controller.verificationStatus.value == 'pending') {
          return _buildPendingStatus();
        }

        // Show form for new submission
        return _buildVerificationForm();
      }),
    );
  }

  Widget _buildApprovedNotification() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Congratulations!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Application Accepted',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your shelter verification has been approved by admin. You can now access the shelter dashboard.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.green[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.goToShelterHome(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.dashboard, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Go to Shelter Dashboard',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => controller.backToStarter(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.neutral400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionNotification() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Application Rejected',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.rejectionReason.value ?? 'No reason provided',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'You can reapply for verification after correcting the data',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.verificationStatus.value = null;
                  controller.rejectionReason.value = null;
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Reapply',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => controller.backToStarter(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.neutral400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingStatus() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending_actions,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Application Being Processed',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  'Your verification application is currently being reviewed. We will contact you within 1-3 business days.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.orange[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => controller.backToStarter(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.neutral400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Text(
                    'Register as Shelter',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete the following data to register as a shelter. Your data will be verified within 1-3 business days.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email and password fields for new users (not logged in)
                  Obx(() {
                    if (!controller.isExistingUser.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: controller.emailController,
                            labelText: 'Email *',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email),
                            validator: controller.validateRequired,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => CustomTextField(
                              controller: controller.passwordController,
                              labelText: 'Password *',
                              hintText: 'Minimum 6 characters',
                              prefixIcon: const Icon(Icons.lock),
                              obscureText: controller.isPasswordHidden.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  controller.isPasswordHidden.value =
                                      !controller.isPasswordHidden.value;
                                },
                              ),
                              validator: controller.validateRequired,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => CustomTextField(
                              controller: controller.confirmPasswordController,
                              labelText: 'Confirm Password *',
                              hintText: 'Re-enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              obscureText: controller.isConfirmPasswordHidden.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordHidden.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  controller.isConfirmPasswordHidden.value =
                                      !controller.isConfirmPasswordHidden.value;
                                },
                              ),
                              validator: controller.validateRequired,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Shelter Information',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Form fields
                  CustomTextField(
                    controller: controller.shelterNameController,
                    labelText: 'Shelter Name *',
                    hintText: 'Enter your shelter name',
                    prefixIcon: const Icon(Icons.store),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: controller.phoneController,
                    labelText: 'Phone Number *',
                    hintText: 'Enter a contactable phone number',
                    prefixIcon: const Icon(Icons.phone),
                    validator: controller.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: controller.legalNumberController,
                    labelText: 'Legal/License Number *',
                    hintText: 'NIB, SIUP, or other legal document',
                    prefixIcon: const Icon(Icons.assignment),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: controller.descriptionController,
                    labelText: 'Shelter Description (Optional)',
                    hintText: 'Tell us a bit about your shelter',
                    prefixIcon: const Icon(Icons.description),
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  Text(
                    'Shelter Location *',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select shelter location on the map to auto-fill address',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.neutral600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Display address if available
                  Obx(() {
                    if (controller.latitude.value != null && 
                        controller.longitude.value != null &&
                        controller.address.value.isNotEmpty) {
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
                                fontWeight: FontWeight.w500,
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
                            const SizedBox(height: 4),
                            Text(
                              'Coordinates: ${controller.latitude.value!.toStringAsFixed(6)}, ${controller.longitude.value!.toStringAsFixed(6)}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No location selected yet. Click button below to select.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Map picker button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        print('🗺️ DEBUG VerificationView: Opening map picker...');
                        GeoPoint? initialLocation;
                        if (controller.latitude.value != null && 
                            controller.longitude.value != null) {
                          initialLocation = GeoPoint(
                            controller.latitude.value!,
                            controller.longitude.value!,
                          );
                          print('🗺️ DEBUG VerificationView: Initial location: ${initialLocation.latitude}, ${initialLocation.longitude}');
                        }
                        
                        final result = await Get.to(() => LocationPickerView(
                          initialLocation: initialLocation,
                        ));
                        
                        print('🗺️ DEBUG VerificationView: Returned from map picker');
                        print('🗺️ DEBUG VerificationView: Result: $result');
                        print('🗺️ DEBUG VerificationView: Result type: ${result.runtimeType}');
                        
                        if (result != null && result is GeoPoint) {
                          print('🗺️ DEBUG VerificationView: Valid GeoPoint received');
                          controller.latitude.value = result.latitude;
                          controller.longitude.value = result.longitude;
                          print('🗺️ DEBUG VerificationView: Coordinates set - Lat: ${result.latitude}, Lng: ${result.longitude}');
                          
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
                          print('🗺️ DEBUG VerificationView: Starting reverse geocode...');
                          try {
                            await controller.reverseGeocode(
                              result.latitude,
                              result.longitude,
                            );
                            print('🗺️ DEBUG VerificationView: Reverse geocode complete');
                            
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
                            print('❌ DEBUG VerificationView: Reverse geocode failed: $e');
                            
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
                        } else {
                          print('🗺️ DEBUG VerificationView: No valid result received or user cancelled');
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: Text(
                        controller.latitude.value == null 
                            ? 'Select Location on Map'
                            : 'Change Location',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Profile Photo Section
                  Text(
                    'Shelter Profile Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
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
                                  Icons.home_work,
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
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap to select photo (optional)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'After the submission is sent, our team will verify it. You will receive a notification via email.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  Obx(() => Button1(
                    text: 'Submit Application',
                    onPressed: () => controller.submitVerification(),
                    isLoading: controller.isLoading.value,
                  )),
                  const SizedBox(height: 16),

                  // Cancel button
                  Button2(
                    text: 'Cancel',
                    onPressed: () => controller.backToStarter(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
