import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk kategori hewan peliharaan
/// Digunakan untuk mengelola jenis hewan dan ras-rasnya
class PetCategory {
  final String id;
  final String type; // Anjing, Kucing, Kelinci, dll
  final List<String> breeds; // Daftar ras untuk jenis hewan ini
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PetCategory({
    required this.id,
    required this.type,
    required this.breeds,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat PetCategory dari Firestore document
  factory PetCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PetCategory(
      id: doc.id,
      type: data['type'] ?? '',
      breeds: List<String>.from(data['breeds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat PetCategory dari Map
  factory PetCategory.fromMap(Map<String, dynamic> data, String id) {
    return PetCategory(
      id: id,
      type: data['type'] ?? '',
      breeds: List<String>.from(data['breeds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi PetCategory ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'breeds': breeds,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  PetCategory copyWith({
    String? id,
    String? type,
    List<String>? breeds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetCategory(
      id: id ?? this.id,
      type: type ?? this.type,
      breeds: breeds ?? this.breeds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PetCategory(id: $id, type: $type, breeds: ${breeds.length} breeds)';
  }
}
