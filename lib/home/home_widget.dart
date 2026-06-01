import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'work_schedule.dart';
import 'request/request_personel.dart';
import 'timekeeping_history/tab_worksheet.dart';
import 'package:doan_mobile/user_avatar.dart';
import 'package:doan_mobile/admin_tools/add_employee_screen.dart';
import 'package:doan_mobile/admin_tools/edit_employee_screen.dart';
import 'package:doan_mobile/admin_tools/employee_list_screen.dart';
import 'timekeeping_history/history_time.dart' hide Column;

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const SizedBox();
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String fullName = data['fullName'] ?? 'Chưa cập nhật';
          String roleDb = data['role'] ?? 'employee';
          String roleDisplay = roleDb == 'admin' ? 'Quản Lý' : 'Nhân Viên';
          String branch = data['branchId'] ?? 'Chi nhánh';
          String avatarBase64 = data['avatarBase64'] ?? '';

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                UserAvatar(radius: 20, avatarBase64: avatarBase64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                            child: Text(roleDisplay, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          Text(branch, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.notifications_none, color: Colors.black87),
              ],
            ),
          );
        }
    );
  }
}

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Tìm kiếm",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: const Icon(Icons.tune, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class HomeDateSelector extends StatelessWidget {
  const HomeDateSelector({super.key});

  String _getWeekdayString(int weekday) {
    switch (weekday) {
      case 1: return "T2";
      case 2: return "T3";
      case 3: return "T4";
      case 4: return "T5";
      case 5: return "T6";
      case 6: return "T7";
      case 7: return "CN";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkSchedule()));
      },
      child: Container(
        height: 70,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(weekDates.length, (index) {
            DateTime date = weekDates[index];
            bool isToday = (date.day == now.day && date.month == now.month && date.year == now.year);

            return Container(
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isToday ? Border.all(color: Colors.orange, width: 1.5) : null,
                boxShadow: isToday ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekdayString(date.weekday),
                    style: TextStyle(color: isToday ? Colors.orange : Colors.grey, fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    date.day.toString(),
                    style: TextStyle(color: isToday ? Colors.orange : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (isToday)
                    Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.orange.shade500], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events, color: Colors.white),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thi đua nhà hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Xem bảng xếp hạng điểm", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}

class HomeIconGrid extends StatelessWidget {
  const HomeIconGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator(color: Colors.orange)),
            );
          }

          bool isAdmin = false;
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            isAdmin = data['role'] == 'admin';
          }

          List<Map<String, dynamic>> gridItems = [
            {"icon": Icons.assignment_ind_outlined, "label": "Yêu cầu nhân sự"},
            {"icon": Icons.settings_outlined, "label": "Vận hành"},
            {"icon": Icons.bar_chart_outlined, "label": "Báo cáo"},
            {"icon": Icons.fact_check_outlined, "label": "Biên bản/ TT"},
            {"icon": Icons.history_outlined, "label": "Lịch sử\nchấm công"},
            {"icon": Icons.menu_book_outlined, "label": "Kiểm tra"},
          ];
          

          if (isAdmin) {
            gridItems.addAll([
              {"icon": Icons.table_chart_outlined, "label": "Bảng công\nAdmin"},
              {"icon": Icons.groups_outlined, "label": "Danh sách\nnhân sự"},
              {"icon": Icons.work_outline, "label": "Thêm nhân sự"},
            ]);
          }

          gridItems.addAll([
            {"icon": Icons.folder_open_outlined, "label": "Thư mục"},
            {"icon": Icons.headset_mic_outlined, "label": "Góp ý/\nKhiếu nại"},
            {"icon": Icons.stars_outlined, "label": "KPI, Đánh giá\nđồng nghiệp"},
            {"icon": Icons.build_outlined, "label": "Bảo trì thiết bị"},
            {"icon": Icons.support_agent_outlined, "label": "Hỗ trợ"},
            {"icon": Icons.storefront_outlined, "label": "Tuyển dụng\nNhà Hàng"},
            {"icon": Icons.computer_outlined, "label": "Tuyển dụng\nVăn Phòng"},
          ]);

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 15,
            ),
            itemCount: gridItems.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (gridItems[index]["label"] == "Yêu cầu nhân sự") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestPersonel()));
                  }
                  if (gridItems[index]["label"] == "Lịch sử\nchấm công") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LichSuChamCongScreen()));
                  }
                  if (isAdmin) {
                    if (gridItems[index]["label"] == "Bảng công\nAdmin") {
                      Navigator.push(
                        context,
                          MaterialPageRoute(builder: (context) => const AdminBangCongScreen()),
                      );
                    }

                    if (gridItems[index]["label"] == "Thêm nhân sự") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
                      );
                    }

                    if (gridItems[index]["label"] == "Danh sách\nnhân sự") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
                      );
                    }
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(gridItems[index]["icon"], color: Colors.orange, size: 50),
                      const SizedBox(height: 5),
                      Text(gridItems[index]["label"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
}

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final String action;

  const HomeSectionTitle({super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(action, style: const TextStyle(color: Colors.blue, fontSize: 13)),
        ],
      ),
    );
  }
}

class HomeNotificationList extends StatelessWidget {
  const HomeNotificationList({super.key});

  Widget _buildNotifItem(String title, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 4.0), child: Icon(Icons.circle, size: 8, color: Colors.blue)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildNotifItem("THÔNG BÁO THI THĂNG TIẾN THÁNG 04/2026", "30-03-2026 11:33"),
          _buildNotifItem("[OPS THÔNG BÁO] - HƯỚNG DẪN TƯƠNG TÁC CÔNG VIỆC PHÒNG BAN", "30-03-2026 09:17"),
        ],
      ),
    );
  }
}

class HomeNewsList extends StatelessWidget {
  const HomeNewsList({super.key});

  Widget _buildNewsItem(String title, String subtitle, String time, String views, bool hasImage) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const Spacer(),
                    const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(views, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: hasImage ? const Icon(Icons.storefront, color: Colors.orange, size: 30) : const Icon(Icons.image_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildNewsItem("Khai trương Chi nhánh 38 - Cơm Niêu Thiên Lý chính thức đặt dấu ấn...", "Ngày 03/12/2025 đánh dấu một bước tiến...", "23-12-2025 - 14:06", "700", true),
          _buildNewsItem("THIÊN LÝ CÙNG HÀNH TRÌNH KẾT NỐI SINH VIÊN - LAN TỎA GIÁ TRỊ...", "Ngày hội việc làm JOB FAIR 2025 tại Đại...", "07-11-2025 - 14:46", "930", false),
        ],
      ),
    );
  }
}
