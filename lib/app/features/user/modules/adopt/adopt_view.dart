import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../common/widgets/pet_list.dart';

class AdoptController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following

  void changeTab(int index) {
    selectedTab.value = index;
  }
}

class AdoptView extends StatelessWidget {
  const AdoptView({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RectangleSearchBar(
                  hintText: 'cari hewan',
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
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada hewan yang tersedia untuk adopsi',
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

        // Convert Firestore data to format expected by PetListWidget
        final petsData = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Get first image from imageUrls array, fallback to imageUrl field or placeholder
          String imageUrl = 'https://via.placeholder.com/300x300?text=Pet';
          if (data['imageUrls'] != null &&
              (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List).first.toString();
            print('DEBUG AdoptView - Using imageUrls[0]: $imageUrl');
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
            print('DEBUG AdoptView - Using imageUrl: $imageUrl');
          } else {
            print(
              'DEBUG AdoptView - No image found, using placeholder for: ${data['name']}',
            );
          }

          // Return full data including document fields for detail view
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
              'Fitur Following sedang dalam pengembangan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
