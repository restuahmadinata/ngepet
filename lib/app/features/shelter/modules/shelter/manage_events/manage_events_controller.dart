import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../routes/app_routes.dart';

class ManageEventsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final isLoading = true.obs;
  final events = <Map<String, dynamic>>[].obs;
  final filteredEvents = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final deletingEventId = ''.obs; // Track which event is being deleted

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  /// Load all events created by this shelter
  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('events')
          .where('shelterId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      events.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'eventId': doc.id,
          ...data,
        };
      }).toList();

      filteredEvents.value = events;
    } catch (e) {
      print('Error loading events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search events by title
  void searchEvents(String query) {
    searchQuery.value = query.toLowerCase();
    
    if (query.isEmpty) {
      filteredEvents.value = events;
    } else {
      filteredEvents.value = events.where((event) {
        final title = (event['eventTitle'] ?? '').toString().toLowerCase();
        final location = (event['location'] ?? '').toString().toLowerCase();
        
        return title.contains(searchQuery.value) ||
               location.contains(searchQuery.value);
      }).toList();
    }
  }

  /// Navigate to edit event page
  void editEvent(String eventId) async {
    final result = await Get.toNamed(
      AppRoutes.shelterEditEvent,
      arguments: eventId,
    );
    
    // Refresh list if edit was successful
    if (result == true) {
      await loadEvents();
    }
  }

  /// Delete event directly without confirmation
  Future<void> deleteEvent(String eventId, String eventTitle) async {
    await _performDelete(eventId, eventTitle);
  }

  /// Perform the actual deletion
  Future<void> _performDelete(String eventId, String eventTitle) async {
    try {
      deletingEventId.value = eventId;
      
      await _firestore.collection('events').doc(eventId).delete();
      
      await loadEvents();
    } catch (e) {
      print('Error deleting event: $e');
    } finally {
      deletingEventId.value = '';
    }
  }

  /// Navigate to add new event
  void addNewEvent() {
    Get.toNamed(AppRoutes.shelterAddEvent);
  }

  /// Refresh events list
  Future<void> refreshEvents() async {
    await loadEvents();
  }
}
