import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'chat_list_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import

class ChatController extends GetxController {}

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
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
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
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
          ),
        ),
      ),
    );
  }
}
