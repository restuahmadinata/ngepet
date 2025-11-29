import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../common/widgets/text_field.dart';
import '../../../../../common/widgets/button1.dart';
import '../../../../../common/widgets/location_picker.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../common/widgets/lottie_loading.dart';
import 'verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    // Akses Theme Data
    final theme = Theme.of(Get.context!);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo_ngepet.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 100,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Center(
                    child: Text(
                      "Register As Shelter",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: 24),

                  // Section 0
                  Text(
                    "Shelter Profile Picture",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Obx(() {
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select photo (optional)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 1
                  Obx(() {
                    if (!controller.isExistingUser.value) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Account Information",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          CustomTextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            labelText: 'Email',
                            validator: controller.validateRequired,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          Obx(
                            () => CustomTextField(
                              controller: controller.passwordController,
                              obscureText: controller.isPasswordHidden.value,
                              labelText: 'Password',
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.neutral600,
                                ),
                                onPressed: () {
                                  controller.isPasswordHidden.toggle();
                                },
                              ),
                              validator: controller.validateRequired,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          Obx(
                            () => CustomTextField(
                              controller: controller.confirmPasswordController,
                              obscureText: controller.isConfirmPasswordHidden.value,
                              labelText: 'Confirm Password',
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordHidden.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.neutral600,
                                ),
                                onPressed: () {
                                  controller.isConfirmPasswordHidden.toggle();
                                },
                              ),
                              validator: controller.validateRequired,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Section 2
                  Text(
                    "Shelter Information",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shelter name
                  CustomTextField(
                    controller: controller.shelterNameController,
                    labelText: 'Shelter Name',
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CustomTextField(
                    controller: controller.phoneController,
                    labelText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhone,
                  ),
                  const SizedBox(height: 16),

                  // Legal
                  CustomTextField(
                    controller: controller.legalNumberController,
                    labelText: 'Legal/License Number',
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: controller.descriptionController,
                    labelText: 'Shelter Description',
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Obx(() => Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        GeoPoint? initialLocation;
                        if (controller.latitude.value != null && controller.longitude.value != null) {
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
                          // Show loading
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
                          // Reverse geocode
                          try {
                            await controller.reverseGeocode(
                              result.latitude,
                              result.longitude,
                            );
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Location updated successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          } catch (e) {
                            Get.back();
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
                      icon: const Icon(Icons.map, color: AppColors.neutral600),
                      label: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          controller.address.value.isEmpty ? 'Select Location on Map' : controller.address.value,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: controller.address.value.isEmpty ? AppColors.neutral500 : AppColors.neutral700,
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

                  // Register Button
                  Obx(() => Button1(
                    text: 'REGISTER',
                    onPressed: controller.submitVerification,
                    isLoading: controller.isLoading.value,
                  )),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
