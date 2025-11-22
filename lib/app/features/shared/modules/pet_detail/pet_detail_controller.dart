import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/conversation.dart';
import '../chat/chat_detail_view.dart';

class PetDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final hasApplied = false.obs;
  final isLoading = true.obs;
  final isLoadingChat = false.obs;
  // Removed requestStatus and applicationStatus fields
  String? applicationId;

  Future<void> checkApplicationStatus(String petId) async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        hasApplied.value = false;
        return;
      }

      // Check if user has already applied for this pet
      final querySnapshot = await _firestore
          .collection('adoption_applications')
          .where('petId', isEqualTo: petId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
  final doc = querySnapshot.docs.first;
        hasApplied.value = true;
        applicationId = doc.id;
  // We only track whether user has applied; detailed status view is in Adoption Status screen.
        print('✅ User has already applied for this pet');
      } else {
        hasApplied.value = false;
        applicationId = null;
  // Resetting status values isn't necessary here
        print('✅ User has not applied for this pet');
      }
    } catch (e) {
      print('❌ Error checking application status: $e');
      hasApplied.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel logic should only be handled via AdoptionStatusController to keep UI flows consistent.

  /// Start or continue a chat with the shelter about this pet
  Future<void> startChat(Map<String, dynamic> petData) async {
    try {
      isLoadingChat.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Please login to chat with shelter');
        return;
      }

      final userId = user.uid;
      final shelterId = petData['shelterId']?.toString() ?? '';
      final petId = petData['petId']?.toString() ?? petData['id']?.toString() ?? '';

      if (shelterId.isEmpty || petId.isEmpty) {
        Get.snackbar('Error', 'Invalid pet or shelter data');
        return;
      }

      // Check if conversation already exists
      final existingConversation = await _firestore
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .where('petId', isEqualTo: petId)
          .limit(1)
          .get();

      Conversation conversation;

      if (existingConversation.docs.isNotEmpty) {
        // Use existing conversation
        conversation = Conversation.fromFirestore(existingConversation.docs.first);
      } else {
        // Create new conversation
        final conversationRef = _firestore.collection('conversations').doc();
        
        // Get user data
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userName = userDoc.data()?['fullName'] ?? 'User';
        final userPhoto = userDoc.data()?['profilePhoto'];
        
        // Get shelter data
        final shelterDoc = await _firestore.collection('shelters').doc(shelterId).get();
        final shelterName = shelterDoc.data()?['shelterName'] ?? 'Shelter';
        final shelterLocation = shelterDoc.data()?['city'] ?? 'Location';
        final shelterPhoto = shelterDoc.data()?['profilePhotoUrl'];

        conversation = Conversation(
          conversationId: conversationRef.id,
          userId: userId,
          shelterId: shelterId,
          petId: petId,
          userName: userName,
          shelterName: shelterName,
          shelterLocation: shelterLocation,
          petName: petData['petName']?.toString() ?? petData['name']?.toString() ?? 'Pet',
          petImageUrl: (petData['imageUrls'] != null && (petData['imageUrls'] as List).isNotEmpty)
              ? (petData['imageUrls'] as List)[0].toString()
              : (petData['imageUrl']?.toString() ?? ''),
          userPhoto: userPhoto,
          shelterPhoto: shelterPhoto,
          lastMessage: '',
          lastMessageAt: DateTime.now(),
          lastMessageSenderId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await conversationRef.set(conversation.toMap());
      }

      // Navigate to chat detail
      Get.to(() => ChatDetailView(conversation: conversation));
    } catch (e) {
      print('Error starting chat: $e');
      Get.snackbar('Error', 'Failed to start chat. Please try again.');
    } finally {
      isLoadingChat.value = false;
    }
  }
}
