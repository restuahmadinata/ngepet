import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/conversation.dart';

enum UserType { user, shelter, unknown }

class ChatListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserType> userType = UserType.unknown.obs;

  @override
  void onInit() {
    super.onInit();
    determineUserTypeAndLoadConversations();
  }

  /// Determine if logged in user is a regular user or shelter
  Future<void> determineUserTypeAndLoadConversations() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        errorMessage.value = 'User not logged in';
        isLoading.value = false;
        return;
      }

      // Check if user exists in shelters collection
      final shelterDoc = await _firestore
          .collection('shelters')
          .doc(currentUserId)
          .get();

      if (shelterDoc.exists) {
        userType.value = UserType.shelter;
        loadConversationsForShelter(currentUserId);
      } else {
        // Check if user exists in users collection
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          userType.value = UserType.user;
          loadConversationsForUser(currentUserId);
        } else {
          errorMessage.value = 'User profile not found';
          isLoading.value = false;
        }
      }
    } catch (e) {
      errorMessage.value = 'Error determining user type: $e';
      isLoading.value = false;
    }
  }

  /// Load conversations for regular user
  void loadConversationsForUser(String userId) {
    try {
      _firestore
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          conversations.value = snapshot.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList();
          isLoading.value = false;
        },
        onError: (error) {
          errorMessage.value = 'Error loading conversations: $error';
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  /// Load conversations for shelter
  void loadConversationsForShelter(String shelterId) {
    try {
      _firestore
          .collection('conversations')
          .where('shelterId', isEqualTo: shelterId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          conversations.value = snapshot.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList();
          isLoading.value = false;
        },
        onError: (error) {
          errorMessage.value = 'Error loading conversations: $error';
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  /// Mark conversation as read (reset unread count based on user type)
  Future<void> markAsRead(String conversationId) async {
    try {
      if (userType.value == UserType.user) {
        await _firestore.collection('conversations').doc(conversationId).update({
          'unreadCountUser': 0,
        });
      } else if (userType.value == UserType.shelter) {
        await _firestore.collection('conversations').doc(conversationId).update({
          'unreadCountShelter': 0,
        });
      }
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

  /// Get unread count for badge (based on user type)
  int get totalUnreadCount {
    if (userType.value == UserType.user) {
      return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCountUser);
    } else if (userType.value == UserType.shelter) {
      return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCountShelter);
    }
    return 0;
  }

  /// Get the appropriate unread count for a conversation based on user type
  int getUnreadCount(Conversation conversation) {
    if (userType.value == UserType.user) {
      return conversation.unreadCountUser;
    } else if (userType.value == UserType.shelter) {
      return conversation.unreadCountShelter;
    }
    return 0;
  }
}
