import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Shelter
/// Collection: shelters/{shelterId}
class Shelter {
  final String shelterId;
  final String shelterName;
  final String description;
  final String city;
  final GeoPoint? geoPoint; // Shelter location
  final String shelterPhone;
  final String shelterEmail;
  final String? shelterPhoto;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final DateTime? verificationDate;
  final String? legalNumber;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shelter({
    required this.shelterId,
    required this.shelterName,
    required this.description,
    required this.city,
    this.geoPoint,
    required this.shelterPhone,
    required this.shelterEmail,
    this.shelterPhoto,
    this.verificationStatus = 'pending',
    this.verificationDate,
    this.legalNumber,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create Shelter from Firestore document
  factory Shelter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Shelter(
      shelterId: doc.id,
      shelterName: data['shelterName'] ?? '',
      description: data['description'] ?? '',
      city: data['city'] ?? '',
      geoPoint: data['geoPoint'] as GeoPoint?,
      shelterPhone: data['phone'] ?? '',
      shelterEmail: data['email'] ?? '',
      shelterPhoto: data['profilePhotoUrl'],
      verificationStatus: data['verificationStatus'] ?? 'pending',
      verificationDate: (data['verificationDate'] as Timestamp?)?.toDate(),
      legalNumber: data['legalNumber'],
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor to create Shelter from Map
  factory Shelter.fromMap(Map<String, dynamic> data, String id) {
    return Shelter(
      shelterId: id,
      shelterName: data['shelterName'] ?? '',
      description: data['description'] ?? '',
      city: data['city'] ?? '',
      geoPoint: data['geoPoint'] as GeoPoint?,
      shelterPhone: data['phone'] ?? '',
      shelterEmail: data['email'] ?? '',
      shelterPhoto: data['profilePhotoUrl'],
      verificationStatus: data['verificationStatus'] ?? 'pending',
      verificationDate: (data['verificationDate'] as Timestamp?)?.toDate(),
      legalNumber: data['legalNumber'],
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Shelter to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'shelterId': shelterId,
      'shelterName': shelterName,
      'description': description,
      'city': city,
      'geoPoint': geoPoint,
      'phone': shelterPhone,
      'email': shelterEmail,
      'profilePhotoUrl': shelterPhoto,
      'verificationStatus': verificationStatus,
      'verificationDate': verificationDate != null 
          ? Timestamp.fromDate(verificationDate!) 
          : null,
      'legalNumber': legalNumber,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  Shelter copyWith({
    String? shelterId,
    String? shelterName,
    String? description,
    String? city,
    GeoPoint? geoPoint,
    String? shelterPhone,
    String? shelterEmail,
    String? shelterPhoto,
    String? verificationStatus,
    DateTime? verificationDate,
    String? legalNumber,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shelter(
      shelterId: shelterId ?? this.shelterId,
      shelterName: shelterName ?? this.shelterName,
      description: description ?? this.description,
      city: city ?? this.city,
      geoPoint: geoPoint ?? this.geoPoint,
      shelterPhone: shelterPhone ?? this.shelterPhone,
      shelterEmail: shelterEmail ?? this.shelterEmail,
      shelterPhoto: shelterPhoto ?? this.shelterPhoto,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDate: verificationDate ?? this.verificationDate,
      legalNumber: legalNumber ?? this.legalNumber,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Shelter(shelterId: $shelterId, shelterName: $shelterName, verificationStatus: $verificationStatus)';
  }
}
