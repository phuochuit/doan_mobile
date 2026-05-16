import 'package:flutter/material.dart';

class WorkSchedule extends StatefulWidget {
  const WorkSchedule({super.key});

  @override
  State<WorkSchedule> createState() => _WorkScheduleState();
}

class _WorkScheduleState extends State<WorkSchedule> {
  late DateTime _selectedMonth;

  final List<GlobalKey> _dayKeys = List.generate(32, (index) => GlobalKey());

  final Map<String, Map<int, Map<String, dynamic>>> _mockData = {
    "2026-04": {
      2: {"name": "Phục vụ theo giờ (10h - 15h)", "realTime": "09:48 - 15:20", "stdTime": "10:00 - 15:00", "location": "HCM.Q1.16NDC", "status": "Đúng giờ"},
      3: {"name": "Phục vụ theo giờ (11h - 15h)", "realTime": "10:58 - 15:16", "stdTime": "11:00 - 15:00", "location": "HCM.Q1.16NDC", "status": "Đúng giờ"},
      4: {"name": "Phục vụ theo giờ (11h - 15h)", "realTime": "10:36 - 15:28", "stdTime": "11:00 - 15:00", "location": "HCM.Q1.16NDC", "status": "Đúng giờ"},
      5: {"name": "Phục vụ theo giờ (11h - 15h)", "realTime": "10:43 - 15:42", "stdTime": "11:00 - 15:00", "location": "HCM.Q1.16NDC", "status": "Đúng giờ"},
      6: {"name": "Phục vụ theo giờ (09h - 14h)", "realTime": "08:54 - 14:21", "stdTime": "09:00 - 14:00", "location": "HCM.Q1.16NDC", "status": "Đúng giờ"},
    },
  };

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
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

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'CHỌN NGÀY LÀM VIỆC',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dayKeys[picked.day].currentContext != null) {
          Scrollable.ensureVisible(
            _dayKeys[picked.day].currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

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
    int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    String monthKey = "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}";
    Map<int, Map<String, dynamic>> shiftsInCurrentMonth = _mockData[monthKey] ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lịch làm việc",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMonthFilter(daysInMonth),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: List.generate(daysInMonth, (index) {
                  int day = index + 1;
                  DateTime currentDate = DateTime(_selectedMonth.year, _selectedMonth.month, day);

                  String dayName = _getWeekdayString(currentDate.weekday);
                  String dateStr = day.toString().padLeft(2, '0');
                  bool isSunday = currentDate.weekday == 7;

                  bool hasShift = shiftsInCurrentMonth.containsKey(day);
                  var shiftData = hasShift ? shiftsInCurrentMonth[day] : null;

                  return Container(
                    key: _dayKeys[day],
                    child: _buildScheduleItem(
                      dayName: dayName,
                      dateStr: dateStr,
                      isSunday: isSunday,
                      isOff: !hasShift,
                      shiftData: shiftData,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthFilter(int daysInMonth) {
    String monthStr = _selectedMonth.month.toString().padLeft(2, '0');
    String yearStr = _selectedMonth.year.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickDate,
            child: Row(
              children: [
                const Text("Tháng", style: TextStyle(color: Colors.black87, fontSize: 14)),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
              ],
            ),
          ),
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
                GestureDetector(
                  onTap: _pickDate,
                  child: Text(
                      "01 - $daysInMonth/$monthStr/$yearStr",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                  ),
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
    );
  }

  Widget _buildScheduleItem({
    required String dayName,
    required String dateStr,
    required bool isSunday,
    required bool isOff,
    Map<String, dynamic>? shiftData,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(dayName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                      dateStr,
                      style: TextStyle(
                          color: isSunday ? Colors.orange : Colors.orange.shade300,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )
                  ),
                ],
              ),
            ),

            Container(
              width: 3,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isOff ? Colors.lightBlue.shade200 : Colors.green.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isOff ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  if (isOff)
                    const Text(
                        "Nghỉ",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic
                        )
                    )
                  else
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shiftData!["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(shiftData["realTime"], style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(shiftData["stdTime"], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(shiftData["location"], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(shiftData["status"], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 15),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}