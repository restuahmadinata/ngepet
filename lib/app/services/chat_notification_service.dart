import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../models/conversation.dart';

/// Simple notification service for chat messages (FREE - no Firebase required)
/// Uses Firestore listeners and local notifications
class ChatNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _conversationListener;
  final Set<String> _seenMessageIds = {};
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<ChatNotificationService> init() async {
    if (_isInitialized) return this;

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions for Android 13+
    if (GetPlatform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _isInitialized = true;
    _startListeningToMessages();
    return this;
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Navigate to chat detail page
      Get.toNamed('/chat-detail', arguments: {'conversationId': payload});
    }
  }

  /// Start listening to new messages
  void _startListeningToMessages() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userId = currentUser.uid;

    // Determine if the current user is a shelter or regular user
    _firestore.collection('shelters').doc(userId).get().then((doc) {
      final isShelter = doc.exists;

      // Listen to conversations where user is a participant
      Query conversationsQuery;
      if (isShelter) {
        conversationsQuery = _firestore
            .collection('conversations')
            .where('shelterId', isEqualTo: userId);
      } else {
        conversationsQuery = _firestore
            .collection('conversations')
            .where('userId', isEqualTo: userId);
      }

      _conversationListener = conversationsQuery.snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified ||
              change.type == DocumentChangeType.added) {
            _checkForNewMessages(
              Conversation.fromFirestore(change.doc),
              userId,
              isShelter,
            );
          }
        }
      });
    }).catchError((error) {
      print('Error determining user type: $error');
    });
  }

  /// Check for new messages in a conversation
  void _checkForNewMessages(
    Conversation conversation,
    String currentUserId,
    bool isShelter,
  ) {
    // Only show notification if the last message was NOT sent by current user
    if (conversation.lastMessageSenderId == currentUserId) {
      return;
    }

    // Check if there are unread messages
    final hasUnread = isShelter
        ? conversation.unreadCountShelter > 0
        : conversation.unreadCountUser > 0;

    if (!hasUnread) return;

    // Create a unique ID for this notification
    final notificationId = conversation.conversationId.hashCode;
    final messageKey = '${conversation.conversationId}_${conversation.lastMessageAt.millisecondsSinceEpoch}';

    // Don't show if we've already seen this message
    if (_seenMessageIds.contains(messageKey)) {
      return;
    }
    _seenMessageIds.add(messageKey);

    // Clean up old seen messages (keep only last 100)
    if (_seenMessageIds.length > 100) {
      final toRemove = _seenMessageIds.length - 100;
      _seenMessageIds.removeAll(_seenMessageIds.take(toRemove));
    }

    // Show notification
    _showNotification(
      id: notificationId,
      title: isShelter ? conversation.userName : conversation.shelterName,
      body: conversation.lastMessage,
      payload: conversation.conversationId,
    );
  }

  /// Show a local notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Stop listening to messages
  void stopListening() {
    _conversationListener?.cancel();
    _conversationListener = null;
    _seenMessageIds.clear();
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}
