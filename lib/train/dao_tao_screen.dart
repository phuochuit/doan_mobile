import 'package:flutter/material.dart';

class DaoTaoScreen extends StatelessWidget {
  const DaoTaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Chỉ giữ lại cái khung body, không cần Scaffold cũng được
    // hoặc giữ Scaffold nhưng PHẢI XÓA bottomNavigationBar.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatistics(),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 25),
              _buildSectionTitle("THIÊN LÝ - LỘ TRÌNH ĐÀO TẠO CHUNG"),
              _buildCourseCard("HỘI NHẬP", "02:54 23-01-2026"),
              _buildCourseCard("THÔNG TIN CẦN BIẾT", "07:54 19-06-2025"),
              _buildCourseCard("NỀN TẢNG PHẦN MỀM", "08:32 19-06-2025"),
            ],
          ),
        ),
      ),
      // ĐÃ XÓA PHẦN _buildBottomNav() Ở ĐÂY
    );
  }

  // --- Mấy hàm bổ trợ bên dưới giữ nguyên ---
  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📊 Thống kê hiện tại:",
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        _statRow("Tổng số bài test khóa học:", "1"),
        _statRow("Bài test khóa học đã hoàn thành:", "1"),
        _statRow("Số khóa học:", "47"),
        _statRow("Số khóa học đã hoàn thành:", "3"),
      ],
    );
  }

  Widget _statRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _orangeButton("KIỂM TRA"),
        _orangeButton("LỘ TRÌNH"),
        _orangeButton("QUÉT QR"),
      ],
    );
  }

  Widget _orangeButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {},
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCourseCard(String title, String time) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
              child: Text("CƠM NIÊU\nTHIÊN LÝ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(time,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
