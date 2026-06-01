import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'tab_checkin_out.dart';
import 'tab_worksheet.dart';

class LichSuChamCongScreen extends StatefulWidget {
  const LichSuChamCongScreen({super.key});

  @override
  State<LichSuChamCongScreen> createState() => _LichSuChamCongScreenState();
}

class _LichSuChamCongScreenState extends State<LichSuChamCongScreen> {
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

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return "$h giờ $m phút";
  }

  String _formatDate(DateTime date) {
    final weekdays = ["", "T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    return "${weekdays[date.weekday]}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) return "--:--";
    final date = timestamp.toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<Map<String, dynamic>> _loadMonthData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {
        "vaoRaData": <Map<String, dynamic>>[],
        "bangCongData": null,
      };
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('checkin_logs')
        .where('userId', isEqualTo: user.uid)
        .where('month', isEqualTo: _selectedMonth.month)
        .get();

    final docs = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['year'] == _selectedMonth.year;
    }).toList();

    docs.sort((a, b) {
      final aTime = a.data()['checkInTime'];
      final bTime = b.data()['checkInTime'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.toDate().compareTo(aTime.toDate());
      }

      return 0;
    });

    final vaoRaData = docs.map((doc) {
      final data = doc.data();

      final checkInTime = data['checkInTime'];
      final checkOutTime = data['checkOutTime'];

      DateTime date = DateTime.now();
      if (checkInTime is Timestamp) {
        date = checkInTime.toDate();
      }

      final workMinutes = (data['workMinutes'] ?? 0) as int;
      final status = data['status'] == 'completed' ? 'Hoàn thành' : 'Đang làm';

      return {
        "date": _formatDate(date),
        "status": status,
        "fullName": data['fullName'] ?? 'Nhân viên',
        "records": [
          {
            "type": "out",
            "title": "Ra ca - ${data['shiftName'] ?? 'Ca làm'}",
            "time": "${data['shiftStart'] ?? '--:--'} - ${data['shiftEnd'] ?? '--:--'}",
            "actual": _formatTime(checkOutTime),
          },
          {
            "type": "in",
            "title": "Vào ca - ${data['shiftName'] ?? 'Ca làm'}",
            "time": "${data['shiftStart'] ?? '--:--'} - ${data['shiftEnd'] ?? '--:--'}",
            "actual": _formatTime(checkInTime),
          },
        ],
        "workMinutes": workMinutes,
      };
    }).toList();

    final completedDocs = docs.where((doc) {
      final data = doc.data();
      return data['status'] == 'completed';
    }).toList();

    final workDays = completedDocs.length;

    final totalWorkMinutes = completedDocs.fold<int>(0, (sum, doc) {
      final data = doc.data();
      return sum + ((data['workMinutes'] ?? 0) as int);
    });

    final overtimeMinutes = completedDocs.fold<int>(0, (sum, doc) {
      final data = doc.data();
      return sum + ((data['overtimeMinutes'] ?? 0) as int);
    });

    final standardMinutes = workDays * 240;

    final bangCongData = {
      "ngayCong": workDays.toString(),
      "gioTieuChuan": _formatDuration(standardMinutes),
      "gioThucTe": _formatDuration(totalWorkMinutes),
      "tongGioChamHo": "0 giờ 0 phút",
      "gioChamHo": "0 giờ 0 phút",
      "gioDuocThem": "0 giờ 0 phút",
      "tongGioDuyet": _formatDuration(overtimeMinutes),
      "gioQuen": "0 giờ 0 phút",
      "gioNghiBu": "0 giờ 0 phút",
      "gioNghiPhep": "0 giờ 0 phút",
      "gioCongTac": "0 giờ 0 phút",
      "gioTangCa": _formatDuration(overtimeMinutes),
      "gioLeTet": "0 giờ 0 phút",
      "gioDiLamSom": "0 giờ 0 phút",
      "gioDiLamSomMuon": "0 giờ 0 phút",
      "gioVeSomMuon": "0 giờ 0 phút",
      "tongPhutLam": totalWorkMinutes,
    };

    return {
      "vaoRaData": vaoRaData,
      "bangCongData": bangCongData,
    };
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    String monthStr = _selectedMonth.month.toString().padLeft(2, '0');
    String yearStr = _selectedMonth.year.toString();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Chấm công",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: "Vào/Ra"),
              Tab(text: "Bảng công"),
            ],
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
                  const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
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
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _loadMonthData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }

                  final data = snapshot.data ?? {
                    "vaoRaData": <Map<String, dynamic>>[],
                    "bangCongData": null,
                  };

                  final vaoRaList = data["vaoRaData"] as List<Map<String, dynamic>>;
                  final bangCongMap = data["bangCongData"] as Map<String, dynamic>?;

                  return TabBarView(
                    children: [
                      TabVaoRa(data: vaoRaList),
                      TabBangCong(data: bangCongMap),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}          bottom: const TabBar(
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: "Vào/Ra"),
              Tab(text: "Bảng công"),
            ],
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
                  const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
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
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            Expanded(
              child: TabBarView(
                children: [
                  TabVaoRa(data: vaoRaList),
                  TabBangCong(data: bangCongMap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
