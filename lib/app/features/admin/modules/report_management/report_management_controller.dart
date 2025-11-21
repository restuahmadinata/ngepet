import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/report.dart';
import '../../../../models/enums.dart';
import '../../../../services/report_service.dart';

class ReportManagementController extends GetxController {
  final ReportService _reportService = ReportService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final reports = <Report>[].obs;
  final selectedStatus = Rxn<ReportStatus>();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  /// Load all reports or filter by status
  void loadReports() {
    isLoading.value = true;
    
    if (selectedStatus.value == null) {
      // Load all reports
      _reportService.getAllReports().listen((reportList) {
        reports.value = reportList;
        isLoading.value = false;
      }, onError: (error) {
        print('Error loading reports: $error');
        isLoading.value = false;
      });
    } else {
      // Load reports by status
      _reportService.getReportsByStatus(selectedStatus.value!).listen((reportList) {
        reports.value = reportList;
        isLoading.value = false;
      }, onError: (error) {
        print('Error loading reports: $error');
        isLoading.value = false;
      });
    }
  }

  /// Filter reports by status
  void filterByStatus(ReportStatus? status) {
    selectedStatus.value = status;
    loadReports();
  }

  /// Get filtered reports based on search query
  List<Report> get filteredReports {
    if (searchQuery.value.isEmpty) {
      return reports;
    }
    
    final query = searchQuery.value.toLowerCase();
    return reports.where((report) {
      return report.reporterId.toLowerCase().contains(query) ||
             report.reportedId.toLowerCase().contains(query) ||
             report.reportDescription.toLowerCase().contains(query);
    }).toList();
  }

  /// Navigate to report details
  void viewReportDetails(Report report) {
    Get.toNamed('/admin/report-details', arguments: {'report': report});
  }

  /// Get count for each status
  Future<Map<String, int>> getStatusCounts() async {
    try {
      final snapshot = await _firestore.collection('reports').get();
      final counts = <String, int>{
        'all': snapshot.docs.length,
        'pending': 0,
        'reviewing': 0,
        'resolved': 0,
        'rejected': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['reportStatus'] as String?;
        if (status != null && counts.containsKey(status)) {
          counts[status] = (counts[status] ?? 0) + 1;
        }
      }

      return counts;
    } catch (e) {
      print('Error getting status counts: $e');
      return {};
    }
  }
}
