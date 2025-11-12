import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk kategori hewan
/// Collection: kategori_hewan/{kategoriId}
class PetCategory {
  final String kategoriId;
  final String namaKategori; // Anjing, Kucing, Kelinci, Burung, dll
  final String deskripsi;

  PetCategory({
    required this.kategoriId,
    required this.namaKategori,
    required this.deskripsi,
  });

  /// Factory constructor untuk membuat PetCategory dari Firestore document
  factory PetCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetCategory(
      kategoriId: doc.id,
      namaKategori: data['namaKategori'] ?? data['type'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'] ?? '',
    );
  }

  /// Factory constructor untuk membuat PetCategory dari Map
  factory PetCategory.fromMap(Map<String, dynamic> data, String id) {
    return PetCategory(
      kategoriId: id,
      namaKategori: data['namaKategori'] ?? data['type'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'] ?? '',
    );
  }

  /// Konversi PetCategory ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'kategoriId': kategoriId,
      'namaKategori': namaKategori,
      'deskripsi': deskripsi,
    };
  }

  /// Copy dengan perubahan tertentu
  PetCategory copyWith({
    String? kategoriId,
    String? namaKategori,
    String? deskripsi,
  }) {
    return PetCategory(
      kategoriId: kategoriId ?? this.kategoriId,
      namaKategori: namaKategori ?? this.namaKategori,
      deskripsi: deskripsi ?? this.deskripsi,
    );
  }

  @override
  String toString() {
    return 'PetCategory(kategoriId: $kategoriId, namaKategori: $namaKategori)';
  }
}
