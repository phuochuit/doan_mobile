import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'chi_tiet_nhan_vien_screen.dart';
import 'package:doan_mobile/user_avatar.dart';
import 'package:doan_mobile/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doan_mobile/admin_tools/employee_list_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String role;
  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bytes = await File(pickedFile.path).readAsBytes();

      final String base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'avatarBase64': base64Image,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ảnh đại diện thành công!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showPickerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Thư viện ảnh'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Máy ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Cá nhân",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context),
            const SizedBox(height: 30),
            _buildMenuItem(
              Icons.person_outline,
              "Thông tin cá nhân",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChiTietNhanVienScreen()),
                );
              },
            ),
            _buildMenuItem(
                Icons.assignment_turned_in_outlined, "Hợp đồng lao động",
                trailingText: "Có thông tin"),
            _buildMenuItem(Icons.history, "Lịch sử hoạt động"),
            _buildMenuItem(Icons.attach_money_outlined, "Phiếu lương"),
            _buildMenuItem(Icons.security_outlined, "Chính sách bảo mật"),
            _buildMenuItem(Icons.lock_outline, "Đổi mật khẩu"),

            if (widget.role == 'admin') ...[
              const Divider(thickness: 6, color: Color(0xFFF5F5F5)),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 15, bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("QUẢN LÝ (Dành cho Admin)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              _buildMenuItem(
                Icons.people_alt_outlined,
                "Danh sách nhân sự",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
                  );
                },
              ),
              _buildMenuItem(Icons.calendar_month, "Quản lý ca làm"),
              const Divider(thickness: 6, color: Color(0xFFF5F5F5)),
            ],

            const SizedBox(height: 40),
            _buildTextAction(
                "Đăng xuất",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Đăng xuất"),
                      content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (Route<dynamic> route) => false,
                              );
                            }
                          },
                          child: const Text("Đăng xuất", style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                  );
                }
            ),
            _buildTextAction("Yêu cầu xóa tài khoản", color: Colors.grey),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String fullName = userData['fullName'] ?? 'Chưa cập nhật';
          String phone = userData['phone'] ?? 'Chưa cập nhật';
          String roleDb = userData['role'] ?? 'employee';
          String roleDisplay = roleDb == 'admin' ? 'Quản Lý' : 'Nhân Viên';

          String avatarBase64 = userData['avatarBase64'] ?? '';

          return Column(
            children: [
              GestureDetector(
                onTap: () => _showPickerMenu(context),
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        image: avatarBase64.isNotEmpty
                            ? DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(base64Decode(avatarBase64)),
                        )
                            : null,
                      ),
                      child: _isUploading
                          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                          : (avatarBase64.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                    child: Text(roleDisplay, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(phone, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          );
        }
    );
  }

  Widget _buildMenuItem(IconData icon, String title,
      {String? trailingText, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            if (trailingText != null)
              Text(trailingText,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAction(String text, {Color color = Colors.black, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}