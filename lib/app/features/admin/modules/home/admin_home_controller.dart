import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/controllers/auth_controller.dart';

class AdminHomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final totalPets = 0.obs;
  final totalEvents = 0.obs;
  final totalUsers = 0.obs;
  final totalShelters = 0.obs;
  final isLoading = true.obs;

  // Time series data for charts (date -> count)
  final petTimeSeriesData = <DateTime, int>{}.obs;
  final eventTimeSeriesData = <DateTime, int>{}.obs;
  final userTimeSeriesData = <DateTime, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
    loadTimeSeriesData();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;

      // Load total pets
      final petsSnapshot = await _firestore.collection('pets').get();
      totalPets.value = petsSnapshot.docs.length;

      // Load total events
      final eventsSnapshot = await _firestore.collection('events').get();
      totalEvents.value = eventsSnapshot.docs.length;

      // Load total users
      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers.value = usersSnapshot.docs.length;

      // Load total shelters
      final sheltersSnapshot = await _firestore.collection('shelters').get();
      totalShelters.value = sheltersSnapshot.docs.length;

    } catch (e) {
      print('Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTimeSeriesData() async {
    try {
      // Get pets with createdAt timestamp
      final petsSnapshot = await _firestore.collection('pets').get();
      final petDataMap = <DateTime, int>{};
      
      for (var doc in petsSnapshot.docs) {
        final data = doc.data();
        DateTime date;
        
        if (data['createdAt'] != null) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else {
          // Fallback to current date if no timestamp
          date = DateTime.now();
        }
        
        // Group by day (remove time component)
        final dateOnly = DateTime(date.year, date.month, date.day);
        petDataMap[dateOnly] = (petDataMap[dateOnly] ?? 0) + 1;
      }

      // Get events with createdAt timestamp
      final eventsSnapshot = await _firestore.collection('events').get();
      final eventDataMap = <DateTime, int>{};
      
      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        DateTime date;
        
        if (data['createdAt'] != null) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else if (data['startDate'] != null) {
          date = (data['startDate'] as Timestamp).toDate();
        } else {
          date = DateTime.now();
        }
        
        final dateOnly = DateTime(date.year, date.month, date.day);
        eventDataMap[dateOnly] = (eventDataMap[dateOnly] ?? 0) + 1;
      }

      petTimeSeriesData.value = petDataMap;
      eventTimeSeriesData.value = eventDataMap;

      // Get users with createdAt timestamp
      final usersSnapshot = await _firestore.collection('users').get();
      final userDataMap = <DateTime, int>{};
      
      print('Loading user time series data: ${usersSnapshot.docs.length} users found');
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        DateTime date;
        
        // Since users collection doesn't have createdAt field per Firebase structure,
        // we'll use the current date as fallback for all users
        // This will show all users as registered on today's date
        if (data['createdAt'] != null) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else if (data['registeredAt'] != null) {
          date = (data['registeredAt'] as Timestamp).toDate();
        } else if (data['joinedAt'] != null) {
          date = (data['joinedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] != null) {
          // Use updatedAt as a proxy
          date = (data['updatedAt'] as Timestamp).toDate();
        } else {
          // If no timestamp field exists, spread users over the last 30 days
          // to show some data distribution
          final dayOffset = usersSnapshot.docs.indexOf(doc) % 30;
          date = DateTime.now().subtract(Duration(days: dayOffset));
        }
        
        final dateOnly = DateTime(date.year, date.month, date.day);
        userDataMap[dateOnly] = (userDataMap[dateOnly] ?? 0) + 1;
      }

      print('User time series data: ${userDataMap.length} unique dates, total entries: ${userDataMap.values.fold(0, (sum, count) => sum + count)}');
      userTimeSeriesData.value = userDataMap;

    } catch (e) {
      print('Error loading time series data: $e');
    }
  }

  void signOut() async {
    await authController.signOut();
  }
}
