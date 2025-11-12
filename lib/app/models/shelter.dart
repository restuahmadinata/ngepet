import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Shelter
/// Collection: shelters/{shelterId}
class Shelter {
  final String shelterId;
  final String namaShelter;
  final String deskripsi;
  final String kota;
  final GeoPoint? geoPoint; // Lokasi shelter
  final String noTeleponShelter;
  final String emailShelter;
  final String? fotoShelter;
  final String statusVerifikasi; // 'pending', 'approved', 'rejected'
  final DateTime? tanggalVerifikasi;
  final String? legalNumber;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shelter({
    required this.shelterId,
    required this.namaShelter,
    required this.deskripsi,
    required this.kota,
    this.geoPoint,
    required this.noTeleponShelter,
    required this.emailShelter,
    this.fotoShelter,
    this.statusVerifikasi = 'pending',
    this.tanggalVerifikasi,
    this.legalNumber,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat Shelter dari Firestore document
  factory Shelter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Shelter(
      shelterId: doc.id,
      namaShelter: data['namaShelter'] ?? data['shelterName'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'] ?? '',
      kota: data['kota'] ?? data['city'] ?? '',
      geoPoint: data['geoPoint'] as GeoPoint?,
      noTeleponShelter: data['noTeleponShelter'] ?? data['phone'] ?? '',
      emailShelter: data['emailShelter'] ?? data['email'] ?? '',
      fotoShelter: data['fotoShelter'] ?? data['profilePhotoUrl'] ?? data['photo'],
      statusVerifikasi: data['statusVerifikasi'] ?? data['verificationStatus'] ?? 'pending',
      tanggalVerifikasi: (data['tanggalVerifikasi'] as Timestamp?)?.toDate(),
      legalNumber: data['legalNumber'],
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat Shelter dari Map
  factory Shelter.fromMap(Map<String, dynamic> data, String id) {
    return Shelter(
      shelterId: id,
      namaShelter: data['namaShelter'] ?? data['shelterName'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'] ?? '',
      kota: data['kota'] ?? data['city'] ?? '',
      geoPoint: data['geoPoint'] as GeoPoint?,
      noTeleponShelter: data['noTeleponShelter'] ?? data['phone'] ?? '',
      emailShelter: data['emailShelter'] ?? data['email'] ?? '',
      fotoShelter: data['fotoShelter'] ?? data['profilePhotoUrl'] ?? data['photo'],
      statusVerifikasi: data['statusVerifikasi'] ?? data['verificationStatus'] ?? 'pending',
      tanggalVerifikasi: (data['tanggalVerifikasi'] as Timestamp?)?.toDate(),
      legalNumber: data['legalNumber'],
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi Shelter ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'shelterId': shelterId,
      'namaShelter': namaShelter,
      'deskripsi': deskripsi,
      'kota': kota,
      'geoPoint': geoPoint,
      'noTeleponShelter': noTeleponShelter,
      'emailShelter': emailShelter,
      'fotoShelter': fotoShelter,
      'statusVerifikasi': statusVerifikasi,
      'tanggalVerifikasi': tanggalVerifikasi != null 
          ? Timestamp.fromDate(tanggalVerifikasi!) 
          : null,
      'legalNumber': legalNumber,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  Shelter copyWith({
    String? shelterId,
    String? namaShelter,
    String? deskripsi,
    String? kota,
    GeoPoint? geoPoint,
    String? noTeleponShelter,
    String? emailShelter,
    String? fotoShelter,
    String? statusVerifikasi,
    DateTime? tanggalVerifikasi,
    String? legalNumber,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shelter(
      shelterId: shelterId ?? this.shelterId,
      namaShelter: namaShelter ?? this.namaShelter,
      deskripsi: deskripsi ?? this.deskripsi,
      kota: kota ?? this.kota,
      geoPoint: geoPoint ?? this.geoPoint,
      noTeleponShelter: noTeleponShelter ?? this.noTeleponShelter,
      emailShelter: emailShelter ?? this.emailShelter,
      fotoShelter: fotoShelter ?? this.fotoShelter,
      statusVerifikasi: statusVerifikasi ?? this.statusVerifikasi,
      tanggalVerifikasi: tanggalVerifikasi ?? this.tanggalVerifikasi,
      legalNumber: legalNumber ?? this.legalNumber,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Shelter(shelterId: $shelterId, namaShelter: $namaShelter, statusVerifikasi: $statusVerifikasi)';
  }
}
