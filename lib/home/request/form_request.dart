import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FormYeuCauScreen extends StatefulWidget {
  final String title;

  const FormYeuCauScreen({super.key, required this.title});

  @override
  State<FormYeuCauScreen> createState() => _FormYeuCauScreenState();
}

class _FormYeuCauScreenState extends State<FormYeuCauScreen> {
  File? _selectedImage;
  File? _selectedFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      int sizeInBytes = file.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 100) {
        _showErrorSnackBar("Ảnh vượt quá dung lượng 100MB cho phép.");
        return;
      }

      setState(() {
        _selectedImage = file;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'txt', 'doc', 'docx', 'xls', 'xlsx', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      int sizeInBytes = file.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 100) {
        _showErrorSnackBar("File đính kèm vượt quá dung lượng 100MB cho phép.");
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectionField(Icons.people_outline, "Trương Tô Đình Phước", isPrefilled: true),
                    const SizedBox(height: 12),
                    _buildSelectionField(Icons.calendar_today_outlined, "Giờ bắt đầu"),
                    const SizedBox(height: 12),
                    _buildSelectionField(Icons.calendar_today_outlined, "Giờ kết thúc"),
                    const SizedBox(height: 12),
                    _buildSelectionField(Icons.timelapse, "Chọn ca làm"),
                    const SizedBox(height: 12),
                    _buildReasonField(),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange.shade300, width: 1),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              image: _selectedImage != null
                                  ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _selectedImage == null
                                ? const Center(child: Icon(Icons.camera_alt_outlined, color: Colors.orange, size: 30))
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ảnh mô tả", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                              SizedBox(height: 4),
                              Text("Bấm vào ô bên trái để chọn ảnh từ thư viện. Tối đa 100MB.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: _selectedFile == null
                          ? TextButton.icon(
                        onPressed: _pickFile,
                        icon: const Text("File đính kèm", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        label: const Icon(Icons.add, color: Colors.orange, size: 18),
                      )
                          : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _selectedFile!.path.split('/').last,
                                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                              child: const Icon(Icons.close, color: Colors.red, size: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 28),
                              SizedBox(width: 10),
                              Text("Thành công", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: const Text("Yêu cầu của bạn đã được gửi thành công!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                Navigator.pop(context);
                              },
                              child: const Text("ĐÓNG", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );                  },
                  child: const Text("GỬI YÊU CẦU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField(IconData icon, String hintText, {bool isPrefilled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hintText,
              style: TextStyle(
                color: isPrefilled ? Colors.black87 : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: isPrefilled ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Nhập vào lý do",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 65),
            child: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 20),
          ),
        ),
      ),
    );
  }
}