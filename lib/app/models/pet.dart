import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Pet/Hewan
/// Collection: pets/{hewanId}
/// Semua data pet termasuk kategori dan foto disimpan dalam satu collection
class Pet {
  final String hewanId;
  final String shelterId;
  final String kategori; // Jenis hewan: 'Anjing', 'Kucing', 'Kelinci', 'Burung', dll
  final String namaHewan;
  final String jenisKelamin; // 'Jantan', 'Betina'
  final int usiaBulan;
  final String ras;
  final String deskripsi;
  final String kondisiKesehatan;
  final String statusAdopsi; // 'available', 'pending', 'adopted'
  final String location;
  final String shelterName;
  final List<String> fotoUrls; // Array of photo URLs, index 0 = foto utama/thumbnail
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pet({
    required this.hewanId,
    required this.shelterId,
    required this.kategori,
    required this.namaHewan,
    required this.jenisKelamin,
    required this.usiaBulan,
    required this.ras,
    required this.deskripsi,
    required this.kondisiKesehatan,
    this.statusAdopsi = 'available',
    required this.location,
    required this.shelterName,
    this.fotoUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat Pet dari Firestore document
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Pet(
      hewanId: doc.id,
      shelterId: data['shelterId'] ?? '',
      kategori: data['kategori'] ?? data['kategoriId'] ?? data['type'] ?? '',
      namaHewan: data['namaHewan'] ?? data['name'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? data['gender'] ?? 'Jantan',
      usiaBulan: _parseUsiaBulan(data['usiaBulan'] ?? data['age']),
      ras: data['ras'] ?? data['breed'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'] ?? '',
      kondisiKesehatan: data['kondisiKesehatan'] ?? data['healthCondition'] ?? 'Sehat',
      statusAdopsi: data['statusAdopsi'] ?? data['status'] ?? 'available',
      location: data['location'] ?? '',
      shelterName: data['shelterName'] ?? '',
      fotoUrls: data['fotoUrls'] != null 
          ? List<String>.from(data['fotoUrls']) 
          : (data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat Pet dari Map
  factory Pet.fromMap(Map<String, dynamic> data, String id) {
    return Pet(
      hewanId: id,
      shelterId: data['shelterId'] ?? '',
      kategori: data['kategori'] ?? data['kategoriId'] ?? data['type'] ?? '',
      namaHewan: data['namaHewan'] ?? data['name'] ?? '',
      jenisKelamin: data['jenisKelamin'] ?? data['gender'] ?? 'Jantan',
      usiaBulan: _parseUsiaBulan(data['usiaBulan'] ?? data['age']),
      ras: data['ras'] ?? data['breed'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'] ?? '',
      kondisiKesehatan: data['kondisiKesehatan'] ?? data['healthCondition'] ?? 'Sehat',
      statusAdopsi: data['statusAdopsi'] ?? data['status'] ?? 'available',
      location: data['location'] ?? '',
      shelterName: data['shelterName'] ?? '',
      fotoUrls: data['fotoUrls'] != null 
          ? List<String>.from(data['fotoUrls']) 
          : (data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Helper untuk parsing usia bulan dari berbagai format
  static int _parseUsiaBulan(dynamic age) {
    if (age == null) return 0;
    if (age is int) return age;
    if (age is double) return age.toInt();
    if (age is String) {
      // Coba parse jika format string seperti "3 bulan"
      final match = RegExp(r'(\d+)').firstMatch(age);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    return 0;
  }

  /// Konversi Pet ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'hewanId': hewanId,
      'shelterId': shelterId,
      'kategori': kategori,
      'namaHewan': namaHewan,
      'jenisKelamin': jenisKelamin,
      'usiaBulan': usiaBulan,
      'ras': ras,
      'deskripsi': deskripsi,
      'kondisiKesehatan': kondisiKesehatan,
      'statusAdopsi': statusAdopsi,
      'location': location,
      'shelterName': shelterName,
      'fotoUrls': fotoUrls,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  Pet copyWith({
    String? hewanId,
    String? shelterId,
    String? kategori,
    String? namaHewan,
    String? jenisKelamin,
    int? usiaBulan,
    String? ras,
    String? deskripsi,
    String? kondisiKesehatan,
    String? statusAdopsi,
    String? location,
    String? shelterName,
    List<String>? fotoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      hewanId: hewanId ?? this.hewanId,
      shelterId: shelterId ?? this.shelterId,
      kategori: kategori ?? this.kategori,
      namaHewan: namaHewan ?? this.namaHewan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      usiaBulan: usiaBulan ?? this.usiaBulan,
      ras: ras ?? this.ras,
      deskripsi: deskripsi ?? this.deskripsi,
      kondisiKesehatan: kondisiKesehatan ?? this.kondisiKesehatan,
      statusAdopsi: statusAdopsi ?? this.statusAdopsi,
      location: location ?? this.location,
      shelterName: shelterName ?? this.shelterName,
      fotoUrls: fotoUrls ?? this.fotoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Pet(hewanId: $hewanId, namaHewan: $namaHewan, statusAdopsi: $statusAdopsi)';
  }
}
