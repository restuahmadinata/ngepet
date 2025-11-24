import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../common/widgets/pet_list.dart';
import '../../../../utils/pet_photo_helper.dart';
import '../../../../services/follower_service.dart';
import '../../../../common/controllers/search_controller.dart' as search;
import '../../../../common/widgets/lottie_loading.dart';

class AdoptController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following
  final FollowerService _followerService = FollowerService();
  final RxList<String> followedShelterIds = <String>[].obs;
  final searchController = Get.put(search.SearchController(), tag: 'adopt');
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _listenToFollowedShelters();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void _listenToFollowedShelters() {
    // Use stream for real-time updates
    _followerService.getFollowedShelterIdsStream().listen((shelterIds) {
      followedShelterIds.value = shelterIds;
      print('📊 Followed shelters updated: ${shelterIds.length} shelters');
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
    // Clear search when switching tabs
    if (textController.text.isNotEmpty) {
      textController.clear();
      searchController.clearResults();
    }
  }

  void onSearchChanged(String value) {
    searchController.updateSearchQuery(value);
    if (value.trim().isNotEmpty) {
      searchController.searchPets();
    }
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
        title: Text(
            'Adopt',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  RectangleSearchBar(
                    hintText: 'Search pets...',
                    onChanged: controller.onSearchChanged,
                    controller: controller.textController,
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    // Show search results if searching
                    if (controller.searchController.searchQuery.value.trim().isNotEmpty) {
                      return _buildSearchResults();
                    }
                    
                    // Show tabs if not searching
                    return Column(
                      children: [
                        Row(
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
                        const SizedBox(height: 24),
                        Obx(
                          () => controller.selectedTab.value == 0
                              ? _buildPetStream()
                              : _buildFollowingPets(),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetStream() {
    print('🔍 DEBUG: Building pet stream (Adopt View)...');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('adoptionStatus', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        print('📊 DEBUG: Pet stream state: ${snapshot.connectionState}');
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
              child: LottieLoading(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
              return const Center(child: LottieLoading());
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

  // Helper function to fetch pets with their photos from subcollection (for Exploring tab)
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
        } else if (data['imageUrls'] != null &&
            (data['imageUrls'] as List).isNotEmpty) {
          // Fallback to old imageUrls field
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
        'age': data['ageMonths']?.toString() ?? '0',
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

  Widget _buildSearchResults() {
    final AdoptController controller = Get.find<AdoptController>();
    
    return Obx(() {
      if (controller.searchController.isSearching.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LottieLoading(),
          ),
        );
      }

      if (controller.searchController.petResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No pets found',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different keywords',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          PetListWidget(pets: controller.searchController.petResults),
          if (controller.searchController.hasMorePets.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: controller.searchController.isLoadingMore.value
                  ? const LottieLoading(width: 80, height: 80)
                  : OutlinedButton(
                      onPressed: () => controller.searchController.loadMorePets(),
                      child: Text(
                        'Load More',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
            ),
        ],
      );
    });
  }

  Widget _buildFollowingPets() {
    final AdoptController controller = Get.find<AdoptController>();
    
    return Obx(() {
      if (controller.followedShelterIds.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No followed shelters yet',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Follow shelters to see their pets here',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      }

      // Use a key based on the shelter IDs to prevent unnecessary rebuilds
      final shelterIdsKey = controller.followedShelterIds.take(10).join(',');
      return _FollowingPetsStream(key: ValueKey(shelterIdsKey), shelterIds: controller.followedShelterIds.take(10).toList());
    });
  }
}

// Separate StatefulWidget to prevent StreamBuilder from rebuilding unnecessarily
class _FollowingPetsStream extends StatefulWidget {
  final List<String> shelterIds;

  const _FollowingPetsStream({super.key, required this.shelterIds});

  @override
  State<_FollowingPetsStream> createState() => _FollowingPetsStreamState();
}

class _FollowingPetsStreamState extends State<_FollowingPetsStream> {
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
        } else if (data['imageUrls'] != null &&
            (data['imageUrls'] as List).isNotEmpty) {
          // Fallback to old imageUrls field
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
        'age': data['ageMonths']?.toString() ?? '0',
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pets')
          .where('shelterId', whereIn: widget.shelterIds)
          .where('adoptionStatus', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: LottieLoading(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                    'No pets available from followed shelters',
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
              return const Center(child: LottieLoading());
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
}
