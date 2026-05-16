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

  final Map<String, Map<String, dynamic>> _database = {
    "2026-03": {
      "vaoRaData": [
        {
          "date": "CN, 29/03",
          "status": "Đúng giờ",
          "records": [
            {"type": "out", "title": "Ra ca - Phục vụ theo giờ (17h - 21h)", "time": "17:00 - 21:00", "actual": "21:43"},
            {"type": "in", "title": "Vào ca - Phục vụ theo giờ (17h - 21h)", "time": "17:00 - 21:00", "actual": "16:06"},
          ]
        },
        {
          "date": "T7, 28/03",
          "status": "Đúng giờ",
          "records": [
            {"type": "out", "title": "Ra ca - Phục vụ theo giờ (17h30 - 21h30)", "time": "17:30 - 21:30", "actual": "21:31"},
            {"type": "in", "title": "Vào ca - Phục vụ theo giờ (17h30 - 21h30)", "time": "17:30 - 21:30", "actual": "16:44"},
          ]
        }
      ],
      "bangCongData": {
        "ngayCong": "27",
        "gioTieuChuan": "117 giờ 30 phút 0s",
        "gioThucTe": "97 giờ 18 phút 54s",
        "tongGioChamHo": "0 giờ 0 phút 0s",
        "gioChamHo": "0 giờ 0 phút 0s",
        "gioDuocThem": "0 giờ 0 phút 0s",
        "tongGioDuyet": "9 giờ 30 phút 0s",
        "gioQuen": "7 giờ 30 phút 0s",
        "gioNghiBu": "0 giờ 0 phút 0s",
        "gioNghiPhep": "0 giờ 0 phút 0s",
        "gioCongTac": "0 giờ 0 phút 0s",
        "gioTangCa": "2 giờ 0 phút 0s",
        "gioLeTet": "0 giờ 0 phút 0s",
        "gioDiLamSom": "8 giờ 26 phút 45s",
        "gioDiLamSomMuon": "1 giờ 10 phút 0s",
        "gioVeSomMuon": "0 giờ 45 phút 0s",
      }
    }
  };

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(2026, 3, 1);
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

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    String monthStr = _selectedMonth.month.toString().padLeft(2, '0');
    String yearStr = _selectedMonth.year.toString();

    String monthKey = "$yearStr-$monthStr";
    var monthData = _database[monthKey];
    List<Map<String, dynamic>> vaoRaList = monthData != null ? monthData["vaoRaData"] : [];
    Map<String, dynamic>? bangCongMap = monthData != null ? monthData["bangCongData"] : null;

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
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text("Xác nhận", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
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