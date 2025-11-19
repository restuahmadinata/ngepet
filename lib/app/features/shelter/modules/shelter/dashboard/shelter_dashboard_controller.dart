import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/follower_service.dart';

class ShelterDashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FollowerService _followerService = FollowerService();

  // Observable variables
  final shelterName = ''.obs;
  final petCount = 0.obs;
  final eventCount = 0.obs;
  final adoptionRequestCount = 0.obs;
  final followerCount = 0.obs;
  final isLoading = true.obs;

  // Time series data for charts (date -> count)
  final adoptionRequestTimeSeriesData = <DateTime, int>{}.obs;
  final followerTimeSeriesData = <DateTime, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadShelterData();
    _loadStats();
    _loadTimeSeriesData();
  }

  @override
  void onReady() {
    super.onReady();
    refreshData();
  }

  // Load shelter basic data
  Future<void> _loadShelterData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final shelterDoc = await _firestore.collection('shelters').doc(user.uid).get();
      if (shelterDoc.exists) {
        final data = shelterDoc.data();
        shelterName.value = data?['shelterName'] ?? 'Shelter';
      }
    } catch (e) {
      print('Error loading shelter data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load dashboard statistics
  Future<void> _loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final petsQuery = await _firestore
          .collection('pets')
          .where('shelterId', isEqualTo: user.uid)
          .get();
      petCount.value = petsQuery.docs.length;

      final eventsQuery = await _firestore
          .collection('events')
          .where('shelterId', isEqualTo: user.uid)
          .get();
      eventCount.value = eventsQuery.docs.length;

      final adoptionQuery = await _firestore
          .collection('adoption_applications')
          .where('shelterId', isEqualTo: user.uid)
          .where('applicationStatus', isEqualTo: 'pending')
          .get();
      adoptionRequestCount.value = adoptionQuery.docs.length;

      followerCount.value = await _followerService.getFollowerCount(user.uid);
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  // Navigation methods
  void goToAddPet() {
    Get.toNamed('/shelter/add-pet');
  }

  void goToAddEvent() {
    Get.toNamed('/shelter/add-event');
  }

  void goToFollowers() {
    final user = _auth.currentUser;
    if (user != null) {
      Get.toNamed('/shelter/followers', arguments: user.uid)?.then((_) {
        refreshData();
      });
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([_loadShelterData(), _loadStats(), _loadTimeSeriesData()]);
  }

  // Load time series data for charts
  Future<void> _loadTimeSeriesData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get adoption requests with createdAt timestamp for this shelter
      final adoptionQuery = await _firestore
          .collection('adoption_applications')
          .where('shelterId', isEqualTo: user.uid)
          .get();
      
      final adoptionDataMap = <DateTime, int>{};
      
      for (var doc in adoptionQuery.docs) {
        final data = doc.data();
        DateTime date;
        
        if (data['createdAt'] != null) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else if (data['appliedAt'] != null) {
          date = (data['appliedAt'] as Timestamp).toDate();
        } else {
          date = DateTime.now();
        }
        
        // Group by day (remove time component)
        final dateOnly = DateTime(date.year, date.month, date.day);
        adoptionDataMap[dateOnly] = (adoptionDataMap[dateOnly] ?? 0) + 1;
      }

      adoptionRequestTimeSeriesData.value = adoptionDataMap;

      // Get followers with followedAt timestamp for this shelter
      final followersQuery = await _firestore
          .collection('followers')
          .where('shelterId', isEqualTo: user.uid)
          .get();
      
      final followerDataMap = <DateTime, int>{};
      
      for (var doc in followersQuery.docs) {
        final data = doc.data();
        DateTime date;
        
        if (data['followedAt'] != null) {
          date = (data['followedAt'] as Timestamp).toDate();
        } else if (data['createdAt'] != null) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else {
          date = DateTime.now();
        }
        
        final dateOnly = DateTime(date.year, date.month, date.day);
        followerDataMap[dateOnly] = (followerDataMap[dateOnly] ?? 0) + 1;
      }

      followerTimeSeriesData.value = followerDataMap;

    } catch (e) {
      print('Error loading time series data: $e');
    }
  }
}
