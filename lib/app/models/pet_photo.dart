import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk foto hewan peliharaan
/// Subcollection: pets/{hewanId}/photos/{fotoId}
class PetPhoto {
  final String fotoId;
  final String urlFoto; // URL foto dari ImgBB atau Firebase Storage
  final bool isPrimary; // Apakah ini foto utama/thumbnail
  final int order; // Urutan foto (0 = pertama)
  final DateTime? uploadedAt;

  PetPhoto({
    required this.fotoId,
    required this.urlFoto,
    this.isPrimary = false,
    this.order = 0,
    this.uploadedAt,
  });

  /// Factory constructor untuk membuat PetPhoto dari Firestore document
  factory PetPhoto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetPhoto(
      fotoId: doc.id,
      urlFoto: data['urlFoto'] ?? data['url'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      order: data['order'] ?? 0,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat PetPhoto dari Map
  factory PetPhoto.fromMap(Map<String, dynamic> data, String id) {
    return PetPhoto(
      fotoId: id,
      urlFoto: data['urlFoto'] ?? data['url'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      order: data['order'] ?? 0,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi PetPhoto ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'fotoId': fotoId,
      'urlFoto': urlFoto,
      'isPrimary': isPrimary,
      'order': order,
      'uploadedAt': uploadedAt != null 
          ? Timestamp.fromDate(uploadedAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  PetPhoto copyWith({
    String? fotoId,
    String? urlFoto,
    bool? isPrimary,
    int? order,
    DateTime? uploadedAt,
  }) {
    return PetPhoto(
      fotoId: fotoId ?? this.fotoId,
      urlFoto: urlFoto ?? this.urlFoto,
      isPrimary: isPrimary ?? this.isPrimary,
      order: order ?? this.order,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() {
    return 'PetPhoto(fotoId: $fotoId, isPrimary: $isPrimary, order: $order)';
  }
}
