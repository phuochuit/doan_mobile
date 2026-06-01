import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TabBangCong extends StatelessWidget {
  final Map<String, dynamic>? data;

  const TabBangCong({super.key, this.data});

  String _formatMoney(num money) {
    return "${money.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => "${match[1]}.",
    )}đ";
  }

  Future<void> _xacNhanLuong(BuildContext context, Map<String, dynamic> d) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập")),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};
    final hourlyRate = (userData['hourlyRate'] ?? 28000) as num;

    final tongPhutLam = (d["tongPhutLam"] ?? 0) as int;
    final tongGioLam = tongPhutLam / 60;
    final tongLuong = tongGioLam * hourlyRate;

    await FirebaseFirestore.instance.collection("salary_confirmations").add({
      "userId": user.uid,
      "email": user.email,
      "fullName": userData['fullName'] ?? '',
      "employeeCode": userData['employeeCode'] ?? '',
      "month": DateTime.now().month,
      "year": DateTime.now().year,
      "ngayCong": d["ngayCong"],
      "gioThucTe": d["gioThucTe"],
      "tongPhutLam": tongPhutLam,
      "tongGioLam": tongGioLam,
      "hourlyRate": hourlyRate,
      "totalSalary": tongLuong,
      "status": "confirmed",
      "confirmedAt": FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã xác nhận phiếu lương"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = data ?? {
      "ngayCong": "0",
      "gioTieuChuan": "0 giờ 0 phút",
      "gioThucTe": "0 giờ 0 phút",
      "tongGioChamHo": "0 giờ 0 phút",
      "gioChamHo": "0 giờ 0 phút",
      "gioDuocThem": "0 giờ 0 phút",
      "tongGioDuyet": "0 giờ 0 phút",
      "gioQuen": "0 giờ 0 phút",
      "gioNghiBu": "0 giờ 0 phút",
      "gioNghiPhep": "0 giờ 0 phút",
      "gioCongTac": "0 giờ 0 phút",
      "gioTangCa": "0 giờ 0 phút",
      "gioLeTet": "0 giờ 0 phút",
      "gioDiLamSom": "0 giờ 0 phút",
      "gioDiLamSomMuon": "0 giờ 0 phút",
      "gioVeSomMuon": "0 giờ 0 phút",
      "tongPhutLam": 0,
    };

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseAuth.instance.currentUser == null
          ? null
          : FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final hourlyRate = (userData?['hourlyRate'] ?? 28000) as num;

        final tongPhutLam = (d["tongPhutLam"] ?? 0) as int;
        final tongGioLam = tongPhutLam / 60;
        final tongLuong = tongGioLam * hourlyRate;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phiếu lương tạm tính",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildSalaryRow("Tổng giờ làm", "${tongGioLam.toStringAsFixed(1)} giờ"),
                  _buildSalaryRow("Lương theo giờ", _formatMoney(hourlyRate)),
                  _buildSalaryRow("Tổng lương", _formatMoney(tongLuong)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _xacNhanLuong(context, d),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        "Xác nhận lương",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildStatRow("Ngày công thực tế", d["ngayCong"].toString()),
            _buildStatRow("Giờ công tiêu chuẩn", d["gioTieuChuan"].toString()),
            _buildStatRow("Giờ công thực tế", d["gioThucTe"].toString(), hasArrow: true),

            _buildStatRow("Giờ công chấm hộ/thêm:", d["tongGioChamHo"].toString(), hasArrow: true),
            _buildSubItemRow("Giờ công chấm hộ", d["gioChamHo"].toString()),
            _buildSubItemRow("Giờ công được thêm", d["gioDuocThem"].toString()),

            _buildStatRow("Giờ công được duyệt:", d["tongGioDuyet"].toString(), hasArrow: true),
            _buildSubItemRow("Giờ công quên chấm công", d["gioQuen"].toString()),
            _buildSubItemRow("Giờ công nghỉ bù", d["gioNghiBu"].toString()),
            _buildSubItemRow("Giờ công nghỉ phép", d["gioNghiPhep"].toString()),
            _buildSubItemRow("Giờ công công tác", d["gioCongTac"].toString()),
            _buildSubItemRow("Giờ công tăng ca/thêm giờ", d["gioTangCa"].toString()),

            _buildStatRow("Giờ công lễ tết", d["gioLeTet"].toString()),
            _buildStatRow("Số giờ đi làm sớm", d["gioDiLamSom"].toString()),
            _buildStatRow("Số giờ đi làm sớm/muộn", d["gioDiLamSomMuon"].toString()),
            _buildStatRow("Số giờ về sớm/muộn", d["gioVeSomMuon"].toString()),
          ],
        );
      },
    );
  }

  Widget _buildSalaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value, {bool hasArrow = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (hasArrow) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ]
                ],
              )
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildSubItemRow(String title, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text("• ", style: TextStyle(fontSize: 18, color: Colors.black87)),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class AdminBangCongScreen extends StatefulWidget {
  const AdminBangCongScreen({super.key});

  @override
  State<AdminBangCongScreen> createState() => _AdminBangCongScreenState();
}

class _AdminBangCongScreenState extends State<AdminBangCongScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  String _formatMoney(num money) {
    return "${money.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => "${match[1]}.",
    )}đ";
  }

  String _formatHour(num minutes) {
    final hour = minutes / 60;
    return "${hour.toStringAsFixed(1)} giờ";
  }

  Future<List<Map<String, dynamic>>> _loadAdminBangCong() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    final logsSnapshot = await FirebaseFirestore.instance
        .collection('checkin_logs')
        .where('month', isEqualTo: _selectedMonth.month)
        .get();

    final logs = logsSnapshot.docs.where((doc) {
      final data = doc.data();
      return data['year'] == _selectedMonth.year;
    }).toList();

    List<Map<String, dynamic>> result = [];

    for (final userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();

      final userLogs = logs.where((log) {
        final data = log.data();
        return data['userId'] == userDoc.id && data['status'] == 'completed';
      }).toList();

      final workDays = userLogs.length;

      final totalMinutes = userLogs.fold<int>(0, (sum, log) {
        final data = log.data();
        return sum + ((data['workMinutes'] ?? 0) as int);
      });

      final overtimeMinutes = userLogs.fold<int>(0, (sum, log) {
        final data = log.data();
        return sum + ((data['overtimeMinutes'] ?? 0) as int);
      });

      final hourlyRate = (userData['hourlyRate'] ?? 28000) as num;
      final totalSalary = (totalMinutes / 60) * hourlyRate;

      result.add({
        'userId': userDoc.id,
        'fullName': userData['fullName'] ?? 'Chưa cập nhật',
        'employeeCode': userData['employeeCode'] ?? '',
        'department': userData['department'] ?? '',
        'hourlyRate': hourlyRate,
        'workDays': workDays,
        'leaveDays': 0,
        'totalMinutes': totalMinutes,
        'overtimeMinutes': overtimeMinutes,
        'totalSalary': totalSalary,
      });
    }

    return result;
  }

  Future<void> _chotLuong(Map<String, dynamic> employee) async {
    await FirebaseFirestore.instance.collection('salary_slips').add({
      'userId': employee['userId'],
      'fullName': employee['fullName'],
      'employeeCode': employee['employeeCode'],
      'department': employee['department'],
      'month': _selectedMonth.month,
      'year': _selectedMonth.year,
      'workDays': employee['workDays'],
      'leaveDays': employee['leaveDays'],
      'totalMinutes': employee['totalMinutes'],
      'overtimeMinutes': employee['overtimeMinutes'],
      'hourlyRate': employee['hourlyRate'],
      'totalSalary': employee['totalSalary'],
      'status': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã chốt lương cho ${employee['fullName']}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    String monthStr = _selectedMonth.month.toString().padLeft(2, '0');
    String yearStr = _selectedMonth.year.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Bảng công tổng hợp",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text("Tháng", style: TextStyle(color: Colors.black87, fontSize: 14)),
                const SizedBox(width: 10),
                Container(width: 1, height: 20, color: Colors.grey.shade300),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 24, color: Colors.black87),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        "01 - $daysInMonth/$monthStr/$yearStr",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 24, color: Colors.black87),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadAdminBangCong(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }

                final employees = snapshot.data ?? [];

                if (employees.isEmpty) {
                  return const Center(child: Text("Chưa có dữ liệu nhân viên"));
                }

                final totalSalary = employees.fold<num>(0, (sum, item) {
                  return sum + (item['totalSalary'] as num);
                });

                final totalMinutes = employees.fold<num>(0, (sum, item) {
                  return sum + (item['totalMinutes'] as num);
                });

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tổng hợp tháng",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text("Số nhân viên: ${employees.length}"),
                            Text("Tổng giờ công: ${_formatHour(totalMinutes)}"),
                            Text("Tổng lương: ${_formatMoney(totalSalary)}"),
                          ],
                        ),
                      ),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columns: const [
                            DataColumn(label: Text("Nhân viên")),
                            DataColumn(label: Text("Ngày làm")),
                            DataColumn(label: Text("Ngày nghỉ")),
                            DataColumn(label: Text("Tăng ca")),
                            DataColumn(label: Text("Tổng giờ")),
                            DataColumn(label: Text("Tổng lương")),
                            DataColumn(label: Text("Chốt")),
                          ],
                          rows: employees.map((employee) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      employee['fullName'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(Text(employee['workDays'].toString())),
                                DataCell(Text(employee['leaveDays'].toString())),
                                DataCell(Text(_formatHour(employee['overtimeMinutes']))),
                                DataCell(Text(_formatHour(employee['totalMinutes']))),
                                DataCell(Text(_formatMoney(employee['totalSalary']))),
                                DataCell(
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _chotLuong(employee),
                                    child: const Text("Chốt"),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
