import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';

class UserAvatar extends StatelessWidget {
  final double radius;
  final String? avatarBase64;

  const UserAvatar({super.key, this.radius = 25, this.avatarBase64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        image: avatarBase64 != null && avatarBase64!.isNotEmpty
            ? DecorationImage(
          fit: BoxFit.cover,
          image: MemoryImage(base64Decode(avatarBase64!)),
        )
            : null,
      ),
      child: avatarBase64 == null || avatarBase64!.isEmpty
          ? Icon(Icons.person, color: Colors.grey, size: radius * 1.2)
          : null,
    );
  }
}
