import 'package:flutter/material.dart';
import '../../../../common/widgets/lottie_loading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../../models/conversation.dart';
import '../../../../models/enums.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';
import 'chat_list_controller.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  Future<void> _refreshData() async {
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
    // Data will automatically refresh because we're using StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatListController());

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.userType.value == UserType.unknown) return SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.report),
              onPressed: () {
                final entityType = controller.userType.value == UserType.shelter ? EntityType.user : EntityType.shelter;
                Get.toNamed('/select-entity-to-report', arguments: {'entityType': entityType});
              },
            );
          }),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  RectangleSearchBar(
                    hintText: 'Search messages...',
                    onChanged: controller.onSearchChanged,
                    controller: controller.searchTextController,
                  ),
                  const SizedBox(height: 24),
                  Obx(() => _buildContent(controller)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ChatListController controller) {
    // Show search results if searching
    if (controller.searchQuery.value.trim().isNotEmpty) {
      return _buildSearchResults(controller);
    }

    // Show regular conversation list
    return _buildConversationList(controller);
  }

  Widget _buildSearchResults(ChatListController controller) {
    final filteredConversations = controller.conversations.where((conversation) {
      final query = controller.searchQuery.value.toLowerCase();
      final userName = conversation.userName.toLowerCase();
      final shelterName = conversation.shelterName.toLowerCase();
      final petName = conversation.petName.toLowerCase();
      final lastMessage = conversation.lastMessage.toLowerCase();
      final isShelter = controller.userType.value == UserType.shelter;
      final displayName = isShelter ? userName : shelterName;
      
      return displayName.contains(query) ||
             petName.contains(query) ||
             lastMessage.contains(query);
    }).toList();

    if (filteredConversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No messages found',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredConversations.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.neutral200,
      ),
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        final hasUnread = controller.getUnreadCount(conversation) > 0;
        final unreadCount = controller.getUnreadCount(conversation);
        final isFirst = index == 0;
        final isLast = index == filteredConversations.length - 1;

        return _ConversationTile(
          conversation: conversation,
          hasUnread: hasUnread,
          unreadCount: unreadCount,
          isShelter: controller.userType.value == UserType.shelter,
          isFirst: isFirst,
          isLast: isLast,
          onTap: () {
            controller.markAsRead(conversation.conversationId);
            Get.to(() => ChatDetailView(conversation: conversation));
          },
        );
      },
    );
  }

  Widget _buildConversationList(ChatListController controller) {
    if (controller.isLoading.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LottieLoading(),
        ),
      );
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.userType.value == UserType.shelter
                    ? 'You\'ll see messages from users interested in your pets here'
                    : 'Start chatting with shelters about pets you\'re interested in',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
        final isFirst = index == 0;
        final isLast = index == controller.conversations.length - 1;

        return _ConversationTile(
          conversation: conversation,
          hasUnread: hasUnread,
          unreadCount: unreadCount,
          isShelter: controller.userType.value == UserType.shelter,
          isFirst: isFirst,
          isLast: isLast,
          onTap: () {
            controller.markAsRead(conversation.conversationId);
            Get.to(() => ChatDetailView(conversation: conversation));
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool hasUnread;
  final int unreadCount;
  final bool isShelter;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.hasUnread,
    required this.unreadCount,
    required this.isShelter,
    required this.isFirst,
    required this.isLast,
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

    // Determine border radius based on position
    BorderRadius? borderRadius;
    if (isFirst && isLast) {
      // Only one item - round all corners
      borderRadius = BorderRadius.circular(12);
    } else if (isFirst) {
      // First item - round top corners
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    } else if (isLast) {
      // Last item - round bottom corners
      borderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }

    return Material(
      color: hasUnread ? primaryColor.withOpacity(0.05) : Colors.white,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
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
