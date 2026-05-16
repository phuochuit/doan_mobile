import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_employee_screen.dart';
import 'edit_employee_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  Future<void> _lockEmployee(BuildContext context, String uid, String name) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận khóa"),
        content: Text("Bạn có chắc muốn vô hiệu hóa tài khoản của $name? Nhân viên này sẽ không thể đăng nhập nữa."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Khóa tài khoản", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isActive': false,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã khóa tài khoản thành công!"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _unlockEmployee(BuildContext context, String uid, String name) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận khôi phục"),
        content: Text("Mở khóa tài khoản cho $name? Nhân viên này sẽ có thể đăng nhập trở lại bằng mật khẩu cũ."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Khôi phục", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isActive': true,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã khôi phục tài khoản thành công!"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildEmployeeList(bool isActiveStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'employee')
          .where('isActive', isEqualTo: isActiveStatus)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              isActiveStatus ? "Chưa có nhân viên nào đang làm việc." : "Không có nhân viên nào đã nghỉ việc.",
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          );
        }

        var employees = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            var emp = employees[index];
            var data = emp.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isActiveStatus ? Colors.orangeAccent : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(data['fullName'] ?? 'Chưa cập nhật tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mã NV: ${data['employeeCode'] ?? 'N/A'} - ${data['department'] ?? ''}"),
                    Text("SĐT: ${data['phone'] ?? 'N/A'}"),
                  ],
                ),
                trailing: isActiveStatus
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditEmployeeScreen(uid: emp.id, employeeData: data)));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock_outline, color: Colors.red),
                      onPressed: () => _lockEmployee(context, emp.id, data['fullName']),
                    ),
                  ],
                )
                    : IconButton(
                  icon: const Icon(Icons.restore, color: Colors.green),
                  onPressed: () => _unlockEmployee(context, emp.id, data['fullName']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Danh sách nhân sự", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "ĐANG LÀM VIỆC"),
              Tab(text: "ĐÃ NGHỈ VIỆC"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEmployeeScreen()));
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: TabBarView(
          children: [
            _buildEmployeeList(true),
            _buildEmployeeList(false),
          ],
        ),
      ),
    );
  }
}