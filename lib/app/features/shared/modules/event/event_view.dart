import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../common/widgets/lottie_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import '../../../../common/widgets/event_list.dart';
import '../../../../services/follower_service.dart';
import '../../../../common/controllers/search_controller.dart' as search;

class EventController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following
  final FollowerService _followerService = FollowerService();
  final RxList<String> followedShelterIds = <String>[].obs;
  final searchController = Get.put(search.SearchController(), tag: 'event');
  final textController = TextEditingController();

  // Pagination for Exploring tab
  final RxList<Map<String, dynamic>> exploringEvents = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingExploring = false.obs;
  final RxBool hasMoreExploring = true.obs;
  DocumentSnapshot? lastExploringDoc;
  static const int pageSize = 10;

  // Pagination for Following tab
  final RxList<Map<String, dynamic>> followingEvents = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingFollowing = false.obs;
  final RxBool hasMoreFollowing = true.obs;
  DocumentSnapshot? lastFollowingDoc;

  @override
  void onInit() {
    super.onInit();
    _listenToFollowedShelters();
    loadExploringEvents();
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
      // Reset and load following events when shelters change
      if (selectedTab.value == 1) {
        resetFollowingEvents();
        loadFollowingEvents();
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
    if (index == 1 && followingEvents.isEmpty && followedShelterIds.isNotEmpty) {
      loadFollowingEvents();
    }
  }

  void onSearchChanged(String value) {
    searchController.updateSearchQuery(value);
    if (value.trim().isNotEmpty) {
      searchController.searchEvents();
    }
  }

  Future<void> loadExploringEvents({bool refresh = false}) async {
    if (isLoadingExploring.value) return;
    if (!refresh && !hasMoreExploring.value) return;

    try {
      isLoadingExploring.value = true;

      if (refresh) {
        exploringEvents.clear();
        lastExploringDoc = null;
        hasMoreExploring.value = true;
      }

      Query query = FirebaseFirestore.instance
          .collection('events')
          .orderBy('dateTime', descending: false)
          .limit(pageSize);

      if (lastExploringDoc != null && !refresh) {
        query = query.startAfterDocument(lastExploringDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreExploring.value = false;
      } else {
        lastExploringDoc = snapshot.docs.last;
        
        final newEvents = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String imageUrl = 'https://via.placeholder.com/400x200?text=Event';
          if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List).first.toString();
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
          }

          return {
            'eventId': doc.id,
            'shelterId': data['shelterId']?.toString() ?? '',
            'imageUrl': imageUrl,
            'eventTitle': (data['eventTitle'] ?? data['title'] ?? 'Event Title').toString(),
            'title': (data['eventTitle'] ?? data['title'] ?? 'Event Title').toString(),
            'eventDate': (data['eventDate'] ?? data['date'] ?? 'TBA').toString(),
            'date': (data['eventDate'] ?? data['date'] ?? 'TBA').toString(),
            'eventTime': (data['eventTime'] ?? data['startTime'] ?? data['time'] ?? '').toString(),
            'time': (data['eventTime'] ?? data['startTime'] ?? data['time'] ?? '').toString(),
            'shelterName': (data['shelterName'] ?? data['shelter'] ?? 'Shelter').toString(),
            'shelter': (data['shelterName'] ?? data['shelter'] ?? 'Shelter').toString(),
            'location': (data['location'] ?? 'Location').toString(),
            'eventDescription': (data['eventDescription'] ?? data['description'] ?? 'Event description').toString(),
            'description': (data['eventDescription'] ?? data['description'] ?? 'Event description').toString(),
            'imageUrls': data['imageUrls'] ?? [imageUrl],
          };
        }).toList();

        exploringEvents.addAll(newEvents);
        
        if (snapshot.docs.length < pageSize) {
          hasMoreExploring.value = false;
        }
      }
    } catch (e) {
      print('❌ Error loading exploring events: $e');
      Get.snackbar('Error', 'Failed to load events');
    } finally {
      isLoadingExploring.value = false;
    }
  }

  Future<void> loadFollowingEvents({bool refresh = false}) async {
    if (followedShelterIds.isEmpty) {
      followingEvents.clear();
      return;
    }

    if (isLoadingFollowing.value) return;
    if (!refresh && !hasMoreFollowing.value) return;

    try {
      isLoadingFollowing.value = true;

      if (refresh) {
        followingEvents.clear();
        lastFollowingDoc = null;
        hasMoreFollowing.value = true;
      }

      // Take up to 10 shelter IDs for Firestore whereIn limit
      final shelterIdsToQuery = followedShelterIds.take(10).toList();

      Query query = FirebaseFirestore.instance
          .collection('events')
          .where('shelterId', whereIn: shelterIdsToQuery)
          .orderBy('dateTime', descending: false)
          .limit(pageSize);

      if (lastFollowingDoc != null && !refresh) {
        query = query.startAfterDocument(lastFollowingDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreFollowing.value = false;
      } else {
        lastFollowingDoc = snapshot.docs.last;
        
        final newEvents = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String imageUrl = 'https://via.placeholder.com/400x200?text=Event';
          if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List).first.toString();
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
          }

          return {
            'eventId': doc.id,
            'shelterId': data['shelterId']?.toString() ?? '',
            'imageUrl': imageUrl,
            'eventTitle': (data['eventTitle'] ?? data['title'] ?? 'Event Title').toString(),
            'title': (data['eventTitle'] ?? data['title'] ?? 'Event Title').toString(),
            'eventDate': (data['eventDate'] ?? data['date'] ?? 'TBA').toString(),
            'date': (data['eventDate'] ?? data['date'] ?? 'TBA').toString(),
            'eventTime': (data['eventTime'] ?? data['startTime'] ?? data['time'] ?? '').toString(),
            'time': (data['eventTime'] ?? data['startTime'] ?? data['time'] ?? '').toString(),
            'shelterName': (data['shelterName'] ?? data['shelter'] ?? 'Shelter').toString(),
            'shelter': (data['shelterName'] ?? data['shelter'] ?? 'Shelter').toString(),
            'location': (data['location'] ?? 'Location').toString(),
            'eventDescription': (data['eventDescription'] ?? data['description'] ?? 'Event description').toString(),
            'description': (data['eventDescription'] ?? data['description'] ?? 'Event description').toString(),
            'imageUrls': data['imageUrls'] ?? [imageUrl],
          };
        }).toList();

        followingEvents.addAll(newEvents);
        
        if (snapshot.docs.length < pageSize) {
          hasMoreFollowing.value = false;
        }
      }
    } catch (e) {
      print('❌ Error loading following events: $e');
      Get.snackbar('Error', 'Failed to load following events');
    } finally {
      isLoadingFollowing.value = false;
    }
  }

  void resetFollowingEvents() {
    followingEvents.clear();
    lastFollowingDoc = null;
    hasMoreFollowing.value = true;
  }

  Future<void> refreshEvents() async {
    if (selectedTab.value == 0) {
      await loadExploringEvents(refresh: true);
    } else {
      await loadFollowingEvents(refresh: true);
    }
  }
}

class EventView extends StatelessWidget {
  const EventView({super.key});

  Future<void> _refreshData() async {
    final EventController controller = Get.find<EventController>();
    await controller.refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.put(EventController());

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  RectangleSearchBar(
                    hintText: 'Search events...',
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
    final EventController controller = Get.find<EventController>();
    
    return Obx(() {
      if (controller.isLoadingExploring.value && controller.exploringEvents.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: LottieLoading(),
          ),
        );
      }

      if (controller.exploringEvents.isEmpty && !controller.isLoadingExploring.value) {
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

      return Column(
        children: [
          EventList(events: controller.exploringEvents),
          if (controller.hasMoreExploring.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: controller.isLoadingExploring.value
                  ? const LottieLoading()
                  : OutlinedButton.icon(
                      onPressed: () => controller.loadExploringEvents(),
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
          if (!controller.hasMoreExploring.value && controller.exploringEvents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No more events to load',
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
    final EventController controller = Get.find<EventController>();
    
    return Obx(() {
      if (controller.searchController.isSearching.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: LottieLoading(),
          ),
        );
      }

      if (controller.searchController.eventResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No events found',
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
          EventList(events: controller.searchController.eventResults),
          if (controller.searchController.hasMoreEvents.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: controller.searchController.isLoadingMore.value
                  ? const LottieLoading()
                  : OutlinedButton(
                      onPressed: () => controller.searchController.loadMoreEvents(),
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
    final EventController controller = Get.find<EventController>();
    
    return Obx(() {
      if (controller.followedShelterIds.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
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
                  'Follow shelters to see their events here',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.isLoadingFollowing.value && controller.followingEvents.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: LottieLoading(),
          ),
        );
      }

      if (controller.followingEvents.isEmpty && !controller.isLoadingFollowing.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.event, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No events available from followed shelters',
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
          EventList(events: controller.followingEvents),
          if (controller.hasMoreFollowing.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: controller.isLoadingFollowing.value
                  ? const LottieLoading()
                  : OutlinedButton.icon(
                      onPressed: () => controller.loadFollowingEvents(),
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
          if (!controller.hasMoreFollowing.value && controller.followingEvents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No more events to load',
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