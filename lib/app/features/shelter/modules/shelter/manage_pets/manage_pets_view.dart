import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../features/shared/modules/pet_detail/pet_detail_view.dart';
import 'manage_pets_controller.dart';

class ManagePetsView extends GetView<ManagePetsController> {
  const ManagePetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Manage My Pets',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.transparent,
            child: TextField(
              onChanged: controller.searchPets,
              decoration: InputDecoration(
                hintText: 'Search pets by name, breed, or category...',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),

          // Pet list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (controller.filteredPets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'No pets yet'
                            : 'No pets found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'Add your first pet for adoption'
                            : 'Try a different search term',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (controller.searchQuery.value.isEmpty) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: controller.addNewPet,
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Add Pet',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshPets,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = controller.filteredPets[index];
                    return _buildPetCard(pet);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addNewPet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Pet',
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final petId = pet['id'] ?? pet['petId'] ?? '';
    final petName = pet['petName']?.toString() ?? 'Unknown';
    final breed = pet['breed']?.toString() ?? 'Unknown breed';
    final category = pet['category']?.toString() ?? 'Unknown';
    final gender = pet['gender']?.toString() ?? 'Unknown';
    final ageMonths = pet['ageMonths']?.toString() ?? 'Unknown age';
    final adoptionStatus = pet['adoptionStatus']?.toString() ?? 'available';
    
    // Check if pet is adopted
    final isAdopted = adoptionStatus.toLowerCase() == 'adopted';
    
    // Get image URL
    String imageUrl = 'https://via.placeholder.com/300x300?text=No+Image';
    if (pet['imageUrls'] != null && pet['imageUrls'] is List && (pet['imageUrls'] as List).isNotEmpty) {
      imageUrl = pet['imageUrls'][0].toString();
    }

    // Status color
    switch (adoptionStatus.toLowerCase()) {
      case 'adopted':
        break;
      case 'pending':
        break;
      default:
    }

    return Opacity(
      opacity: isAdopted ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isAdopted ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAdopted 
                ? () {
                    // Show message that adopted pets cannot be edited
                    Get.snackbar(
                      'Cannot Edit',
                      'This pet has been adopted and cannot be edited',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey[700],
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
                : () {
                    // Show pet details preview
                    Get.to(() => PetDetailView(petData: pet, isPreview: true));
                  },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Pet image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColorFiltered(
                      colorFilter: isAdopted
                          ? ColorFilter.mode(
                              Colors.grey,
                              BlendMode.saturation,
                            )
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.pets, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Pet info
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            petName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            breed,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildInfoChip(Icons.category, category),
                              const SizedBox(width: 6),
                              _buildInfoChip(
                                gender.toLowerCase() == 'male' 
                                    ? Icons.male 
                                    : Icons.female,
                                gender,
                              ),
                              const SizedBox(width: 6),
                              _buildInfoChip(Icons.cake, '$ageMonths mo'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // More options button
                  if (!isAdopted)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit') {
                          controller.editPet(petId);
                        } else if (value == 'delete') {
                          controller.deletePet(petId, petName);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text('Edit', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text('Delete', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(Icons.lock, size: 20, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
