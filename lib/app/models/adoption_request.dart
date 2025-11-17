import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Adoption Request
/// Collection: adoption_applications/{applicationId}
/// 
/// Process Flow:
/// 1. Application Request - User submits form
/// 2. Survey - Shelter visits user's home
/// 3. Handover - Pet is given to user
class AdoptionRequest {
  final String applicationId;
  final String petId;
  final String userId;
  final String shelterId;
  
  // User form data
  final String adoptionReason;
  final String petExperience;
  final String residenceStatus; // 'own_house', 'rental', 'boarding'
  final bool hasYard;
  final int familyMembers;
  final String environmentDescription;
  
  // Overall application status
  final String applicationStatus; // 'pending', 'approved', 'rejected', 'completed'
  
  // Stage 1: Application Request
  final String requestStatus; // 'pending', 'approved', 'rejected'
  final DateTime? requestDate;
  final DateTime? requestProcessedDate;
  final String? requestNotes; // Shelter notes for this stage
  
  // Stage 2: Survey
  final String surveyStatus; // 'pending', 'approved', 'rejected', 'not_started'
  final DateTime? surveyScheduledDate;
  final DateTime? surveyCompletedDate;
  final String? surveyNotes; // Shelter notes for this stage
  
  // Stage 3: Handover
  final String handoverStatus; // 'pending', 'completed', 'not_started'
  final DateTime? handoverScheduledDate;
  final DateTime? handoverCompletedDate;
  final String? handoverNotes; // Shelter notes for this stage
  
  // General fields
  final String? shelterNotes; // General shelter notes
  final DateTime? applicationDate;
  final DateTime? processedDate;
  final DateTime? updatedAt;

  AdoptionRequest({
    required this.applicationId,
    required this.petId,
    required this.userId,
    required this.shelterId,
    required this.adoptionReason,
    required this.petExperience,
    required this.residenceStatus,
    required this.hasYard,
    required this.familyMembers,
    required this.environmentDescription,
    this.applicationStatus = 'pending',
    this.requestStatus = 'pending',
    this.requestDate,
    this.requestProcessedDate,
    this.requestNotes,
    this.surveyStatus = 'not_started',
    this.surveyScheduledDate,
    this.surveyCompletedDate,
    this.surveyNotes,
    this.handoverStatus = 'not_started',
    this.handoverScheduledDate,
    this.handoverCompletedDate,
    this.handoverNotes,
    this.shelterNotes,
    this.applicationDate,
    this.processedDate,
    this.updatedAt,
  });

  /// Factory constructor to create AdoptionRequest from Firestore document
  factory AdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AdoptionRequest(
      applicationId: doc.id,
      petId: data['petId'] ?? '',
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      adoptionReason: data['adoptionReason'] ?? '',
      petExperience: data['petExperience'] ?? '',
      residenceStatus: data['residenceStatus'] ?? '',
      hasYard: data['hasYard'] ?? false,
      familyMembers: data['familyMembers'] ?? 0,
      environmentDescription: data['environmentDescription'] ?? '',
      applicationStatus: data['applicationStatus'] ?? 'pending',
      requestStatus: data['requestStatus'] ?? 'pending',
      requestDate: data['requestDate'] != null 
          ? (data['requestDate'] as Timestamp).toDate() 
          : null,
      requestProcessedDate: data['requestProcessedDate'] != null 
          ? (data['requestProcessedDate'] as Timestamp).toDate() 
          : null,
      requestNotes: data['requestNotes'],
      surveyStatus: data['surveyStatus'] ?? 'not_started',
      surveyScheduledDate: data['surveyScheduledDate'] != null 
          ? (data['surveyScheduledDate'] as Timestamp).toDate() 
          : null,
      surveyCompletedDate: data['surveyCompletedDate'] != null 
          ? (data['surveyCompletedDate'] as Timestamp).toDate() 
          : null,
      surveyNotes: data['surveyNotes'],
      handoverStatus: data['handoverStatus'] ?? 'not_started',
      handoverScheduledDate: data['handoverScheduledDate'] != null 
          ? (data['handoverScheduledDate'] as Timestamp).toDate() 
          : null,
      handoverCompletedDate: data['handoverCompletedDate'] != null 
          ? (data['handoverCompletedDate'] as Timestamp).toDate() 
          : null,
      handoverNotes: data['handoverNotes'],
      shelterNotes: data['shelterNotes'],
      applicationDate: data['applicationDate'] != null 
          ? (data['applicationDate'] as Timestamp).toDate() 
          : null,
      processedDate: data['processedDate'] != null 
          ? (data['processedDate'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  /// Factory constructor to create AdoptionRequest from Map
  factory AdoptionRequest.fromMap(Map<String, dynamic> data, String id) {
    return AdoptionRequest(
      applicationId: id,
      petId: data['petId'] ?? '',
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      adoptionReason: data['adoptionReason'] ?? '',
      petExperience: data['petExperience'] ?? '',
      residenceStatus: data['residenceStatus'] ?? '',
      hasYard: data['hasYard'] ?? false,
      familyMembers: data['familyMembers'] ?? 0,
      environmentDescription: data['environmentDescription'] ?? '',
      applicationStatus: data['applicationStatus'] ?? 'pending',
      requestStatus: data['requestStatus'] ?? 'pending',
      requestDate: data['requestDate'] != null 
          ? (data['requestDate'] as Timestamp).toDate() 
          : null,
      requestProcessedDate: data['requestProcessedDate'] != null 
          ? (data['requestProcessedDate'] as Timestamp).toDate() 
          : null,
      requestNotes: data['requestNotes'],
      surveyStatus: data['surveyStatus'] ?? 'not_started',
      surveyScheduledDate: data['surveyScheduledDate'] != null 
          ? (data['surveyScheduledDate'] as Timestamp).toDate() 
          : null,
      surveyCompletedDate: data['surveyCompletedDate'] != null 
          ? (data['surveyCompletedDate'] as Timestamp).toDate() 
          : null,
      surveyNotes: data['surveyNotes'],
      handoverStatus: data['handoverStatus'] ?? 'not_started',
      handoverScheduledDate: data['handoverScheduledDate'] != null 
          ? (data['handoverScheduledDate'] as Timestamp).toDate() 
          : null,
      handoverCompletedDate: data['handoverCompletedDate'] != null 
          ? (data['handoverCompletedDate'] as Timestamp).toDate() 
          : null,
      handoverNotes: data['handoverNotes'],
      shelterNotes: data['shelterNotes'],
      applicationDate: data['applicationDate'] != null 
          ? (data['applicationDate'] as Timestamp).toDate() 
          : null,
      processedDate: data['processedDate'] != null 
          ? (data['processedDate'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  /// Convert AdoptionRequest to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'petId': petId,
      'userId': userId,
      'shelterId': shelterId,
      'adoptionReason': adoptionReason,
      'petExperience': petExperience,
      'residenceStatus': residenceStatus,
      'hasYard': hasYard,
      'familyMembers': familyMembers,
      'environmentDescription': environmentDescription,
      'applicationStatus': applicationStatus,
      'requestStatus': requestStatus,
      'requestDate': requestDate != null 
          ? Timestamp.fromDate(requestDate!) 
          : null,
      'requestProcessedDate': requestProcessedDate != null 
          ? Timestamp.fromDate(requestProcessedDate!) 
          : null,
      'requestNotes': requestNotes,
      'surveyStatus': surveyStatus,
      'surveyScheduledDate': surveyScheduledDate != null 
          ? Timestamp.fromDate(surveyScheduledDate!) 
          : null,
      'surveyCompletedDate': surveyCompletedDate != null 
          ? Timestamp.fromDate(surveyCompletedDate!) 
          : null,
      'surveyNotes': surveyNotes,
      'handoverStatus': handoverStatus,
      'handoverScheduledDate': handoverScheduledDate != null 
          ? Timestamp.fromDate(handoverScheduledDate!) 
          : null,
      'handoverCompletedDate': handoverCompletedDate != null 
          ? Timestamp.fromDate(handoverCompletedDate!) 
          : null,
      'handoverNotes': handoverNotes,
      'shelterNotes': shelterNotes,
      'applicationDate': applicationDate != null 
          ? Timestamp.fromDate(applicationDate!) 
          : FieldValue.serverTimestamp(),
      'processedDate': processedDate != null 
          ? Timestamp.fromDate(processedDate!) 
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  AdoptionRequest copyWith({
    String? applicationId,
    String? petId,
    String? userId,
    String? shelterId,
    String? adoptionReason,
    String? petExperience,
    String? residenceStatus,
    bool? hasYard,
    int? familyMembers,
    String? environmentDescription,
    String? applicationStatus,
    String? requestStatus,
    DateTime? requestDate,
    DateTime? requestProcessedDate,
    String? requestNotes,
    String? surveyStatus,
    DateTime? surveyScheduledDate,
    DateTime? surveyCompletedDate,
    String? surveyNotes,
    String? handoverStatus,
    DateTime? handoverScheduledDate,
    DateTime? handoverCompletedDate,
    String? handoverNotes,
    String? shelterNotes,
    DateTime? applicationDate,
    DateTime? processedDate,
    DateTime? updatedAt,
  }) {
    return AdoptionRequest(
      applicationId: applicationId ?? this.applicationId,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      shelterId: shelterId ?? this.shelterId,
      adoptionReason: adoptionReason ?? this.adoptionReason,
      petExperience: petExperience ?? this.petExperience,
      residenceStatus: residenceStatus ?? this.residenceStatus,
      hasYard: hasYard ?? this.hasYard,
      familyMembers: familyMembers ?? this.familyMembers,
      environmentDescription: environmentDescription ?? this.environmentDescription,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      requestStatus: requestStatus ?? this.requestStatus,
      requestDate: requestDate ?? this.requestDate,
      requestProcessedDate: requestProcessedDate ?? this.requestProcessedDate,
      requestNotes: requestNotes ?? this.requestNotes,
      surveyStatus: surveyStatus ?? this.surveyStatus,
      surveyScheduledDate: surveyScheduledDate ?? this.surveyScheduledDate,
      surveyCompletedDate: surveyCompletedDate ?? this.surveyCompletedDate,
      surveyNotes: surveyNotes ?? this.surveyNotes,
      handoverStatus: handoverStatus ?? this.handoverStatus,
      handoverScheduledDate: handoverScheduledDate ?? this.handoverScheduledDate,
      handoverCompletedDate: handoverCompletedDate ?? this.handoverCompletedDate,
      handoverNotes: handoverNotes ?? this.handoverNotes,
      shelterNotes: shelterNotes ?? this.shelterNotes,
      applicationDate: applicationDate ?? this.applicationDate,
      processedDate: processedDate ?? this.processedDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AdoptionRequest(applicationId: $applicationId, petId: $petId, applicationStatus: $applicationStatus)';
  }
}
