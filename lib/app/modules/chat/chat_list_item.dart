import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final String lastMessage;
  final VoidCallback? onTap;

  const ChatListItem({
    Key? key,
    required this.imageUrl,
    required this.userName,
    required this.lastMessage,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        radius: 24,
      ),
      title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
