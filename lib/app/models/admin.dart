import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Admin
/// Collection: admins/{adminId}
class Admin {
  final String adminId;
  final String namaAdmin;
  final DateTime? createdAt;

  Admin({
    required this.adminId,
    required this.namaAdmin,
    this.createdAt,
  });

  /// Factory constructor untuk membuat Admin dari Firestore document
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Admin(
      adminId: doc.id,
      namaAdmin: data['namaAdmin'] ?? data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat Admin dari Map
  factory Admin.fromMap(Map<String, dynamic> data, String id) {
    return Admin(
      adminId: id,
      namaAdmin: data['namaAdmin'] ?? data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi Admin ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'namaAdmin': namaAdmin,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  Admin copyWith({
    String? adminId,
    String? namaAdmin,
    DateTime? createdAt,
  }) {
    return Admin(
      adminId: adminId ?? this.adminId,
      namaAdmin: namaAdmin ?? this.namaAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Admin(adminId: $adminId, namaAdmin: $namaAdmin)';
  }
}
