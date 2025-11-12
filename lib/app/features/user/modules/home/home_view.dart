import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../adopt/adopt_view.dart';
import '../../../../features/shared/modules/event/event_view.dart';
import '../chat/chat_view.dart';
import '../profile/profile_view.dart';
import 'home_controller.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../common/widgets/event_carousel.dart';
import '../../../../common/widgets/pet_list.dart';
import '../../../../common/widgets/custom_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // 1. Daftar halaman dipindahkan ke luar 'build' agar state-nya terjaga
  final List<Widget> _pages = const [
    AdoptView(),
    EventView(),
    HomePage(), // Index 2
    ChatView(),
    ProfileView(),
  ];

  // 2. Definisikan index untuk "Home" agar mudah dibaca
  static const int _homeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      return Scaffold(
        // 3. Tambahan untuk memperbaiki masalah radius navbar
        extendBody: true,
        // 4. Gunakan constant '_homeIndex'
        appBar: currentIndex == _homeIndex
            ? AppBar(
                title: Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${_getFirstName()}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Jakarta, Indonesia', // dummy data
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
              )
            : null,

        // Cukup panggil halaman dari list
        body: _pages[currentIndex],

        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: currentIndex,
          onTap: controller.changePage,
        ),
      );
    });
  }

  String _getFirstName() {
    final args = Get.arguments;
    final name = args != null && args['name'] != null
        ? args['name'] as String
        : 'User';
    return name.split(' ').first;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _refreshData() async {
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
    // Data will automatically refresh because we're using StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    // 5. SafeArea diatur 'bottom: false' agar konten bisa scroll
    //    di belakang navigation bar (karena ada extendBody: true)
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RectangleSearchBar(),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Acara Komunitas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                EventCarousel(),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rekomendasi Hewan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecommendedPets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedPets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('status', isEqualTo: 'available')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.pets, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada hewan tersedia',
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

        // Convert Firestore data to format expected by PetListWidget
        final petsData = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Get image URL - prioritize imageUrls array, fallback to imageUrl field
          String imageUrl = 'https://via.placeholder.com/300x300?text=Pet';
          if (data['imageUrls'] != null &&
              (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List)[0].toString();
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
          }

          return {
            'imageUrl': imageUrl,
            'name': (data['name'] ?? 'Nama Hewan').toString(),
            'breed': (data['breed'] ?? 'Ras').toString(),
            'age': (data['age'] ?? 'Umur').toString(),
            'shelter': (data['shelterName'] ?? 'Shelter').toString(),
            'shelterName': (data['shelterName'] ?? 'Shelter').toString(),
            'location': (data['location'] ?? 'Lokasi').toString(),
            'gender': (data['gender'] ?? 'Jantan').toString(),
            'description': (data['description'] ?? '').toString(),
            'type': (data['type'] ?? '').toString(),
            'imageUrls': data['imageUrls'] ?? [imageUrl],
          };
        }).toList();

        return PetListWidget(pets: petsData);
      },
    );
  }
}
