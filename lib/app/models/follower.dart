import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Follower
/// Collection: followers/{followerId}
class Follower {
  final String followerId;
  final String userId;
  final String shelterId;
  final DateTime? followedAt;

  Follower({
    required this.followerId,
    required this.userId,
    required this.shelterId,
    this.followedAt,
  });

  /// Factory constructor untuk membuat Follower dari Firestore document
  factory Follower.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Follower(
      followerId: doc.id,
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      followedAt: (data['followedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat Follower dari Map
  factory Follower.fromMap(Map<String, dynamic> data, String id) {
    return Follower(
      followerId: id,
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      followedAt: (data['followedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi Follower ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'userId': userId,
      'shelterId': shelterId,
      'followedAt': followedAt != null 
          ? Timestamp.fromDate(followedAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  Follower copyWith({
    String? followerId,
    String? userId,
    String? shelterId,
    DateTime? followedAt,
  }) {
    return Follower(
      followerId: followerId ?? this.followerId,
      userId: userId ?? this.userId,
      shelterId: shelterId ?? this.shelterId,
      followedAt: followedAt ?? this.followedAt,
    );
  }

  @override
  String toString() {
    return 'Follower(followerId: $followerId, userId: $userId, shelterId: $shelterId)';
  }
}
