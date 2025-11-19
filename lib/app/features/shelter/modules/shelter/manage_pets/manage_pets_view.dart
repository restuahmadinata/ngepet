import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../theme/app_colors.dart';
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
        actions: [
          // Debug button (temporary - remove in production)
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: () async {
              await controller.debugImages();
              await controller.fixImageStructure();
            },
            tooltip: 'Debug & Fix Images',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.addNewPet,
            tooltip: 'Add New Pet',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
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
                fillColor: Colors.grey[50],
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
    Color statusColor;
    String statusText;
    switch (adoptionStatus.toLowerCase()) {
      case 'adopted':
        statusColor = Colors.green;
        statusText = 'Adopted';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Available';
    }

    return Opacity(
      opacity: isAdopted ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: isAdopted ? 1 : 2,
        color: isAdopted ? Colors.grey[100] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isAdopted 
              ? BorderSide(color: Colors.grey[300]!, width: 1)
              : BorderSide.none,
        ),
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
                  // Show pet details or edit
                  controller.editPet(petId);
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.pets, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Pet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              petName,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        breed,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Pet Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              adoptionStatus.toLowerCase() == 'adopted'
                                  ? Icons.check_circle
                                  : adoptionStatus.toLowerCase() == 'pending'
                                      ? Icons.hourglass_empty
                                      : Icons.pets,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pet Status: $statusText',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(Icons.category, category),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            gender.toLowerCase() == 'male' 
                                ? Icons.male 
                                : Icons.female,
                            gender,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.cake, '$ageMonths months'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!isAdopted)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => controller.editPet(petId),
                              color: AppColors.primary,
                              tooltip: 'Edit',
                            ),
                            Obx(() {
                              final isDeleting = controller.deletingPetId.value == petId;
                              return IconButton(
                                icon: isDeleting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.red,
                                        ),
                                      )
                                    : const Icon(Icons.delete, size: 20),
                                onPressed: isDeleting 
                                    ? null 
                                    : () => controller.deletePet(petId, petName),
                                color: Colors.red,
                                tooltip: isDeleting ? 'Deleting...' : 'Delete',
                              );
                            }),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.lock, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                'Cannot edit adopted pet',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
