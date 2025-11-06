import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../adopt/adopt_view.dart';
import '../event/event_view.dart';
import '../chat/chat_view.dart';
import '../profile/profile_view.dart';
import 'home_controller.dart';
import '../../widgets/rectangle_search_bar.dart';
import '../../widgets/event_carousel.dart';
import '../../widgets/pet_list.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

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
                      Text('Halo, ${_getFirstName()}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Jakarta, Indonesia', // dummy data
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor:
                    Theme.of(context).textTheme.titleLarge?.color,
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
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 5. SafeArea diatur 'bottom: false' agar konten bisa scroll
    //    di belakang navigation bar (karena ada extendBody: true)
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: SingleChildScrollView(
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
                      fontSize: 18, fontWeight: FontWeight.bold),
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
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              PetListWidget(
                pets: [
                  {
                    'imageUrl': 'https://images.unsplash.com/photo-1544568100-847a948585b9',
                    'name': 'Areeliotus',
                    'breed': 'Black Dawg',
                    'age': '69 tahun',
                    'shelter': 'Thug Hunter Victim Shelter',
                    'location': 'Ngawi',
                    'gender': 'Non-binary',
                  },
                  {
                    'imageUrl': 'https://images.unsplash.com/photo-1574158622682-e40e69881006',
                    'name': 'Buddy',
                    'breed': 'Golden Retriever',
                    'age': '1 tahun',
                    'shelter': 'Shelter B',
                    'location': 'Bandung',
                    'gender': 'Jantan',
                  },
                  {
                    'imageUrl': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
                    'name': 'Luna',
                    'breed': 'Siamese',
                    'age': '3 tahun',
                    'shelter': 'Shelter C',
                    'location': 'Surabaya',
                    'gender': 'Betina',
                  },
                  {
                    'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64',
                    'name': 'Max',
                    'breed': 'Bulldog',
                    'age': '4 tahun',
                    'shelter': 'Shelter D',
                    'location': 'Yogyakarta',
                    'gender': 'Jantan',
                  },
                  {
                    'imageUrl': 'https://images.unsplash.com/photo-1516280030429-27679b3dc9cf',
                    'name': 'Bella',
                    'breed': 'Maine Coon',
                    'age': '1.5 tahun',
                    'shelter': 'Shelter E',
                    'location': 'Semarang',
                    'gender': 'Betina',
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}