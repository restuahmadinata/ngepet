import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Message model for individual chat messages
class Message {
  final String messageId;
  final String conversationId;
  final String senderId;
  final SenderType senderType;
  
  // Content
  final String messageContent;
  final MessageType messageType;
  
  // Status & tracking
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  
  // Timestamps
  final DateTime sentAt;
  final DateTime? readAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.messageContent,
    this.messageType = MessageType.text,
    this.isRead = false,
    this.isEdited = false,
    this.isDeleted = false,
    required this.sentAt,
    this.readAt,
    this.editedAt,
    this.deletedAt,
  });

  /// Check if message can be edited (within 15 minutes)
  bool canEdit() {
    if (isDeleted) return false;
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    return difference.inMinutes < 15;
  }

  /// Check if message can be deleted (within 6 hours)
  bool canDelete() {
    if (isDeleted) return false;
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    return difference.inHours < 6;
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderType': senderType.value,
      'messageContent': messageContent,
      'messageType': messageType.value,
      'isRead': isRead,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'sentAt': Timestamp.fromDate(sentAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  /// Create from Firestore document
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      messageId: data['messageId'] ?? doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: SenderType.fromString(data['senderType']),
      messageContent: data['messageContent'] ?? '',
      messageType: MessageType.fromString(data['messageType']),
      isRead: data['isRead'] ?? false,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create from Map
  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      messageId: data['messageId'] ?? '',
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: SenderType.fromString(data['senderType']),
      messageContent: data['messageContent'] ?? '',
      messageType: MessageType.fromString(data['messageType']),
      isRead: data['isRead'] ?? false,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Copy with method for updating fields
  Message copyWith({
    String? messageId,
    String? conversationId,
    String? senderId,
    SenderType? senderType,
    String? messageContent,
    MessageType? messageType,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    DateTime? sentAt,
    DateTime? readAt,
    DateTime? editedAt,
    DateTime? deletedAt,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      messageContent: messageContent ?? this.messageContent,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
