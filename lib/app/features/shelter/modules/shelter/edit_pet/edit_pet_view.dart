import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../common/widgets/text_field.dart';
import '../../../../../common/widgets/button1.dart';
import '../../../../../common/widgets/button2.dart';
import '../../../../../theme/app_colors.dart';
import 'edit_pet_controller.dart';

class EditPetView extends GetView<EditPetController> {
  const EditPetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Pet',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return SafeArea(
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
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Update pet information. You can add or remove photos.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image section
                    Text(
                      'Pet Photos',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Existing images
                    Obx(() {
                      if (controller.existingImageUrls.isEmpty && controller.newImages.isEmpty) {
                        return GestureDetector(
                          onTap: controller.pickImages,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.neutral400),
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
                                  'Add Pet Photos',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display existing images
                          if (controller.existingImageUrls.isNotEmpty) ...[
                            Text(
                              'Current Photos',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.existingImageUrls.length,
                                itemBuilder: (context, index) {
                                  final url = controller.existingImageUrls[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => controller.removeExistingImage(url),
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
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Display new images
                          if (controller.newImages.isNotEmpty) ...[
                            Text(
                              'New Photos (to be uploaded)',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.newImages.length,
                                itemBuilder: (context, index) {
                                  final image = controller.newImages[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            image,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => controller.removeNewImage(index),
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
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Add more photos button
                          TextButton.icon(
                            onPressed: controller.pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(
                              'Add More Photos',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),

                    // Pet name
                    CustomTextField(
                      controller: controller.nameController,
                      labelText: 'Pet Name *',
                      hintText: 'Example: Buddy',
                      prefixIcon: const Icon(Icons.pets),
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 16),

                    // Type/Category
                    Text(
                      'Pet Type *',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedType.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: controller.typeOptions
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedType.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Breed
                    CustomTextField(
                      controller: controller.breedController,
                      labelText: 'Breed *',
                      hintText: 'Example: Golden Retriever',
                      prefixIcon: const Icon(Icons.info_outline),
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    Text(
                      'Gender *',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedGender.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.wc),
                        ),
                        items: controller.genderOptions
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedGender.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Age
                    CustomTextField(
                      controller: controller.ageController,
                      labelText: 'Age *',
                      hintText: 'Example: 2 years, 6 months',
                      prefixIcon: const Icon(Icons.cake),
                      validator: controller.validateAge,
                    ),
                    const SizedBox(height: 16),

                    // Adoption Status
                    Text(
                      'Adoption Status *',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedStatus.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.check_circle_outline),
                        ),
                        items: controller.statusOptions
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status[0].toUpperCase() + status.substring(1),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedStatus.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description *',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tell about this pet...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.description),
                        ),
                      ),
                      validator: controller.validateRequired,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    Obx(() => Button1(
                          text: 'Save Changes',
                          onPressed: controller.saveChanges,
                          isLoading: controller.isSaving.value,
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
        );
      }),
    );
  }
}
