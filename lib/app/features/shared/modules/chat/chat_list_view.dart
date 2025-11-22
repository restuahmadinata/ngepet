import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../../models/conversation.dart';
import 'chat_list_controller.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.poppins(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.conversations.isEmpty) {
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.userType.value == UserType.shelter
                        ? 'You\'ll see messages from users interested in your pets here'
                        : 'Start chatting with shelters about pets you\'re interested in',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.conversations.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.neutral200,
          ),
          itemBuilder: (context, index) {
            final conversation = controller.conversations[index];
            final hasUnread = controller.getUnreadCount(conversation) > 0;
            final unreadCount = controller.getUnreadCount(conversation);

            return _ConversationTile(
              conversation: conversation,
              hasUnread: hasUnread,
              unreadCount: unreadCount,
              isShelter: controller.userType.value == UserType.shelter,
              onTap: () {
                // Mark as read when opening chat
                controller.markAsRead(conversation.conversationId);
                
                // Navigate to chat detail
                Get.to(() => ChatDetailView(conversation: conversation));
              },
            );
          },
        );
      }),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool hasUnread;
  final int unreadCount;
  final bool isShelter;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.hasUnread,
    required this.unreadCount,
    required this.isShelter,
    required this.onTap,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // Day name
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // Show different name based on user type
    final displayName = isShelter ? conversation.userName : conversation.shelterName;

    return Material(
      color: hasUnread ? primaryColor.withOpacity(0.05) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: conversation.petImageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.pets, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Conversation Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(conversation.lastMessageAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: hasUnread ? primaryColor : Colors.grey,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    
                    // Pet name
                    Text(
                      'About: ${conversation.petName}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Last message
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage.isEmpty 
                                ? 'No messages yet' 
                                : conversation.lastMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: hasUnread ? Colors.black87 : Colors.grey.shade600,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
