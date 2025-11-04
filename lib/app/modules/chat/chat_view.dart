
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'chat_list_item.dart';

class ChatController extends GetxController {}

class ChatView extends StatelessWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final chats = List.generate(30, (index) {
      return {
        'imageUrl': 'https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/${(index % 10) + 1}.jpg',
        'userName': 'User $index',
        'lastMessage': 'This is message number $index'
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatListItem(
              imageUrl: chat['imageUrl']!,
              userName: chat['userName']!,
              lastMessage: chat['lastMessage']!,
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
