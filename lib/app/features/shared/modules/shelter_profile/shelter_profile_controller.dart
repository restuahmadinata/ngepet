import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/shelter.dart';
import '../pet_detail/pet_detail_view.dart';
import '../event_detail/event_detail_view.dart';

class ShelterProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable variables
  final Rx<Shelter?> shelter = Rx<Shelter?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isLoadingPets = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxInt selectedTab = 0.obs;
  final RxList<Map<String, dynamic>> pets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;

  String? shelterId;

  @override
  void onInit() {
    super.onInit();
    
    // Get shelterId from arguments
    if (Get.arguments != null) {
      if (Get.arguments is String) {
        shelterId = Get.arguments;
      } else if (Get.arguments is Map && Get.arguments['shelterId'] != null) {
        shelterId = Get.arguments['shelterId'];
      }
    }

    if (shelterId != null) {
      loadShelterData();
    } else {
      isLoading.value = false;
    }

    // Listen to tab changes to load data
    ever(selectedTab, (_) {
      if (selectedTab.value == 0 && pets.isEmpty) {
        loadPets();
      } else if (selectedTab.value == 1 && events.isEmpty) {
        loadEvents();
      }
    });
  }

  /// Load shelter data from Firestore
  Future<void> loadShelterData() async {
    try {
      isLoading.value = true;
      print('🔍 Loading shelter data for: $shelterId');

      final doc = await _firestore.collection('shelters').doc(shelterId).get();

      if (doc.exists) {
        print('✅ Shelter found: ${doc.data()?['shelterName']}');
        shelter.value = Shelter.fromFirestore(doc);
        
        // Load pets by default
        await loadPets();
      } else {
        print('❌ Shelter not found in Firestore');
        Get.snackbar(
          'Error',
          'Shelter not found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error loading shelter: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load shelter data: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally{
      isLoading.value = false;
    }
  }

  /// Load pets from this shelter
  Future<void> loadPets() async {
    if (shelterId == null) {
      print('❌ ShelterId is null, cannot load pets');
      return;
    }

    try {
      isLoadingPets.value = true;
      print('🔍 Loading pets for shelter: $shelterId');

      // Try simpler query first - just filter by shelterId
      final querySnapshot = await _firestore
          .collection('pets')
          .where('shelterId', isEqualTo: shelterId)
          .get();

      print('✅ Found ${querySnapshot.docs.length} pets');

      pets.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('📦 Pet data: ${data['petName']} - status: ${data['adoptionStatus']}');
        return {
          'id': doc.id,
          'petId': doc.id,
          ...data,
        };
      }).toList();
      
      print('✅ Pets loaded successfully: ${pets.length} pets');
    } catch (e, stackTrace) {
      print('❌ Error loading pets: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load pet data: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingPets.value = false;
    }
  }

  /// Load events from this shelter
  Future<void> loadEvents() async {
    if (shelterId == null) {
      print('❌ ShelterId is null, cannot load events');
      return;
    }

    try {
      isLoadingEvents.value = true;
      print('🔍 Loading events for shelter: $shelterId');

      // Try simpler query first - just filter by shelterId
      final querySnapshot = await _firestore
          .collection('events')
          .where('shelterId', isEqualTo: shelterId)
          .get();

      print('✅ Found ${querySnapshot.docs.length} events');

      events.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('📦 Event data: ${data['eventTitle']}');
        return {
          'id': doc.id,
          'eventId': doc.id,
          ...data,
        };
      }).toList();
      
      print('✅ Events loaded successfully: ${events.length} events');
    } catch (e, stackTrace) {
      print('❌ Error loading events: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load event data: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingEvents.value = false;
    }
  }

  /// Navigate to pet detail
  void navigateToPetDetail(Map<String, dynamic> petData) {
    Get.to(
      () => PetDetailView(petData: petData),
      transition: Transition.rightToLeft,
    );
  }

  /// Navigate to event detail
  void navigateToEventDetail(Map<String, dynamic> eventData) {
    Get.to(
      () => EventDetailView(eventData: eventData),
      transition: Transition.rightToLeft,
    );
  }
}
