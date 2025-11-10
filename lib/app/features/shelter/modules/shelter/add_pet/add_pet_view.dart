import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../../../common/widgets/text_field.dart';
import '../../../../../common/widgets/button1.dart';
import '../../../../../theme/app_colors.dart';
import 'add_pet_controller.dart';

class AddPetView extends GetView<AddPetController> {
  const AddPetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Hewan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
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
                            'Lengkapi data hewan dengan benar. Data ini akan dilihat oleh calon adopter.',
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

                  // Image picker section
                  Text(
                    'Foto Hewan',
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
                                    'Pilih Foto Hewan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.neutral600,
                                    ),
                                  ),
                                  Text(
                                    'Bisa pilih banyak foto',
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
                                      '${controller.selectedImages.length} foto dipilih. Foto pertama akan jadi thumbnail.',
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
                                      'Pilih Lagi',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Pet name
                  CustomTextField(
                    controller: controller.nameController,
                    labelText: 'Nama Hewan *',
                    hintText: 'Masukkan nama hewan',
                    prefixIcon: const Icon(Icons.pets),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Pet type dropdown
                  Text(
                    'Jenis Hewan *',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.neutral900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedType.value,
                          isExpanded: true,
                          hint: Text(
                            'Pilih jenis hewan',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          items: controller.typeOptions.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type, style: GoogleFonts.poppins()),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.selectedType.value = newValue;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Breed
                  CustomTextField(
                    controller: controller.breedController,
                    labelText: 'Ras/Breed *',
                    hintText: 'Contoh: Golden Retriever, Persia, dll',
                    prefixIcon: const Icon(Icons.category),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Age
                  CustomTextField(
                    controller: controller.ageController,
                    labelText: 'Umur *',
                    hintText: 'Contoh: 2 tahun, 6 bulan',
                    prefixIcon: const Icon(Icons.cake),
                    validator: controller.validateAge,
                  ),
                  const SizedBox(height: 16),

                  // Gender dropdown
                  Text(
                    'Jenis Kelamin *',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.neutral900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedGender.value,
                          isExpanded: true,
                          items: controller.genderOptions.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Row(
                                children: [
                                  Icon(
                                    gender == 'Jantan'
                                        ? Icons.male
                                        : Icons.female,
                                    color: gender == 'Jantan'
                                        ? Colors.blue
                                        : Colors.pink,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(gender, style: GoogleFonts.poppins()),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.selectedGender.value = newValue;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  CustomTextField(
                    controller: controller.locationController,
                    labelText: 'Lokasi *',
                    hintText: 'Kota/daerah tempat hewan berada',
                    prefixIcon: const Icon(Icons.location_on),
                    validator: controller.validateRequired,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: controller.descriptionController,
                    labelText: 'Deskripsi (Opsional)',
                    hintText:
                        'Ceritakan tentang karakter, kebiasaan, atau kondisi khusus hewan',
                    prefixIcon: const Icon(Icons.description),
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: controller.isLoading.value
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Menyimpan...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Button1(
                              text: 'Simpan Data Hewan',
                              onPressed: () => controller.submitPet(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.neutral400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
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
