import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Adoption Request
/// Collection: adoption_applications/{applicationId}
class AdoptionRequest {
  final String applicationId;
  final String petId;
  final String userId;
  final String shelterId;
  final String adoptionReason;
  final String petExperience;
  final String residenceStatus; // 'own_house', 'rent', 'boarding'
  final bool hasYard;
  final int familyMembers;
  final String environmentDescription;
  final String applicationStatus; // 'pending', 'approved', 'rejected', 'completed'
  final String? shelterNotes;
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
