import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/widgets/text_field.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../theme/app_colors.dart';
import '../../../../common/widgets/lottie_loading.dart';
import 'adoption_request_controller.dart';

class AdoptionRequestView extends GetView<AdoptionRequestController> {
  const AdoptionRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          'Adoption Request',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please fill out this form carefully. The shelter will review your application.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pet Info
                Text(
                  'Pet Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pets, color: AppColors.primary, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.petData['petName'] ?? 
                              controller.petData['name'] ?? 
                              'Unknown Pet',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              controller.petData['breed']?.toString() ?? '-',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Adoption Reason
                Text(
                  'Why do you want to adopt this pet?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.adoptionReasonController,
                  decoration: InputDecoration(
                    labelText: 'Adoption Reason',
                    hintText: 'Tell us your reason for adopting...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 4,
                  validator: controller.validateRequired,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Pet Experience
                Text(
                  'Do you have experience caring for pets?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.petExperienceController,
                  decoration: InputDecoration(
                    labelText: 'Pet Experience',
                    hintText: 'Describe your experience with pets...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 4,
                  validator: controller.validateRequired,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Residence Status
                Text(
                  'Residence Status',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(
                          'Own House',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: 'own_house',
                        groupValue: controller.selectedResidenceStatus.value,
                        onChanged: (value) {
                          controller.selectedResidenceStatus.value = value!;
                        },
                        activeColor: AppColors.primary,
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Rental',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: 'rental',
                        groupValue: controller.selectedResidenceStatus.value,
                        onChanged: (value) {
                          controller.selectedResidenceStatus.value = value!;
                        },
                        activeColor: AppColors.primary,
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Boarding',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        value: 'boarding',
                        groupValue: controller.selectedResidenceStatus.value,
                        onChanged: (value) {
                          controller.selectedResidenceStatus.value = value!;
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),

                // Has Yard
                Obx(() => CheckboxListTile(
                  title: Text(
                    'I have a yard for the pet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: controller.hasYard.value,
                  onChanged: (value) {
                    controller.hasYard.value = value ?? false;
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
                const SizedBox(height: 16),

                // Family Members
                Text(
                  'Number of Family Members',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.familyMembersController,
                  labelText: 'Number of Family Members',
                  hintText: 'Enter number of family members',
                  keyboardType: TextInputType.number,
                  validator: controller.validateNumber,
                ),
                const SizedBox(height: 16),

                // Environment Description
                Text(
                  'Living Environment Description',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.environmentDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Environment Description',
                    hintText: 'Describe your living environment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 4,
                  validator: controller.validateRequired,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Submit Button
                Obx(() => controller.isLoading.value
                    ? const Center(
                        child: LottieLoading(width: 80, height: 80),
                      )
                    : Button1(
                        text: 'Submit Adoption Request',
                        onPressed: controller.submitAdoptionRequest,
                      )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
