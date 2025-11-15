import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shelter_profile_controller.dart';
import '../../../../common/widgets/pet_list.dart';
import '../../../../common/widgets/event_list.dart';

class ShelterProfileView extends GetView<ShelterProfileController> {
  const ShelterProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE27B59),
            ),
          );
        }

        if (controller.shelter.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Shelter not found',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final shelter = controller.shelter.value!;

        return CustomScrollView(
          slivers: [
            // App Bar dengan foto shelter
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Foto shelter atau placeholder
                    shelter.shelterPhoto != null && shelter.shelterPhoto!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: shelter.shelterPhoto!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.home,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFE27B59).withOpacity(0.1),
                            child: Icon(
                              Icons.home,
                              size: 80,
                              color: const Color(0xFFE27B59).withOpacity(0.5),
                            ),
                          ),

                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shelter Info Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama shelter
                        Text(
                          shelter.shelterName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // City
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              shelter.city,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tombol Follow (decorator)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement follow functionality
                              Get.snackbar(
                                'Info',
                                'Follow feature coming soon!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFE27B59),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 8,
                                duration: const Duration(seconds: 2),
                              );
                            },
                            icon: const Icon(Icons.favorite_border),
                            label: Text(
                              'Follow Shelter',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE27B59),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Deskripsi
                        Text(
                          'About Shelter',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          shelter.description.isNotEmpty
                              ? shelter.description
                              : 'No description available.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Contact
                        if (shelter.shelterPhone.isNotEmpty ||
                            shelter.shelterEmail.isNotEmpty) ...[
                          Text(
                            'Contact',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (shelter.shelterPhone.isNotEmpty)
                            _buildContactRow(
                              icon: Icons.phone,
                              text: shelter.shelterPhone,
                            ),
                          if (shelter.shelterEmail.isNotEmpty)
                            _buildContactRow(
                              icon: Icons.email,
                              text: shelter.shelterEmail,
                            ),
                        ],
                      ],
                    ),
                  ),

                  // Tab Bar for Pets and Events
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.selectedTab.value = 0,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Pets',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: controller.selectedTab.value == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: controller.selectedTab.value == 0
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.selectedTab.value = 1,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Events',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: controller.selectedTab.value == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: controller.selectedTab.value == 1
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content based on selected tab
                  Obx(() {
                    if (controller.selectedTab.value == 0) {
                      // Pets Tab
                      return _buildPetsSection();
                    } else {
                      // Events Tab
                      return _buildEventsSection();
                    }
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContactRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsSection() {
    return Obx(() {
      if (controller.isLoadingPets.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE27B59),
            ),
          ),
        );
      }

      if (controller.pets.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.pets,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No pets yet',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Transform data to match PetListWidget format
      final transformedPets = controller.pets.map((pet) {
        String imageUrl = '';
        if (pet['imageUrls'] != null && 
            pet['imageUrls'] is List && 
            (pet['imageUrls'] as List).isNotEmpty) {
          imageUrl = (pet['imageUrls'] as List).first.toString();
        }

        return {
          'imageUrl': imageUrl,
          'name': pet['petName']?.toString() ?? 'Unknown',
          'breed': pet['breed']?.toString() ?? '-',
          'age': '${pet['ageMonths']?.toString() ?? '-'} months',
          'shelter': controller.shelter.value?.shelterName ?? '-',
          'location': controller.shelter.value?.city ?? '-',
          'gender': pet['gender']?.toString() ?? 'Male',
          ...pet, // Include all original data for fullData
        };
      }).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            PetListWidget(pets: transformedPets),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildEventsSection() {
    return Obx(() {
      if (controller.isLoadingEvents.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE27B59),
            ),
          ),
        );
      }

      if (controller.events.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No events yet',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Transform data to match EventList format
      final transformedEvents = controller.events.map((event) {
        String imageUrl = '';
        if (event['imageUrls'] != null && 
            event['imageUrls'] is List && 
            (event['imageUrls'] as List).isNotEmpty) {
          imageUrl = (event['imageUrls'] as List).first.toString();
        } else if (event['imageUrls']?.toString().isNotEmpty == true) {
          imageUrl = event['imageUrls'].toString();
        }

        return {
          'imageUrl': imageUrl,
          'title': event['eventTitle']?.toString() ?? 'Event',
          'date': event['eventDate']?.toString() ?? '-',
          'shelter': controller.shelter.value?.shelterName ?? '-',
          'location': event['location']?.toString() ?? '-',
          'description': event['description']?.toString() ?? '',
          ...event, // Include all original data for fullData
        };
      }).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            EventList(events: transformedEvents),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
