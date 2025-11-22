import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../shared/modules/chat/chat_list_view.dart' as shared;

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
    return const shared.ChatListView();
  }
}
