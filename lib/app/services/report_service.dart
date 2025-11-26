import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report.dart';
import '../models/enums.dart';

/// Service for managing reports
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit a new report
  Future<String?> submitReport({
    required String reportedId,
    required EntityType entityType,
    required ViolationCategory violationCategory,
    required String reportDescription,
    String? incidentLocation,
    List<String>? evidenceAttachments,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return null;
      }

      final reportData = {
        'reporterId': userId,
        'reportedId': reportedId,
        'entityType': entityType.value,
        'violationCategory': violationCategory.value,
        'reportDescription': reportDescription,
        'incidentLocation': incidentLocation,
        'evidenceAttachments': evidenceAttachments ?? [],
        'reportStatus': ReportStatus.pending.value,
        'reportDate': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('reports').add(reportData);
      print('✅ Report submitted successfully');
      return docRef.id;
    } catch (e) {
      print('❌ Error submitting report: $e');
      return null;
    }
  }

  /// Get all reports (for admin)
  Stream<List<Report>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
    });
  }

  /// Get reports by status
  Stream<List<Report>> getReportsByStatus(ReportStatus status) {
    return _firestore
        .collection('reports')
        .where('reportStatus', isEqualTo: status.value)
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      // Sort in memory by reportDate descending
      reports.sort((a, b) {
        if (a.reportDate == null && b.reportDate == null) return 0;
        if (a.reportDate == null) return 1;
        if (b.reportDate == null) return -1;
        return b.reportDate!.compareTo(a.reportDate!);
      });
      return reports;
    });
  }

  /// Update report status
  Future<bool> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNotes,
  }) async {
    try {
      final adminId = _auth.currentUser?.uid;
      if (adminId == null) {
        print('Error: Admin not authenticated');
        return false;
      }

      final updateData = {
        'reportStatus': status.value,
        'adminId': adminId,
        'reviewedDate': FieldValue.serverTimestamp(),
      };

      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }

      await _firestore.collection('reports').doc(reportId).update(updateData);
      print('✅ Report status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating report status: $e');
      return false;
    }
  }

  /// Get report details with related entity information
  Future<Map<String, dynamic>?> getReportDetails(String reportId) async {
    try {
      final reportDoc = await _firestore.collection('reports').doc(reportId).get();
      if (!reportDoc.exists) return null;

      final report = Report.fromFirestore(reportDoc);
      
      // Get reporter information - check both users and shelters
      Map<String, dynamic>? reporterInfo;
      final reporterUserDoc = await _firestore.collection('users').doc(report.reporterId).get();
      if (reporterUserDoc.exists) {
        reporterInfo = reporterUserDoc.data();
        reporterInfo?['id'] = reporterUserDoc.id;
      } else {
        // Try shelters collection
        final reporterShelterDoc = await _firestore.collection('shelters').doc(report.reporterId).get();
        if (reporterShelterDoc.exists) {
          reporterInfo = reporterShelterDoc.data();
          reporterInfo?['id'] = reporterShelterDoc.id;
        }
      }

      // Get reported entity information
      Map<String, dynamic>? reportedInfo;
      if (report.entityType == EntityType.user) {
        final userDoc = await _firestore.collection('users').doc(report.reportedId).get();
        if (userDoc.exists) {
          reportedInfo = userDoc.data();
          reportedInfo?['id'] = userDoc.id;
        }
      } else if (report.entityType == EntityType.shelter) {
        final shelterDoc = await _firestore.collection('shelters').doc(report.reportedId).get();
        if (shelterDoc.exists) {
          reportedInfo = shelterDoc.data();
          reportedInfo?['id'] = shelterDoc.id;
        }
      }

      return {
        'report': report,
        'reporterInfo': reporterInfo,
        'reportedInfo': reportedInfo,
      };
    } catch (e) {
      print('❌ Error getting report details: $e');
      return null;
    }
  }
}
