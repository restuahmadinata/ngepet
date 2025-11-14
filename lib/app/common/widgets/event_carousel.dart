import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../features/shared/modules/event_detail/event_detail_view.dart';

class EventCarousel extends StatefulWidget {
  const EventCarousel({super.key});

  @override
  State<EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<EventCarousel> {
  int currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: 'upcoming')
          .orderBy('dateTime', descending: false)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No events yet',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final events = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Get image URL - prioritize imageUrls array, fallback to imageUrl field
          String imageUrl = 'https://via.placeholder.com/400x200?text=Event';
          if (data['imageUrls'] != null &&
              (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List)[0].toString();
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
          }

          // Return complete event data for detail view
          return {
            'eventId': doc.id,
            'shelterId': data['shelterId']?.toString() ?? '',
            'image': imageUrl,
            'imageUrl': imageUrl,
            'imageUrls': data['imageUrls'] ?? [imageUrl],
            'eventTitle': data['eventTitle']?.toString() ?? data['title']?.toString() ?? 'Event Title',
            'title': data['eventTitle']?.toString() ?? data['title']?.toString() ?? 'Event Title',
            'eventDate': data['eventDate']?.toString() ?? data['date']?.toString() ?? 'TBA',
            'date': data['eventDate']?.toString() ?? data['date']?.toString() ?? 'TBA',
            'startTime': data['startTime']?.toString() ?? data['time']?.toString() ?? '',
            'time': data['startTime']?.toString() ?? data['time']?.toString() ?? '',
            'shelterName': data['shelterName']?.toString() ?? data['shelter']?.toString() ?? 'Shelter',
            'shelter': data['shelterName']?.toString() ?? data['shelter']?.toString() ?? 'Shelter',
            'location': data['location']?.toString() ?? 'Location',
            'eventDescription': data['eventDescription']?.toString() ?? data['description']?.toString() ?? 'Event description',
            'description': data['eventDescription']?.toString() ?? data['description']?.toString() ?? 'Event description',
          };
        }).toList();

        return _buildCarousel(events);
      },
    );
  }

  Widget _buildCarousel(List<Map<String, dynamic>> events) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: events.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to event detail
                  Get.to(
                    () => EventDetailView(eventData: event),
                    transition: Transition.cupertino,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: event['image']!,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${event['date']} | ${event['shelter']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(events.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == index ? Colors.green : Colors.grey[400],
              ),
            );
          }),
        ),
      ],
    );
  }
}
