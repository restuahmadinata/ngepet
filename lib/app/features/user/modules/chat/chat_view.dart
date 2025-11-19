import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'chat_list_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../common/widgets/rectangle_search_bar.dart';

class ChatController extends GetxController {
  final RxString searchQuery = ''.obs;
  final textController = TextEditingController();

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  List<Map<String, String>> filterChats(List<Map<String, String>> chats) {
    if (searchQuery.value.trim().isEmpty) {
      return chats;
    }
    
    final query = searchQuery.value.toLowerCase();
    return chats.where((chat) {
      final userName = chat['userName']!.toLowerCase();
      final lastMessage = chat['lastMessage']!.toLowerCase();
      return userName.contains(query) || lastMessage.contains(query);
    }).toList();
  }
}

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    
    // Dummy data
    final chats = List.generate(30, (index) {
      return {
        'imageUrl':
            'https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/${(index % 10) + 1}.jpg',
        'userName': 'User $index',
        'lastMessage': 'This is message number $index',
      };
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 32,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: Text(
            'Chats',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              RectangleSearchBar(
                hintText: 'Search chats...',
                onChanged: controller.onSearchChanged,
                controller: controller.textController,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final filteredChats = controller.filterChats(chats);
                  
                  if (filteredChats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No chats found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = filteredChats[index];
                      return ChatListItem(
                        // Use CachedNetworkImage for profile picture
                        imageWidget: CachedNetworkImage(
                          imageUrl: chat['imageUrl']!,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(backgroundImage: imageProvider, radius: 24),
                          placeholder: (context, url) => CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 24,
                            child: Icon(Icons.person, color: Colors.grey),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 24,
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                        userName: chat['userName']!,
                        lastMessage: chat['lastMessage']!,
                        onTap: () {},
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
