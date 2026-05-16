import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chatUsers = [
      {
        "name": "Cơm Niêu Thiên Lý",
        "avatar": "TL",
        "lastMessage": "Thông báo mới",
        "isOnline": true,
        "isHtml": false
      },
      {
        "name": "Nguyễn Thị Tứ",
        "avatar": "https://i.pravatar.cc/150?img=9",
        "lastMessage": "<p><span style=\"color: rgb(0, 85, 255)\"><br><...",
        "isOnline": true,
        "isHtml": true // Giả lập tin nhắn chứa mã HTML
      },
      {
        "name": "Trần Văn A",
        "avatar": "", // Avatar trống sẽ tự sinh màu cam
        "lastMessage": "J zậy cha",
        "isOnline": true,
        "isHtml": false
      },
      {
        "name": "Nguyễn Thị Hoàng Nhi",
        "avatar": "HN",
        "lastMessage": "Hình ảnh",
        "isOnline": true,
        "isHtml": false
      },
      {
        "name": "Nguyễn Thị Hoàng Nhi",
        "avatar": "HN",
        "lastMessage": "Chưa có cuộc hội thoại",
        "isOnline": true,
        "isHtml": false
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text("Chat", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.separated(
        itemCount: chatUsers.length,
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE), indent: 80),
        itemBuilder: (context, index) {
          final user = chatUsers[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.orange.shade300,
              backgroundImage: user["avatar"].toString().startsWith("http")
                  ? NetworkImage(user["avatar"])
                  : null,
              child: !user["avatar"].toString().startsWith("http")
                  ? Text(user["avatar"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (user["isOnline"])
                  const Text("Online", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                user["lastMessage"],
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    userName: user["name"],
                    userAvatar: user["avatar"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}