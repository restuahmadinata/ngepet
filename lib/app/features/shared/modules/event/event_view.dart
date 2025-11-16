import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../common/widgets/event_list.dart';

class EventController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following

  void changeTab(int index) {
    selectedTab.value = index;
  }
}

class EventView extends StatelessWidget {
  const EventView({super.key});

  Future<void> _refreshData() async {
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
    // Data will automatically refresh because we're using StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.put(EventController());

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          child: Text(
            'Event',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  RectangleSearchBar(
                    hintText: 'search events',
                    onChanged: (value) {
                      // Handle search
                    },
                    controller: TextEditingController(),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.changeTab(0),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Text(
                                'Exploring',
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
                            onTap: () => controller.changeTab(1),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Text(
                                'Following',
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
                  const SizedBox(height: 24),
                  Obx(
                    () => controller.selectedTab.value == 0
                        ? _buildEventStream()
                        : _buildFollowingEvents(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventStream() {
    print('🔍 DEBUG: Building event stream (Event View)...');
    // Show all events (temporary fix - should filter by upcoming/ongoing in production)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('dateTime', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        print('📊 DEBUG: Event stream state: ${snapshot.connectionState}');
        if (snapshot.hasData) {
          print('✅ DEBUG: Found ${snapshot.data!.docs.length} events');
          if (snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              print('📋 DEBUG Event: ${data['eventTitle']} - Status: ${data['eventStatus']} - DateTime: ${data['dateTime']}');
            }
          }
        }
        if (snapshot.hasError) {
          print('❌ DEBUG: Error loading events: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.error, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'An error occurred',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.event, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No events available yet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Convert Firestore data to format expected by EventList
        final eventsData = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Get first image from imageUrls array, fallback to imageUrl field or placeholder
          String imageUrl = 'https://via.placeholder.com/400x200?text=Event';
          if (data['imageUrls'] != null &&
              (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List).first.toString();
            print('DEBUG EventView - Using imageUrls[0]: $imageUrl');
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
            print('DEBUG EventView - Using imageUrl: $imageUrl');
          } else {
            print(
              'DEBUG EventView - No image found, using placeholder for: ${data['title']}',
            );
          }

          return {
            'eventId': doc.id,
            'shelterId': data['shelterId']?.toString() ?? '',
            'imageUrl': imageUrl,
            'eventTitle': (data['eventTitle'] ?? data['title'] ?? 'Event Title').toString(),
            'title': (data['eventTitle'] ?? data['title'] ?? 'Event Title').toString(),
            'eventDate': (data['eventDate'] ?? data['date'] ?? 'TBA').toString(),
            'date': (data['eventDate'] ?? data['date'] ?? 'TBA').toString(),
            'startTime': (data['startTime'] ?? data['time'] ?? '').toString(),
            'time': (data['startTime'] ?? data['time'] ?? '').toString(),
            'shelterName': (data['shelterName'] ?? data['shelter'] ?? 'Shelter').toString(),
            'shelter': (data['shelterName'] ?? data['shelter'] ?? 'Shelter').toString(),
            'location': (data['location'] ?? 'Location').toString(),
            'eventDescription': (data['eventDescription'] ?? data['description'] ?? 'Event description').toString(),
            'description': (data['eventDescription'] ?? data['description'] ?? 'Event description').toString(),
            'imageUrls': data['imageUrls'] ?? [imageUrl],
          };
        }).toList();

        return EventList(events: eventsData);
      },
    );
  }

  Widget _buildFollowingEvents() {
    // For now, show empty state
    // TODO: Implement user following functionality for events
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Following Event feature is under development',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
