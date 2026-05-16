import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatMessage {
  final String type;
  final String content;
  final bool isMe;

  ChatMessage({required this.type, required this.content, required this.isMe});
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  const ChatDetailScreen({super.key, required this.userName, required this.userAvatar});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _sendTextMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(type: 'text', content: _messageController.text.trim(), isMe: true));
    });
    _messageController.clear();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _checkAndSendFile(File(pickedFile.path), 'image');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      String extension = result.files.single.extension?.toLowerCase() ?? '';

      String msgType = ['jpg', 'jpeg', 'png'].contains(extension) ? 'image' : 'file';
      _checkAndSendFile(file, msgType);
    }
  }

  void _checkAndSendFile(File file, String type) {
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File vượt quá giới hạn 100MB!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(type: type, content: file.path, isMe: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange.shade300,
              backgroundImage: widget.userAvatar.startsWith("http") ? NetworkImage(widget.userAvatar) : null,
              child: !widget.userAvatar.startsWith("http")
                  ? Text(widget.userAvatar, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                const Text("25-01-2026", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black87), onPressed: () {}),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Tin nhắn",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add, color: Colors.black87), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.black87), onPressed: _takePhoto),
                  IconButton(icon: const Icon(Icons.image_outlined, color: Colors.black87), onPressed: _pickFile),
                  IconButton(icon: const Icon(Icons.send, color: Colors.orange), onPressed: _sendTextMessage),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 50),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isMe ? Colors.orange.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: _buildMessageContent(msg),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg) {
    if (msg.type == 'text') {
      return Text(msg.content, style: const TextStyle(color: Colors.black87, fontSize: 14));
    } else if (msg.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(msg.content), width: 200, fit: BoxFit.cover),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.orange, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              msg.content.split('/').last,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      );
    }
  }
}