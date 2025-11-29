import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../common/widgets/lottie_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../common/widgets/fullscreen_image_gallery.dart';
import 'package:ngepet/app/theme/app_colors.dart';
import '../../../../common/controllers/auth_controller.dart';

class EventDetailView extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailView({super.key, required this.eventData});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  int currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get images {
    if (widget.eventData['imageUrls'] != null &&
        widget.eventData['imageUrls'] is List &&
        (widget.eventData['imageUrls'] as List).isNotEmpty) {
      return (widget.eventData['imageUrls'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (widget.eventData['imageUrl'] != null) {
      return [widget.eventData['imageUrl'].toString()];
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
                icon: SvgPicture.asset(
                  'assets/images/back-icon.svg',
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
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
                              child: LottieLoading(width: 80, height: 80),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.event,
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
                // Event Name & Basic Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        widget.eventData['eventTitle']?.toString() ?? 
                            widget.eventData['title']?.toString() ?? 
                            'Event Name',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Grid of attribute cards: Date, Time, Status, Type
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
                                'Event Description',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.eventData['eventDescription']?.toString() ??
                                    widget.eventData['description']?.toString() ??
                                    'No description available for this event.',
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

                      const SizedBox(height: 32),

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

  Widget _buildAttributeGrid() {
    final date = widget.eventData['eventDate']?.toString() ?? widget.eventData['date']?.toString() ?? 'TBA';
    final time = widget.eventData['eventTime']?.toString().isNotEmpty == true
        ? widget.eventData['eventTime']?.toString() ?? ''
        : 'TBA';

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 2;
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
          childAspectRatio: childAspectRatio,
          children: [
            _buildAttributeCard(
              icon: Icons.calendar_today,
              label: 'Date',
              value: date,
              color: Colors.blue,
            ),
            _buildAttributeCard(
              icon: Icons.access_time,
              label: 'Time',
              value: time,
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

  Widget _buildShelterLocationCard(BuildContext context) {
    final shelterName = widget.eventData['shelterName']?.toString() ?? widget.eventData['shelter']?.toString() ?? '-';
    final shelterId = widget.eventData['shelterId']?.toString() ?? '';
    final location = widget.eventData['location']?.toString() ?? '-';

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
              final currentUserId = Get.find<AuthController>().user?.uid;
              if (shelterId == currentUserId) {
                // Already viewing own shelter, show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is your shelter')),
                );
                return;
              }
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