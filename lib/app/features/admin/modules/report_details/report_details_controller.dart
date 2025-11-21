import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/report.dart';
import '../../../../models/enums.dart';
import '../../../../services/report_service.dart';

class ReportDetailsController extends GetxController {
  final ReportService _reportService = ReportService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final report = Rxn<Report>();
  final reporterInfo = Rxn<Map<String, dynamic>>();
  final reportedInfo = Rxn<Map<String, dynamic>>();
  final adminNotesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['report'] != null) {
      report.value = args['report'] as Report;
      loadReportDetails();
    }
  }

  @override
  void onClose() {
    adminNotesController.dispose();
    super.onClose();
  }

  /// Load full report details including user/shelter info
  Future<void> loadReportDetails() async {
    if (report.value == null) return;

    try {
      isLoading.value = true;
      final details = await _reportService.getReportDetails(report.value!.reportId);
      
      if (details != null) {
        reporterInfo.value = details['reporterInfo'];
        reportedInfo.value = details['reportedInfo'];
      }
    } catch (e) {
      print('Error loading report details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update report status
  Future<void> updateStatus(ReportStatus status) async {
    if (report.value == null) return;

    try {
      isLoading.value = true;

      final success = await _reportService.updateReportStatus(
        reportId: report.value!.reportId,
        status: status,
        adminNotes: adminNotesController.text.trim().isEmpty 
            ? null 
            : adminNotesController.text.trim(),
      );

      if (success) {
        Get.dialog(
          AlertDialog(
            title: const Text('Success'),
            content: Text('Report status updated to ${status.value}'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to report list
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update report status'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error updating status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Suspend user with custom dates and reason
  Future<void> suspendUser(String uid, DateTime startDate, DateTime endDate, String reason) async {
    if (report.value == null || reportedInfo.value == null) return;

    try {
      isLoading.value = true;

      final reportedId = report.value!.reportedId;
      final collection = report.value!.entityType == EntityType.user 
          ? 'users' 
          : 'shelters';

      // Update account status to suspended
      await _firestore.collection(collection).doc(reportedId).update({
        'accountStatus': AccountStatus.suspended.value,
      });

      // Create suspension record
      final suspensionRef = await _firestore.collection('suspensions').add({
        'userId': reportedId,
        'reportId': report.value!.reportId,
        'reason': reason,
        'violationCategory': report.value!.violationCategory.value,
        'suspensionStart': Timestamp.fromDate(startDate),
        'suspensionEnd': Timestamp.fromDate(endDate),
        'suspensionStatus': 'active',
        'liftedBy': null,
        'liftedAt': null,
        'liftReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update suspension ID
      await suspensionRef.update({
        'suspensionId': suspensionRef.id,
      });

      // Update report status to resolved
      await updateStatus(ReportStatus.resolved);

      Get.dialog(
        AlertDialog(
          title: const Text('User Suspended'),
          content: const Text('The user has been suspended successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to report list
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error suspending user: $e');
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to suspend user: $e'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
