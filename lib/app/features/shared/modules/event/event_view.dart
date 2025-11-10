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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RectangleSearchBar(
                  hintText: 'cari event',
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
    );
  }

  Widget _buildEventStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: 'upcoming')
          .orderBy('dateTime', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
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
                    'Terjadi kesalahan',
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
                    'Belum ada event yang tersedia',
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
            'imageUrl': imageUrl,
            'title': (data['title'] ?? 'Event Title').toString(),
            'date': (data['date'] ?? 'TBA').toString(),
            'time': (data['time'] ?? '').toString(),
            'shelter': (data['shelter'] ?? 'Shelter').toString(),
            'location': (data['location'] ?? 'Lokasi').toString(),
            'description': (data['description'] ?? 'Deskripsi event')
                .toString(),
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
              'Fitur Following Event sedang dalam pengembangan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
