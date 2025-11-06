import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final Widget imageWidget; // Change from String imageUrl to Widget imageWidget
  final String userName;
  final String lastMessage;
  final VoidCallback? onTap;

  const ChatListItem({
    Key? key,
    required this.imageWidget, // Updated parameter
    required this.userName,
    required this.lastMessage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: imageWidget, // Use imageWidget directly (which is CachedNetworkImage)
      title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}