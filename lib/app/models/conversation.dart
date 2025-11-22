import 'package:cloud_firestore/cloud_firestore.dart';

/// Conversation model for chat threads between users and shelters
class Conversation {
  final String conversationId;
  final String userId;
  final String shelterId;
  final String petId;
  
  // Denormalized data for quick access
  final String userName;
  final String shelterName;
  final String shelterLocation;
  final String petName;
  final String petImageUrl;
  final String? userPhoto;
  final String? shelterPhoto;
  
  // Last message info
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastMessageSenderId;
  
  // Unread tracking
  final int unreadCountUser;
  final int unreadCountShelter;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.conversationId,
    required this.userId,
    required this.shelterId,
    required this.petId,
    required this.userName,
    required this.shelterName,
    required this.shelterLocation,
    required this.petName,
    required this.petImageUrl,
    this.userPhoto,
    this.shelterPhoto,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageSenderId,
    this.unreadCountUser = 0,
    this.unreadCountShelter = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'shelterId': shelterId,
      'petId': petId,
      'userName': userName,
      'shelterName': shelterName,
      'shelterLocation': shelterLocation,
      'petName': petName,
      'petImageUrl': petImageUrl,
      'userPhoto': userPhoto,
      'shelterPhoto': shelterPhoto,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCountUser': unreadCountUser,
      'unreadCountShelter': unreadCountShelter,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      conversationId: data['conversationId'] ?? doc.id,
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      petId: data['petId'] ?? '',
      userName: data['userName'] ?? '',
      shelterName: data['shelterName'] ?? '',
      shelterLocation: data['shelterLocation'] ?? '',
      petName: data['petName'] ?? '',
      petImageUrl: data['petImageUrl'] ?? '',
      userPhoto: data['userPhoto'],
      shelterPhoto: data['shelterPhoto'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCountUser: data['unreadCountUser'] ?? 0,
      unreadCountShelter: data['unreadCountShelter'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from Map
  factory Conversation.fromMap(Map<String, dynamic> data) {
    return Conversation(
      conversationId: data['conversationId'] ?? '',
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      petId: data['petId'] ?? '',
      userName: data['userName'] ?? '',
      shelterName: data['shelterName'] ?? '',
      shelterLocation: data['shelterLocation'] ?? '',
      petName: data['petName'] ?? '',
      petImageUrl: data['petImageUrl'] ?? '',
      userPhoto: data['userPhoto'],
      shelterPhoto: data['shelterPhoto'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCountUser: data['unreadCountUser'] ?? 0,
      unreadCountShelter: data['unreadCountShelter'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Copy with method for updating fields
  Conversation copyWith({
    String? conversationId,
    String? userId,
    String? shelterId,
    String? petId,
    String? userName,
    String? shelterName,
    String? shelterLocation,
    String? petName,
    String? petImageUrl,
    String? userPhoto,
    String? shelterPhoto,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    int? unreadCountUser,
    int? unreadCountShelter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      shelterId: shelterId ?? this.shelterId,
      petId: petId ?? this.petId,
      userName: userName ?? this.userName,
      shelterName: shelterName ?? this.shelterName,
      shelterLocation: shelterLocation ?? this.shelterLocation,
      petName: petName ?? this.petName,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      userPhoto: userPhoto ?? this.userPhoto,
      shelterPhoto: shelterPhoto ?? this.shelterPhoto,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCountUser: unreadCountUser ?? this.unreadCountUser,
      unreadCountShelter: unreadCountShelter ?? this.unreadCountShelter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
