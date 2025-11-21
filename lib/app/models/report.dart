import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Model for Report
/// Collection: reports/{reportId}
class Report {
  final String reportId;
  final String reporterId;
  final String reportedId;
  final EntityType entityType; // user, shelter, pet
  final ViolationCategory violationCategory; // fraud, animal_abuse, spam, inappropriate_content
  final String reportDescription;
  final String? incidentLocation;
  final List<String> evidenceAttachments; // Array of evidence image URLs
  final ReportStatus reportStatus; // pending, reviewing, resolved, rejected
  final String? adminId;
  final String? adminNotes;
  final DateTime? reportDate;
  final DateTime? reviewedDate;

  Report({
    required this.reportId,
    required this.reporterId,
    required this.reportedId,
    required this.entityType,
    required this.violationCategory,
    required this.reportDescription,
    this.incidentLocation,
    this.evidenceAttachments = const [],
    this.reportStatus = ReportStatus.pending,
    this.adminId,
    this.adminNotes,
    this.reportDate,
    this.reviewedDate,
  });

  /// Factory constructor to create Report from Firestore document
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Report(
      reportId: doc.id,
      reporterId: data['reporterId'] ?? '',
      reportedId: data['reportedId'] ?? '',
      entityType: EntityType.fromString(data['entityType']),
      violationCategory: ViolationCategory.fromString(data['violationCategory']),
      reportDescription: data['reportDescription'] ?? '',
      incidentLocation: data['incidentLocation'],
      evidenceAttachments: data['evidenceAttachments'] != null 
          ? List<String>.from(data['evidenceAttachments']) 
          : [],
      reportStatus: ReportStatus.fromString(data['reportStatus']),
      adminId: data['adminId'],
      adminNotes: data['adminNotes'],
      reportDate: data['reportDate'] != null
          ? (data['reportDate'] as Timestamp).toDate()
          : null,
      reviewedDate: data['reviewedDate'] != null
          ? (data['reviewedDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Factory constructor to create Report from Map
  factory Report.fromMap(Map<String, dynamic> data, String id) {
    return Report(
      reportId: id,
      reporterId: data['reporterId'] ?? '',
      reportedId: data['reportedId'] ?? '',
      entityType: EntityType.fromString(data['entityType']),
      violationCategory: ViolationCategory.fromString(data['violationCategory']),
      reportDescription: data['reportDescription'] ?? '',
      incidentLocation: data['incidentLocation'],
      evidenceAttachments: data['evidenceAttachments'] != null 
          ? List<String>.from(data['evidenceAttachments']) 
          : [],
      reportStatus: ReportStatus.fromString(data['reportStatus']),
      adminId: data['adminId'],
      adminNotes: data['adminNotes'],
      reportDate: data['reportDate'] != null
          ? (data['reportDate'] as Timestamp).toDate()
          : null,
      reviewedDate: data['reviewedDate'] != null
          ? (data['reviewedDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Report to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reportedId': reportedId,
      'entityType': entityType.value,
      'violationCategory': violationCategory.value,
      'reportDescription': reportDescription,
      'incidentLocation': incidentLocation,
      'evidenceAttachments': evidenceAttachments,
      'reportStatus': reportStatus.value,
      'adminId': adminId,
      'adminNotes': adminNotes,
      'reportDate': reportDate != null 
          ? Timestamp.fromDate(reportDate!) 
          : FieldValue.serverTimestamp(),
      'reviewedDate': reviewedDate != null 
          ? Timestamp.fromDate(reviewedDate!) 
          : null,
    };
  }

  /// Copy with specific changes
  Report copyWith({
    String? reportId,
    String? reporterId,
    String? reportedId,
    EntityType? entityType,
    ViolationCategory? violationCategory,
    String? reportDescription,
    String? incidentLocation,
    List<String>? evidenceAttachments,
    ReportStatus? reportStatus,
    String? adminId,
    String? adminNotes,
    DateTime? reportDate,
    DateTime? reviewedDate,
  }) {
    return Report(
      reportId: reportId ?? this.reportId,
      reporterId: reporterId ?? this.reporterId,
      reportedId: reportedId ?? this.reportedId,
      entityType: entityType ?? this.entityType,
      violationCategory: violationCategory ?? this.violationCategory,
      reportDescription: reportDescription ?? this.reportDescription,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      evidenceAttachments: evidenceAttachments ?? this.evidenceAttachments,
      reportStatus: reportStatus ?? this.reportStatus,
      adminId: adminId ?? this.adminId,
      adminNotes: adminNotes ?? this.adminNotes,
      reportDate: reportDate ?? this.reportDate,
      reviewedDate: reviewedDate ?? this.reviewedDate,
    );
  }

  @override
  String toString() {
    return 'Report(reportId: $reportId, violationCategory: $violationCategory, reportStatus: $reportStatus)';
  }
}
