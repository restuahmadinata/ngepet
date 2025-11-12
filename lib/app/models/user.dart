import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk User
/// Collection: users/{userId}
class User {
  final String userId;
  final String email;
  final String namaLengkap;
  final String? noTelepon;
  final String? alamat;
  final String? kota;
  final DateTime? tanggalLahir;
  final String? jenisKelamin; // 'Laki-laki', 'Perempuan'
  final String? fotoProfil;
  final String statusAkun; // 'active', 'suspended', 'banned'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.namaLengkap,
    this.noTelepon,
    this.alamat,
    this.kota,
    this.tanggalLahir,
    this.jenisKelamin,
    this.fotoProfil,
    this.statusAkun = 'active',
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat User dari Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return User(
      userId: doc.id,
      email: data['email'] ?? '',
      namaLengkap: data['namaLengkap'] ?? data['fullName'] ?? data['name'] ?? '',
      noTelepon: data['noTelepon'] ?? data['phoneNumber'],
      alamat: data['alamat'] ?? data['address'],
      kota: data['kota'] ?? data['city'],
      tanggalLahir: (data['tanggalLahir'] as Timestamp?)?.toDate() ?? (data['birthDate'] as Timestamp?)?.toDate(),
      jenisKelamin: data['jenisKelamin'] ?? data['gender'],
      fotoProfil: data['fotoProfil'] ?? data['profilePhotoUrl'],
      statusAkun: data['statusAkun'] ?? data['accountStatus'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat User dari Map
  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      userId: id,
      email: data['email'] ?? '',
      namaLengkap: data['namaLengkap'] ?? data['fullName'] ?? data['name'] ?? '',
      noTelepon: data['noTelepon'] ?? data['phoneNumber'],
      alamat: data['alamat'] ?? data['address'],
      kota: data['kota'] ?? data['city'],
      tanggalLahir: (data['tanggalLahir'] as Timestamp?)?.toDate() ?? (data['birthDate'] as Timestamp?)?.toDate(),
      jenisKelamin: data['jenisKelamin'] ?? data['gender'],
      fotoProfil: data['fotoProfil'] ?? data['profilePhotoUrl'],
      statusAkun: data['statusAkun'] ?? data['accountStatus'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi User ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'namaLengkap': namaLengkap,
      'noTelepon': noTelepon,
      'alamat': alamat,
      'kota': kota,
      'tanggalLahir': tanggalLahir != null ? Timestamp.fromDate(tanggalLahir!) : null,
      'jenisKelamin': jenisKelamin,
      'fotoProfil': fotoProfil,
      'statusAkun': statusAkun,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  User copyWith({
    String? userId,
    String? email,
    String? namaLengkap,
    String? noTelepon,
    String? alamat,
    String? kota,
    DateTime? tanggalLahir,
    String? jenisKelamin,
    String? fotoProfil,
    String? statusAkun,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      kota: kota ?? this.kota,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      statusAkun: statusAkun ?? this.statusAkun,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, namaLengkap: $namaLengkap, email: $email, statusAkun: $statusAkun)';
  }
}
