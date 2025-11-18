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
import '../../../../utils/pet_photo_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // 1. Page list moved outside 'build' to maintain state
  final List<Widget> _pages = const [
    AdoptView(),
    EventView(),
    HomePage(), // Index 2
    ChatView(),
    ProfileView(),
  ];

  // 2. Define index for "Home" for readability
  static const int _homeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      return Scaffold(
        // 3. Added to fix navbar radius issue
        extendBody: true,
        // 4. Use constant '_homeIndex'
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
                          Obx(() => Text(
                                controller.userLocation.value.isNotEmpty
                                    ? controller.userLocation.value
                                    : 'Location not set',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              )),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                child: RectangleSearchBar(
                  hintText: 'Search events and pets...',
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Community Events',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // EventCarousel with consistent padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: EventCarousel(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recommended Pets',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildRecommendedPets(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedPets() {
    print('🔍 DEBUG: Building recommended pets stream...');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('adoptionStatus', isEqualTo: 'available')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        print('📊 DEBUG: Stream state: ${snapshot.connectionState}');
        if (snapshot.hasData) {
          print('✅ DEBUG: Found ${snapshot.data!.docs.length} pets');
        }
        if (snapshot.hasError) {
          print('❌ DEBUG: Error loading pets: ${snapshot.error}');
        }
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
                    'No pets available yet',
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
        // Now fetch photos from subcollection
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _buildPetsWithPhotos(snapshot.data!.docs),
          builder: (context, petsSnapshot) {
            if (petsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!petsSnapshot.hasData || petsSnapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No pet data available',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            return PetListWidget(pets: petsSnapshot.data!);
          },
        );
      },
    );
  }

  // Helper function to fetch pets with their photos from subcollection
  Future<List<Map<String, dynamic>>> _buildPetsWithPhotos(
      List<QueryDocumentSnapshot> docs) async {
    final List<Map<String, dynamic>> petsData = [];
    
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Get primary photo from subcollection
      String imageUrl = 'https://via.placeholder.com/300x300?text=Pet';
      List<String> imageUrls = [];
      
      try {
        final helper = PetPhotoHelper();
        final photos = await helper.getPetPhotoUrls(doc.id);
        
        if (photos.isNotEmpty) {
          imageUrls = photos;
          imageUrl = photos[0];
        } else if (data['imageUrls'] != null &&
            (data['imageUrls'] as List).isNotEmpty) {
          // Fallback to old imageUrls field for backward compatibility
          imageUrls = (data['imageUrls'] as List)
              .map((e) => e.toString())
              .toList();
          imageUrl = imageUrls[0];
        }
      } catch (e) {
        print('Error fetching photos for pet ${doc.id}: $e');
      }

      petsData.add({
        'petId': doc.id,
        'shelterId': data['shelterId']?.toString() ?? '',
        'imageUrl': imageUrl,
        'petName': (data['petName'] ?? 'Pet Name').toString(),
        'name': (data['petName'] ?? data['name'] ?? 'Pet Name').toString(),
        'breed': (data['breed'] ?? 'Breed').toString(),
        'ageMonths': data['ageMonths'] ?? 0,
        'age': data['ageMonths']?.toString() ?? data['age']?.toString() ?? 'Age',
        'shelter': (data['shelterName'] ?? 'Shelter').toString(),
        'shelterName': (data['shelterName'] ?? 'Shelter').toString(),
        'location': (data['location'] ?? 'Location').toString(),
        'gender': (data['gender'] ?? 'Male').toString(),
        'description': (data['description'] ?? '').toString(),
        'category': (data['category'] ?? '').toString(),
        'type': (data['category'] ?? data['type'] ?? '').toString(),
        'imageUrls': imageUrls.isNotEmpty ? imageUrls : [imageUrl],
      });
    }
    
    return petsData;
  }
}
