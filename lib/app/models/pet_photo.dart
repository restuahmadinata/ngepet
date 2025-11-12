import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk foto hewan peliharaan
/// Disimpan sebagai subcollection di bawah setiap pet document:
/// pets/{petId}/photos/{photoId}
class PetPhoto {
  final String id;
  final String url; // URL foto dari ImgBB atau Firebase Storage
  final bool isPrimary; // Apakah ini foto utama/thumbnail
  final int order; // Urutan foto (0 = pertama)
  final DateTime? uploadedAt;

  PetPhoto({
    required this.id,
    required this.url,
    this.isPrimary = false,
    this.order = 0,
    this.uploadedAt,
  });

  /// Factory constructor untuk membuat PetPhoto dari Firestore document
  factory PetPhoto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetPhoto(
      id: doc.id,
      url: data['url'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      order: data['order'] ?? 0,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat PetPhoto dari Map
  factory PetPhoto.fromMap(Map<String, dynamic> data, String id) {
    return PetPhoto(
      id: id,
      url: data['url'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      order: data['order'] ?? 0,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi PetPhoto ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'isPrimary': isPrimary,
      'order': order,
      'uploadedAt': uploadedAt != null 
          ? Timestamp.fromDate(uploadedAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  PetPhoto copyWith({
    String? id,
    String? url,
    bool? isPrimary,
    int? order,
    DateTime? uploadedAt,
  }) {
    return PetPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      isPrimary: isPrimary ?? this.isPrimary,
      order: order ?? this.order,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() {
    return 'PetPhoto(id: $id, isPrimary: $isPrimary, order: $order)';
  }
}
