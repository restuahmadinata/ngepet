import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/conversation.dart';
import '../../../../models/message.dart';
import '../../../../models/enums.dart';

class ChatDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final TextEditingController messageController = TextEditingController();
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final Rx<Message?> editingMessage = Rx<Message?>(null);

  late Conversation conversation;
  late String currentUserId;
  late bool isShelter;

  @override
  void onInit() {
    super.onInit();
    currentUserId = _auth.currentUser?.uid ?? '';
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  /// Initialize with conversation data
  void initConversation(Conversation conv) async {
    conversation = conv;
    
    // Determine if current user is shelter or regular user
    isShelter = currentUserId == conversation.shelterId;
    
    // Fetch latest profile photos if they're missing
    await _ensureProfilePhotos();
    
    loadMessages();
    markMessagesAsRead();
  }

  /// Ensure profile photos are loaded
  Future<void> _ensureProfilePhotos() async {
    try {
      bool needsUpdate = false;
      String? userPhoto = conversation.userPhoto;
      String? shelterPhoto = conversation.shelterPhoto;

      // Fetch user photo if missing
      if (userPhoto == null || userPhoto.isEmpty) {
        final userDoc = await _firestore
            .collection('users')
            .doc(conversation.userId)
            .get();
        userPhoto = userDoc.data()?['profilePhoto'];
        needsUpdate = true;
      }

      // Fetch shelter photo if missing
      if (shelterPhoto == null || shelterPhoto.isEmpty) {
        final shelterDoc = await _firestore
            .collection('shelters')
            .doc(conversation.shelterId)
            .get();
        shelterPhoto = shelterDoc.data()?['profilePhotoUrl'];
        needsUpdate = true;
      }

      // Update conversation if photos were fetched
      if (needsUpdate) {
        conversation = conversation.copyWith(
          userPhoto: userPhoto,
          shelterPhoto: shelterPhoto,
        );

        // Update in Firestore
        await _firestore
            .collection('conversations')
            .doc(conversation.conversationId)
            .update({
          'userPhoto': userPhoto,
          'shelterPhoto': shelterPhoto,
        });
      }
    } catch (e) {
      print('Error fetching profile photos: $e');
    }
  }

  /// Load messages for this conversation
  void loadMessages() {
    isLoading.value = true;

    _firestore
        .collection('conversations')
        .doc(conversation.conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        messages.value = snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList();
        isLoading.value = false;
        
        // Only mark messages as read if there are unread messages from the other person
        final hasUnreadFromOthers = messages.any(
          (msg) => !msg.isRead && msg.senderId != currentUserId,
        );
        
        if (hasUnreadFromOthers) {
          markMessagesAsRead();
        }
      },
      onError: (error) {
        print('Error loading messages: $error');
        isLoading.value = false;
      },
    );
  }

  /// Send a new message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || isSending.value) return;

    final messageText = messageController.text.trim();
    messageController.clear();
    isSending.value = true;

    try {
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversation.conversationId)
          .collection('messages')
          .doc();

      // Determine sender type based on who is logged in
      final senderType = isShelter ? SenderType.shelter : SenderType.user;

      final message = Message(
        messageId: messageRef.id,
        conversationId: conversation.conversationId,
        senderId: currentUserId,
        senderType: senderType,
        messageContent: messageText,
        messageType: MessageType.text,
        sentAt: DateTime.now(),
      );

      // Save message
      await messageRef.set(message.toMap());

      // Update conversation with last message
      // Only increment unread count for the OTHER party
      final updateData = {
        'lastMessage': messageText,
        'lastMessageAt': Timestamp.fromDate(DateTime.now()),
        'lastMessageSenderId': currentUserId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // If shelter sends message, increment user's unread count
      // If user sends message, increment shelter's unread count
      if (isShelter) {
        updateData['unreadCountUser'] = FieldValue.increment(1);
      } else {
        updateData['unreadCountShelter'] = FieldValue.increment(1);
      }

      await _firestore
          .collection('conversations')
          .doc(conversation.conversationId)
          .update(updateData);
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// Edit a message
  Future<void> editMessage(Message message, String newContent) async {
    if (newContent.trim().isEmpty) return;
    if (!message.canEdit()) {
      Get.snackbar(
        'Cannot Edit',
        'Messages can only be edited within 15 minutes',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _firestore
          .collection('conversations')
          .doc(conversation.conversationId)
          .collection('messages')
          .doc(message.messageId)
          .update({
        'messageContent': newContent.trim(),
        'isEdited': true,
        'editedAt': Timestamp.fromDate(DateTime.now()),
      });

      // If this was the last message, update conversation
      if (message.messageId == messages.last.messageId) {
        await _firestore
            .collection('conversations')
            .doc(conversation.conversationId)
            .update({
          'lastMessage': newContent.trim(),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      editingMessage.value = null;
    } catch (e) {
      print('Error editing message: $e');
      Get.snackbar(
        'Error',
        'Failed to edit message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete a message
  Future<void> deleteMessage(Message message) async {
    if (!message.canDelete()) {
      Get.snackbar(
        'Cannot Delete',
        'Messages can only be deleted within 6 hours',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _firestore
          .collection('conversations')
          .doc(conversation.conversationId)
          .collection('messages')
          .doc(message.messageId)
          .update({
        'messageContent': 'Message deleted',
        'messageType': MessageType.deleted.value,
        'isDeleted': true,
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      });

      // If this was the last message, update conversation
      if (message.messageId == messages.last.messageId) {
        await _firestore
            .collection('conversations')
            .doc(conversation.conversationId)
            .update({
          'lastMessage': 'Message deleted',
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar(
        'Error',
        'Failed to delete message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Mark all unread messages as read
  Future<void> markMessagesAsRead() async {
    try {
      final unreadMessages = messages.where(
        (msg) => !msg.isRead && msg.senderId != currentUserId,
      );

      for (var message in unreadMessages) {
        await _firestore
            .collection('conversations')
            .doc(conversation.conversationId)
            .collection('messages')
            .doc(message.messageId)
            .update({
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      // Reset unread count for current user type
      if (unreadMessages.isNotEmpty) {
        final updateData = <String, dynamic>{};
        
        if (isShelter) {
          updateData['unreadCountShelter'] = 0;
        } else {
          updateData['unreadCountUser'] = 0;
        }
        
        await _firestore
            .collection('conversations')
            .doc(conversation.conversationId)
            .update(updateData);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Show edit dialog
  void showEditDialog(Message message) {
    editingMessage.value = message;
    messageController.text = message.messageContent;
  }

  /// Cancel editing
  void cancelEdit() {
    editingMessage.value = null;
    messageController.clear();
  }

  /// Show delete confirmation
  void showDeleteConfirmation(Message message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteMessage(message);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
