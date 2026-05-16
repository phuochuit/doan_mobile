import 'package:flutter/material.dart';
import 'form_request.dart';

class ChooseRequest extends StatelessWidget {
  const ChooseRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> requestTypes = [
      {"icon": Icons.history_toggle_off, "title": "Quên chấm công"},
      {"icon": Icons.access_time, "title": "Làm thêm giờ"},
      {"icon": Icons.bed_outlined, "title": "Nghỉ phép"},
      {"icon": Icons.assignment_ind_outlined, "title": "Chấm công hộ"},
      {"icon": Icons.work_outline, "title": "Đi công tác"},
      {"icon": Icons.attach_money, "title": "Đề xuất điều chỉnh lương"},
      {"icon": Icons.trending_up, "title": "Đề xuất thăng tiến"},
      {"icon": Icons.swap_horiz, "title": "Đề xuất điều chuyển"},
      {"icon": Icons.exit_to_app, "title": "Đơn thôi việc"},
      {"icon": Icons.person_add_alt_1_outlined, "title": "Đề xuất tuyển dụng"},
      {"icon": Icons.checkroom, "title": "Đề xuất đồng phục"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chọn loại yêu cầu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: requestTypes.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFEEEEEE),
          indent: 60,
        ),
        itemBuilder: (context, index) {
          final item = requestTypes[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item["icon"],
                color: Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              item["title"],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormYeuCauScreen(title: item["title"]),
                ),
              );},
          );
        },
      ),
    );
  }
}