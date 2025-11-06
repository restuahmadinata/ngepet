import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/rectangle_search_bar.dart';
import '../../widgets/event_list.dart';

class EventController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following

  void changeTab(int index) {
    selectedTab.value = index;
  }
}

class EventView extends StatelessWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.put(EventController());

    final exploringEvents = [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1544568100-847a948585b9',
        'title': 'Adoption Day Jakarta',
        'date': '15 Nov 2025',
        'shelter': 'Jakarta Animal Shelter',
        'location': 'Jakarta',
        'description': 'Event adopsi hewan di Jakarta dengan berbagai jenis hewan.',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1574158622682-e40e69881006',
        'title': 'Pet Care Workshop',
        'date': '20 Nov 2025',
        'shelter': 'Bandung Pet Care Center',
        'location': 'Bandung',
        'description': 'Workshop perawatan hewan peliharaan untuk pemula.',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
        'title': 'Animal Rescue Fundraiser',
        'date': '25 Nov 2025',
        'shelter': 'Surabaya Wildlife Rescue',
        'location': 'Surabaya',
        'description': 'Penggalangan dana untuk penyelamatan hewan liar.',
      },
    ];

    final followingEvents = [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64',
        'title': 'Cat Adoption Event',
        'date': '10 Nov 2025',
        'shelter': 'Yogyakarta Cat Sanctuary',
        'location': 'Yogyakarta',
        'description': 'Event khusus adopsi kucing di Yogyakarta.',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1516280030429-27679b3dc9cf',
        'title': 'Dog Training Seminar',
        'date': '30 Nov 2025',
        'shelter': 'Semarang Dog Training Academy',
        'location': 'Semarang',
        'description': 'Seminar pelatihan anjing untuk pemilik baru.',
      },
    ];

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
                Obx(() => Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Exploring',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: controller.selectedTab.value == 0 ? FontWeight.bold : FontWeight.normal,
                              color: controller.selectedTab.value == 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Following',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: controller.selectedTab.value == 1 ? FontWeight.bold : FontWeight.normal,
                              color: controller.selectedTab.value == 1 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 24),
                Obx(() => EventList(
                  events: controller.selectedTab.value == 0 ? exploringEvents : followingEvents,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
