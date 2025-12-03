import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/pet_photo_helper.dart';

class SearchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  
  // For pets
  final RxList<Map<String, dynamic>> petResults = <Map<String, dynamic>>[].obs;
  final RxBool hasMorePets = true.obs;
  DocumentSnapshot? _lastPetDoc;
  
  // For events
  final RxList<Map<String, dynamic>> eventResults = <Map<String, dynamic>>[].obs;
  final RxBool hasMoreEvents = true.obs;
  DocumentSnapshot? _lastEventDoc;
  
  final int _pageSize = 10;

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      clearResults();
    }
  }

  void clearResults() {
    petResults.clear();
    eventResults.clear();
    hasMorePets.value = true;
    hasMoreEvents.value = true;
    _lastPetDoc = null;
    _lastEventDoc = null;
    isSearching.value = false;
  }

  Future<void> searchPets({bool loadMore = false}) async {
    if (searchQuery.value.trim().isEmpty) return;
    
    if (loadMore && !hasMorePets.value) return;
    
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isSearching.value = true;
        petResults.clear();
        _lastPetDoc = null;
      }

      Query query = _firestore
          .collection('pets')
          .where('adoptionStatus', isEqualTo: 'available')
          .limit(_pageSize);

      if (loadMore && _lastPetDoc != null) {
        query = query.startAfterDocument(_lastPetDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMorePets.value = false;
        return;
      }

      _lastPetDoc = snapshot.docs.last;
      hasMorePets.value = snapshot.docs.length == _pageSize;

      // Filter by search query (client-side filtering)
      final searchLower = searchQuery.value.toLowerCase();
      final List<Map<String, dynamic>> newPets = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final petName = (data['petName'] ?? '').toString().toLowerCase();
        final breed = (data['breed'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();
        
        if (petName.contains(searchLower) || 
            breed.contains(searchLower) || 
            category.contains(searchLower)) {
          
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
              imageUrls = (data['imageUrls'] as List)
                  .map((e) => e.toString())
                  .toList();
              imageUrl = imageUrls[0];
            }
          } catch (e) {
            print('Error fetching photos for pet ${doc.id}: $e');
          }

          newPets.add({
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
      }

      if (loadMore) {
        petResults.addAll(newPets);
      } else {
        petResults.value = newPets;
      }
    } catch (e) {
      print('Error searching pets: $e');
      Get.snackbar('Error', 'Failed to search pets');
    } finally {
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> searchEvents({bool loadMore = false}) async {
    if (searchQuery.value.trim().isEmpty) return;
    
    if (loadMore && !hasMoreEvents.value) return;
    
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isSearching.value = true;
        eventResults.clear();
        _lastEventDoc = null;
      }

      // Get current time for filtering upcoming events
      final now = Timestamp.fromDate(DateTime.now());

      Query query = _firestore
          .collection('events')
          .where('dateTime', isGreaterThanOrEqualTo: now)
          .orderBy('dateTime', descending: false)
          .limit(_pageSize);

      if (loadMore && _lastEventDoc != null) {
        query = query.startAfterDocument(_lastEventDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreEvents.value = false;
        return;
      }

      _lastEventDoc = snapshot.docs.last;
      hasMoreEvents.value = snapshot.docs.length == _pageSize;

      // Filter by search query (client-side filtering)
      final searchLower = searchQuery.value.toLowerCase();
      final List<Map<String, dynamic>> newEvents = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final eventTitle = (data['eventTitle'] ?? '').toString().toLowerCase();
        final location = (data['location'] ?? '').toString().toLowerCase();
        final description = (data['eventDescription'] ?? '').toString().toLowerCase();
        
        if (eventTitle.contains(searchLower) || 
            location.contains(searchLower) || 
            description.contains(searchLower)) {
          
          String imageUrl = 'https://via.placeholder.com/400x200?text=Event';
          if (data['imageUrls'] != null &&
              (data['imageUrls'] as List).isNotEmpty) {
            imageUrl = (data['imageUrls'] as List).first.toString();
          } else if (data['imageUrl'] != null) {
            imageUrl = data['imageUrl'].toString();
          }

          newEvents.add({
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
          });
        }
      }

      if (loadMore) {
        eventResults.addAll(newEvents);
      } else {
        eventResults.value = newEvents;
      }
    } catch (e) {
      print('Error searching events: $e');
      Get.snackbar('Error', 'Failed to search events');
    } finally {
      isSearching.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> searchAll() async {
    await Future.wait([
      searchPets(),
      searchEvents(),
    ]);
  }

  Future<void> loadMorePets() async {
    await searchPets(loadMore: true);
  }

  Future<void> loadMoreEvents() async {
    await searchEvents(loadMore: true);
  }
}
