import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 300,
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
                      return CachedNetworkImage(
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
                            Icons.event,
                            size: 64,
                            color: Colors.grey,
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
            child: Padding(
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date & Time Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE27B59).withOpacity(0.1),
                          const Color(0xFFE27B59).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE27B59).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE27B59),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.eventData['eventDate']?.toString() ?? 
                                    widget.eventData['date']?.toString() ?? 'TBA',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if ((widget.eventData['startTime']?.toString().isNotEmpty ?? false) ||
                                  (widget.eventData['time']?.toString().isNotEmpty ?? false))
                                Text(
                                  widget.eventData['startTime']?.toString() ?? 
                                      widget.eventData['time']?.toString() ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Location
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: widget.eventData['location']?.toString() ?? '-',
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 16),

                  // Organizer
                  GestureDetector(
                    onTap: () {
                      // Navigate to shelter profile
                      print('🔍 Event data keys: ${widget.eventData.keys}');
                      print('🔍 ShelterId: ${widget.eventData['shelterId']}');
                      
                      if (widget.eventData['shelterId'] != null && 
                          widget.eventData['shelterId'].toString().isNotEmpty) {
                        print('✅ Navigating to shelter profile');
                        Get.toNamed(
                          AppRoutes.shelterProfile,
                          arguments: widget.eventData['shelterId'],
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
                      icon: Icons.business,
                      label: 'Organizer',
                      value: widget.eventData['shelterName']?.toString() ?? 
                             widget.eventData['shelter']?.toString() ?? '-',
                      iconColor: Colors.blue,
                      isClickable: widget.eventData['shelterId'] != null &&
                          widget.eventData['shelterId'].toString().isNotEmpty,
                    ),
                  ),                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Event Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
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

                  const SizedBox(height: 32),

                ],
              ),
            ),
          ),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
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
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
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
