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

  // Pagination for Exploring tab
  final RxList<Map<String, dynamic>> exploringPets = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingExploring = false.obs;
  final RxBool hasMoreExploring = true.obs;
  DocumentSnapshot? lastExploringDoc;
  static const int pageSize = 10;

  // Pagination for Following tab
  final RxList<Map<String, dynamic>> followingPets = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingFollowing = false.obs;
  final RxBool hasMoreFollowing = true.obs;
  DocumentSnapshot? lastFollowingDoc;

  @override
  void onInit() {
    super.onInit();
    _listenToFollowedShelters();
    loadExploringPets();
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
      // Reset and load following pets when shelters change
      if (selectedTab.value == 1) {
        resetFollowingPets();
        loadFollowingPets();
      }
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
    // Clear search when switching tabs
    if (textController.text.isNotEmpty) {
      textController.clear();
      searchController.clearResults();
    }
    // Load data for the selected tab if not loaded yet
    if (index == 1 && followingPets.isEmpty && followedShelterIds.isNotEmpty) {
      loadFollowingPets();
    }
  }

  void onSearchChanged(String value) {
    searchController.updateSearchQuery(value);
    if (value.trim().isNotEmpty) {
      searchController.searchPets();
    }
  }

  Future<void> loadExploringPets({bool refresh = false}) async {
    if (isLoadingExploring.value) return;
    if (!refresh && !hasMoreExploring.value) return;

    try {
      isLoadingExploring.value = true;

      if (refresh) {
        exploringPets.clear();
        lastExploringDoc = null;
        hasMoreExploring.value = true;
      }

      Query query = FirebaseFirestore.instance
          .collection('pets')
          .where('adoptionStatus', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (lastExploringDoc != null && !refresh) {
        query = query.startAfterDocument(lastExploringDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreExploring.value = false;
      } else {
        lastExploringDoc = snapshot.docs.last;
        
        final newPets = await _buildPetsWithPhotos(snapshot.docs);
        exploringPets.addAll(newPets);
        
        if (snapshot.docs.length < pageSize) {
          hasMoreExploring.value = false;
        }
      }
    } catch (e) {
      print('❌ Error loading exploring pets: $e');
      Get.snackbar('Error', 'Failed to load pets');
    } finally {
      isLoadingExploring.value = false;
    }
  }

  Future<void> loadFollowingPets({bool refresh = false}) async {
    if (followedShelterIds.isEmpty) {
      followingPets.clear();
      return;
    }

    if (isLoadingFollowing.value) return;
    if (!refresh && !hasMoreFollowing.value) return;

    try {
      isLoadingFollowing.value = true;

      if (refresh) {
        followingPets.clear();
        lastFollowingDoc = null;
        hasMoreFollowing.value = true;
      }

      // Take up to 10 shelter IDs for Firestore whereIn limit
      final shelterIdsToQuery = followedShelterIds.take(10).toList();

      Query query = FirebaseFirestore.instance
          .collection('pets')
          .where('shelterId', whereIn: shelterIdsToQuery)
          .where('adoptionStatus', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (lastFollowingDoc != null && !refresh) {
        query = query.startAfterDocument(lastFollowingDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreFollowing.value = false;
      } else {
        lastFollowingDoc = snapshot.docs.last;
        
        final newPets = await _buildPetsWithPhotos(snapshot.docs);
        followingPets.addAll(newPets);
        
        if (snapshot.docs.length < pageSize) {
          hasMoreFollowing.value = false;
        }
      }
    } catch (e) {
      print('❌ Error loading following pets: $e');
      Get.snackbar('Error', 'Failed to load following pets');
    } finally {
      isLoadingFollowing.value = false;
    }
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

  void resetFollowingPets() {
    followingPets.clear();
    lastFollowingDoc = null;
    hasMoreFollowing.value = true;
  }

  Future<void> refreshPets() async {
    if (selectedTab.value == 0) {
      await loadExploringPets(refresh: true);
    } else {
      await loadFollowingPets(refresh: true);
    }
  }
}

class AdoptView extends StatelessWidget {
  const AdoptView({super.key});

  Future<void> _refreshData() async {
    final AdoptController controller = Get.find<AdoptController>();
    await controller.refreshPets();
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
                              ? _buildExploringTab()
                              : _buildFollowingTab(),
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

  Widget _buildExploringTab() {
    final AdoptController controller = Get.find<AdoptController>();
    
    return Obx(() {
      if (controller.isLoadingExploring.value && controller.exploringPets.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: LottieLoading(),
          ),
        );
      }

      if (controller.exploringPets.isEmpty && !controller.isLoadingExploring.value) {
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

      return Column(
        children: [
          PetListWidget(pets: controller.exploringPets),
          if (controller.hasMoreExploring.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: controller.isLoadingExploring.value
                  ? const LottieLoading()
                  : OutlinedButton.icon(
                      onPressed: () => controller.loadExploringPets(),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Load More',
                        style: GoogleFonts.poppins(),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),
          if (!controller.hasMoreExploring.value && controller.exploringPets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No more pets to load',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      );
    });
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

  Widget _buildFollowingTab() {
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

      if (controller.isLoadingFollowing.value && controller.followingPets.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: LottieLoading(),
          ),
        );
      }

      if (controller.followingPets.isEmpty && !controller.isLoadingFollowing.value) {
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

      return Column(
        children: [
          PetListWidget(pets: controller.followingPets),
          if (controller.hasMoreFollowing.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: controller.isLoadingFollowing.value
                  ? const LottieLoading()
                  : OutlinedButton.icon(
                      onPressed: () => controller.loadFollowingPets(),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Load More',
                        style: GoogleFonts.poppins(),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),
          if (!controller.hasMoreFollowing.value && controller.followingPets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No more pets to load',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      );
    });
  }
}
