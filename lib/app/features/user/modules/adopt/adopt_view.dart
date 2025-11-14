import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../common/widgets/pet_list.dart';
import '../../../../utils/pet_photo_helper.dart';

class AdoptController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following

  void changeTab(int index) {
    selectedTab.value = index;
  }
}

class AdoptView extends StatelessWidget {
  const AdoptView({super.key});

  Future<void> _refreshData() async {
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
    // Data will automatically refresh because we're using StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    final AdoptController controller = Get.put(AdoptController());

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          child: Text(
            'Adopt',
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
                    hintText: 'search pets',
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
                        ? _buildPetStream()
                        : _buildFollowingPets(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
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
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pets available for adoption yet',
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

        // Convert Firestore data with photos from subcollection
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
      
      // Get photos from subcollection
      String imageUrl = 'https://via.placeholder.com/300x300?text=Pet';
      List<String> imageUrls = [];
      
      try {
        final helper = PetPhotoHelper();
        final photos = await helper.getPetPhotoUrls(doc.id);
        
        if (photos.isNotEmpty) {
          imageUrls = photos;
          imageUrl = photos[0];
          print('DEBUG AdoptView - Using subcollection photo: $imageUrl');
        } else if (data['imageUrls'] != null &&
            (data['imageUrls'] as List).isNotEmpty) {
          // Fallback to old imageUrls field
          imageUrls = (data['imageUrls'] as List)
              .map((e) => e.toString())
              .toList();
          imageUrl = imageUrls[0];
          print('DEBUG AdoptView - Using old imageUrls: $imageUrl');
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

  Widget _buildFollowingPets() {
    // For now, show the same pets stream
    // TODO: Implement user following/favorites functionality
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Following feature under development',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
