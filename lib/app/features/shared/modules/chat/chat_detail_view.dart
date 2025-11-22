import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import '../../../../models/conversation.dart';
import '../../../../models/message.dart';
import '../../../../common/widgets/pet_list.dart';
import 'chat_detail_controller.dart';

class ChatDetailView extends StatelessWidget {
  final Conversation conversation;

  const ChatDetailView({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatDetailController());
    controller.initConversation(conversation);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 26),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            () {
              final photoUrl = controller.isShelter
                  ? conversation.userPhoto
                  : conversation.shelterPhoto;
              
              return CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.neutral200,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImageProvider(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        color: AppColors.neutral500,
                        size: 24,
                      )
                    : null,
              );
            }(),
            const SizedBox(width: 14),
            Expanded(
              child: controller.isShelter
                  ? Text(
                      conversation.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          conversation.shelterName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                conversation.shelterLocation,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Pet Card
          _buildPetCard(context),

          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.senderId == controller.currentUserId;

                  return _MessageBubble(
                    message: message,
                    isMe: isMe,
                    onEdit: () => controller.showEditDialog(message),
                    onDelete: () => controller.showDeleteConfirmation(message),
                  );
                },
              );
            }),
          ),

          // Edit indicator
          Obx(() {
            if (controller.editingMessage.value != null) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.amber.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editing message',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: controller.cancelEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Message Input
          _buildMessageInput(context, controller),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPetData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final petData = snapshot.data ?? {
            'imageUrl': conversation.petImageUrl,
            'name': conversation.petName,
            'breed': 'Unknown',
            'age': '0',
            'shelter': conversation.shelterName,
            'location': conversation.shelterLocation,
            'gender': 'Unknown',
          };

          return PetListItem(
            imageUrl: petData['imageUrl']!,
            name: petData['name']!,
            breed: petData['breed']!,
            age: petData['age']!,
            shelter: petData['shelter']!,
            location: petData['location']!,
            gender: petData['gender']!,
            onAdoptPressed: null, // No adopt button in chat
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchPetData() async {
    try {
      final petDoc = await FirebaseFirestore.instance
          .collection('pets')
          .doc(conversation.petId)
          .get();

      if (petDoc.exists) {
        final data = petDoc.data()!;
        return {
          'imageUrl': conversation.petImageUrl,
          'name': conversation.petName,
          'breed': data['breed']?.toString() ?? 'Unknown',
          'age': (data['ageMonths'] ?? 0).toString(),
          'shelter': conversation.shelterName,
          'location': conversation.shelterLocation,
          'gender': data['gender']?.toString() ?? 'Unknown',
        };
      }
    } catch (e) {
      print('Error fetching pet data: $e');
    }

    // Return default values if fetch fails
    return {
      'imageUrl': conversation.petImageUrl,
      'name': conversation.petName,
      'breed': 'Unknown',
      'age': '0',
      'shelter': conversation.shelterName,
      'location': conversation.shelterLocation,
      'gender': 'Unknown',
    };
  }

  Widget _buildMessageInput(BuildContext context, ChatDetailController controller) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => Material(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: controller.isSending.value
                        ? null
                        : () {
                            if (controller.editingMessage.value != null) {
                              // Save edited message
                              controller.editMessage(
                                controller.editingMessage.value!,
                                controller.messageController.text,
                              );
                            } else {
                              // Send new message
                              controller.sendMessage();
                            }
                          },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: controller.isSending.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              controller.editingMessage.value != null
                                  ? Icons.check
                                  : Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GestureDetector(
          onLongPress: isMe && !message.isDeleted
              ? () => _showMessageOptions(context)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: message.isDeleted
                  ? Colors.grey.shade200
                  : isMe
                      ? primaryColor.withOpacity(0.15)
                      : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
              ),
              border: isMe
                  ? null
                  : Border.all(color: AppColors.neutral300, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.messageContent,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: message.isDeleted
                        ? Colors.grey
                        : Colors.black87,
                    fontStyle:
                        message.isDeleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.sentAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    if (message.isEdited && !message.isDeleted) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(edited)',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead ? primaryColor : Colors.grey,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.canEdit())
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(
                      'Edit Message',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      'Can edit for ${15 - DateTime.now().difference(message.sentAt).inMinutes} more minutes',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    onTap: () {
                      Get.back();
                      onEdit();
                    },
                  ),
                if (message.canDelete())
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete Message',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                    subtitle: Text(
                      'Can delete for ${6 - DateTime.now().difference(message.sentAt).inHours} more hours',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    onTap: () {
                      Get.back();
                      onDelete();
                    },
                  ),
                if (!message.canEdit() && !message.canDelete())
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Message can no longer be edited or deleted',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
