import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Admin
/// Collection: admins/{adminId}
class Admin {
  final String adminId;
  final String adminName;
  final DateTime? createdAt;

  Admin({
    required this.adminId,
    required this.adminName,
    this.createdAt,
  });

  /// Factory constructor to create Admin from Firestore document
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Admin(
      adminId: doc.id,
      adminName: data['adminName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor to create Admin from Map
  factory Admin.fromMap(Map<String, dynamic> data, String id) {
    return Admin(
      adminId: id,
      adminName: data['adminName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Admin to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  Admin copyWith({
    String? adminId,
    String? adminName,
    DateTime? createdAt,
  }) {
    return Admin(
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Admin(adminId: $adminId, adminName: $adminName)';
  }
}
