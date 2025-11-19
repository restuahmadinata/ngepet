import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../common/widgets/fullscreen_image_gallery.dart';
import 'pet_detail_controller.dart';

class PetDetailView extends StatefulWidget {
  final Map<String, dynamic> petData;
  final bool isPreview;

  const PetDetailView({
    super.key, 
    required this.petData,
    this.isPreview = false,
  });

  @override
  State<PetDetailView> createState() => _PetDetailViewState();
}

class _PetDetailViewState extends State<PetDetailView> {
  int currentImageIndex = 0;
  final PageController _pageController = PageController();
  final PetDetailController controller = Get.put(PetDetailController());

  @override
  void initState() {
    super.initState();
    // Check if user has already applied for this pet
    final petId = widget.petData['petId']?.toString() ?? 
                  widget.petData['id']?.toString() ?? '';
    if (petId.isNotEmpty) {
      controller.checkApplicationStatus(petId);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    Get.delete<PetDetailController>();
    super.dispose();
  }

  List<String> get images {
    if (widget.petData['imageUrls'] != null &&
        widget.petData['imageUrls'] is List &&
        (widget.petData['imageUrls'] as List).isNotEmpty) {
      return (widget.petData['imageUrls'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (widget.petData['imageUrl'] != null) {
      return [widget.petData['imageUrl'].toString()];
    }
    return ['https://via.placeholder.com/400x300?text=No+Image'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 350,
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
                  // Image Carousel
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => FullscreenImageGallery(
                                imageUrls: images,
                                initialIndex: index,
                              ));
                        },
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Image indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
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
                // Pet Name & Basic Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Name
                      Text(
                        widget.petData['petName']?.toString() ??
                            widget.petData['name']?.toString() ??
                            'Pet Name',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Grid of attribute cards: Category, Breed, Gender, Age
                      _buildAttributeGrid(),

                      const SizedBox(height: 16),

                      // Shelter + Location combined card (no shadow, gray border)
                      _buildShelterLocationCard(context),
                      const SizedBox(height: 12),

                      // Description
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.petData['description']?.toString() ??
                                    'No description available.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (!widget.isPreview) const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: widget.isPreview ? null : Obx(() {
        final primaryColor = Theme.of(context).primaryColor;
        if (controller.isLoading.value) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: const SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Chat Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement chat functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(
                      'Chat Owner',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Adopt Button or Check Status Button
                Expanded(
                  child: controller.hasApplied.value
                      ? ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to adoption status page
                            Get.toNamed(AppRoutes.adoptionStatus);
                          },
                          icon: const Icon(Icons.assignment_outlined),
                          label: Text(
                            'Check Status',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () async {
                            // Navigate to adoption request form and wait for result
                            final result = await Get.toNamed(
                              AppRoutes.adoptionRequest,
                              arguments: widget.petData,
                            );

                            // If adoption application was successfully submitted, refresh and update UI
                            if (result == true) {
                              final petId = widget.petData['petId']?.toString() ?? widget.petData['id']?.toString() ?? '';
                              if (petId.isNotEmpty) {
                                await controller.checkApplicationStatus(petId);
                              }
                            }
                          },
                          icon: const Icon(Icons.favorite),
                          label: Text(
                            'Adopt',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAttributeGrid() {
    final category = widget.petData['category']?.toString() ?? widget.petData['type']?.toString() ?? '-';
    final breed = widget.petData['breed']?.toString() ?? '-';
    final gender = widget.petData['gender']?.toString() ?? '-';
    final age = (widget.petData['ageMonths'] != null)
        ? '${widget.petData['ageMonths']?.toString()} months'
        : (widget.petData['age']?.toString() ?? '-');

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 2;
        // Desired target height for each card in logical pixels; increase to make cards bigger
        final targetCardHeight = 75.0;
        final totalSpacing = 8.0 * (crossAxisCount - 1);
        final columnWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        final childAspectRatio = columnWidth / targetCardHeight;

        return GridView.count(
          crossAxisCount: crossAxisCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      // Reduce aspect ratio to give each card more vertical space and avoid overflow
      // width / height = 3.0 means card height will be larger for the current column width
          // computed dynamically to maintain the desired card height
          childAspectRatio: childAspectRatio,
      children: [
        _buildAttributeCard(
          icon: Icons.category,
          label: 'Category',
          value: category,
          color: Colors.purple,
        ),
        _buildAttributeCard(
          icon: Icons.pets,
          label: 'Breed',
          value: breed,
          color: Colors.orange,
        ),
        _buildAttributeCard(
          icon: widget.petData['gender']?.toString() == 'Male' ? Icons.male : Icons.female,
          label: 'Gender',
          value: gender,
          color: widget.petData['gender']?.toString() == 'Male' ? Colors.blue : Colors.pink,
        ),
        _buildAttributeCard(
          icon: Icons.cake,
          label: 'Age',
          value: age,
          color: Colors.green,
        ),
      ],
        );
      },
    );
  }

  Widget _buildAttributeCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Combined shelter and location card will be rendered by _buildShelterLocationCard
  Widget _buildShelterLocationCard(BuildContext context) {
    final shelterName = widget.petData['shelterName']?.toString() ?? widget.petData['shelter']?.toString() ?? '-';
    final shelterId = widget.petData['shelterId']?.toString() ?? '';
    final location = widget.petData['location']?.toString() ?? '-';

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () {
              if (shelterId.isNotEmpty) {
                Get.toNamed(AppRoutes.shelterProfile, arguments: shelterId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shelter data not available')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFEEEFF3),
                    child: Icon(Icons.apartment, color: Color(0xFF444654)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelterName,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'View shelter profile',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
                ],
              ),
            ),
          ),

          // Divider between shelter and location
          Container(color: Colors.grey.shade50, height: 1),

          // Location area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.location_on, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        location,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
