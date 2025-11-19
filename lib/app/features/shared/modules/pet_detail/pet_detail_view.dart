import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../common/widgets/fullscreen_image_gallery.dart';
import 'pet_detail_controller.dart';

class PetDetailView extends StatefulWidget {
  final Map<String, dynamic> petData;

  const PetDetailView({super.key, required this.petData});

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
      backgroundColor: Colors.white,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.petData['petName']?.toString() ??
                                  widget.petData['name']?.toString() ??
                                  'Pet Name',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.petData['gender']?.toString() == 'Male')
                                  ? Colors.blue[100]
                                  : Colors.pink[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  (widget.petData['gender']?.toString() == 'Male')
                                      ? Icons.male
                                      : Icons.female,
                                  size: 16,
                                  color:
                                      (widget.petData['gender']?.toString() == 'Male')
                                      ? Colors.blue[700]
                                      : Colors.pink[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.petData['gender']?.toString() ??
                                      'Male',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        (widget.petData['gender']?.toString() == 'Male')
                                        ? Colors.blue[700]
                                        : Colors.pink[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Info Cards
                      Row(
                        children: [
                          _buildInfoCard(
                            icon: Icons.pets,
                            label: 'Breed',
                            value: widget.petData['breed']?.toString() ?? '-',
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.cake,
                            label: 'Age',
                            value: '${widget.petData['ageMonths']?.toString() ?? widget.petData['age']?.toString() ?? '-'} months',
                            color: Colors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
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

                      const SizedBox(height: 20),

                      // Location
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: widget.petData['location']?.toString() ?? '-',
                        iconColor: Colors.red,
                      ),
                      const SizedBox(height: 12),

                      // Shelter
                      GestureDetector(
                        onTap: () {
                          // Navigate to shelter profile
                          print('🔍 Pet data keys: ${widget.petData.keys}');
                          print('🔍 ShelterId: ${widget.petData['shelterId']}');
                          
                          if (widget.petData['shelterId'] != null && 
                              widget.petData['shelterId'].toString().isNotEmpty) {
                            print('✅ Navigating to shelter profile');
                            Get.toNamed(
                              AppRoutes.shelterProfile,
                              arguments: widget.petData['shelterId'],
                            );
                          } else {
                            print('❌ No shelterId found');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Shelter data not available'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: _buildDetailRow(
                          icon: Icons.home,
                          label: 'Shelter',
                          value:
                              widget.petData['shelterName']?.toString() ??
                              widget.petData['shelter']?.toString() ??
                              '-',
                          iconColor: Colors.blue,
                          // Keep the row tappable (GestureDetector) but don't
                          // visually indicate it as a link — make text plain black
                          // and remove the arrow icon by setting isClickable=false.
                          isClickable: false,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Type
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Category',
                        value: widget.petData['category']?.toString() ?? 
                               widget.petData['type']?.toString() ?? '-',
                        iconColor: Colors.purple,
                      ),

                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Obx(() {
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
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
                      foregroundColor: const Color(0xFFE27B59),
                      side: const BorderSide(color: Color(0xFFE27B59), width: 2),
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
                            backgroundColor: Colors.blue,
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
                            backgroundColor: const Color(0xFFE27B59),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isClickable = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isClickable ? Colors.blue[700] : Colors.black87,
                        decoration: isClickable ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                  if (isClickable)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.blue[700],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
