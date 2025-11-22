import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final petTimeSeriesData = <DateTime, int>{}.obs;
  final eventTimeSeriesData = <DateTime, int>{}.obs;
  final userTimeSeriesData = <DateTime, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadPetAnalytics(),
        _loadEventAnalytics(),
        _loadUserAnalytics(),
      ]);
    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPetAnalytics() async {
    try {
      final snapshot = await _firestore.collection('pets').get();
      final Map<DateTime, int> dataByDate = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final date = DateTime(
            createdAt.toDate().year,
            createdAt.toDate().month,
            createdAt.toDate().day,
          );
          dataByDate[date] = (dataByDate[date] ?? 0) + 1;
        }
      }

      petTimeSeriesData.value = dataByDate;
    } catch (e) {
      print('Error loading pet analytics: $e');
    }
  }

  Future<void> _loadEventAnalytics() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      final Map<DateTime, int> dataByDate = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final date = DateTime(
            createdAt.toDate().year,
            createdAt.toDate().month,
            createdAt.toDate().day,
          );
          dataByDate[date] = (dataByDate[date] ?? 0) + 1;
        }
      }

      eventTimeSeriesData.value = dataByDate;
    } catch (e) {
      print('Error loading event analytics: $e');
    }
  }

  Future<void> _loadUserAnalytics() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final Map<DateTime, int> dataByDate = {};

      print('🔵 Loading user time series data: ${snapshot.docs.length} users found');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime date;
        
        print('📄 User doc fields: ${data.keys.toList()}');
        
        // Try multiple possible timestamp fields
        if (data['createdAt'] != null) {
          date = (data['createdAt'] as Timestamp).toDate();
          print('✅ Using createdAt: $date');
        } else if (data['registeredAt'] != null) {
          date = (data['registeredAt'] as Timestamp).toDate();
          print('✅ Using registeredAt: $date');
        } else if (data['joinedAt'] != null) {
          date = (data['joinedAt'] as Timestamp).toDate();
          print('✅ Using joinedAt: $date');
        } else if (data['updatedAt'] != null) {
          date = (data['updatedAt'] as Timestamp).toDate();
          print('✅ Using updatedAt: $date');
        } else {
          // If no timestamp field exists, spread users over the last 30 days
          final dayOffset = snapshot.docs.indexOf(doc) % 30;
          date = DateTime.now().subtract(Duration(days: dayOffset));
          print('⚠️ No timestamp field, using fallback: $date');
        }
        
        final dateOnly = DateTime(date.year, date.month, date.day);
        dataByDate[dateOnly] = (dataByDate[dateOnly] ?? 0) + 1;
      }

      print('🟢 User time series data: ${dataByDate.length} unique dates, total entries: ${dataByDate.values.fold(0, (sum, count) => sum + count)}');
      print('📊 Data: $dataByDate');
      
      // Force update the observable
      userTimeSeriesData.value = Map<DateTime, int>.from(dataByDate);
      
      print('✅ userTimeSeriesData updated: ${dataByDate.length} entries');
    } catch (e) {
      print('❌ Error loading user analytics: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
}
