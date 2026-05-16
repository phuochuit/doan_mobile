import 'package:flutter/material.dart';
import 'choose_request.dart';

class RequestPersonel extends StatefulWidget {
  const RequestPersonel({super.key});

  @override
  State<RequestPersonel> createState() => _RequestPersonelState();
}

class _RequestPersonelState extends State<RequestPersonel> {
  late DateTime _selectedMonth;

  final Map<String, Map<String, List<Map<String, dynamic>>>> _mockRequests = {
    "2026-03": {
      "pending": [
        {
          "title": "Đi công tác",
          "date": "T4, 25/03",
          "details": [
            {"label": "NGÀY BẮT ĐẦU", "value": "25-03-2026 17:00"},
            {"label": "NGÀY KẾT THÚC", "value": "25-03-2026 21:00"},
            {"label": "CA", "value": "Phục vụ theo giờ (17h - 21h)"},
            {"label": "ĐỊA ĐIỂM", "value": "HCM.Q10.HADO"},
          ]
        }
      ],
      "approved": [
        {
          "title": "Quên chấm công",
          "date": "CN, 22/03",
          "details": [
            {"label": "GIỜ BẮT ĐẦU", "value": "17-03-2026 18:00"},
            {"label": "GIỜ KẾT THÚC", "value": "17-03-2026 21:30"},
            {"label": "CA", "value": "Phục vụ theo giờ 18h00-21h30"},
            {
              "label": "LÝ DO",
              "value": "Kính gửi anh/chị ngày 17/03, em có ca làm từ 18h-21h30, em quên chấm công vì không mang theo điện thoại. Nhờ anh/chị hỗ trợ duyệt phiếu giúp em.",
              "isFullWidth": true
            },
          ]
        },
        {
          "title": "Làm thêm giờ",
          "date": "CN, 08/03",
          "details": [
            {"label": "NGÀY", "value": "07-03-2026"},
            {"label": "THỜI GIAN", "value": "09:00 - 11:00"},
            {"label": "LOẠI", "value": "Làm thêm giờ"},
            {
              "label": "LÝ DO",
              "value": "Ngày 07/03, vì có đơn hàng gói món lớn nên em lên sớm tăng ca hỗ trợ từ 9h-11h. Nhờ anh/chị hỗ trợ duyệt phiếu giúp em. Em cảm ơn ạ.",
              "isFullWidth": true
            },
          ]
        }
      ],
      "rejected": []
    },
    "2026-02": {
      "pending": [],
      "approved": [],
      "rejected": [
        {
          "title": "Làm thêm giờ",
          "date": "T7, 14/02",
          "details": [
            {"label": "NGÀY", "value": "14-02-2026"},
            {"label": "THỜI GIAN", "value": "15:00 - 16:00"},
            {
              "label": "LÝ DO",
              "value": "Kính gửi anh/chị, ngày 14/02 vì lý do tổng dọn vệ sinh nhà hàng nên em đã làm thêm giờ từ 15h-16h. Nhờ anh/chị hỗ trợ duyệt phiếu giúp em.",
              "isFullWidth": true
            },
          ]
        },
        {
          "title": "Phiếu chấm công hộ",
          "date": "T6, 13/02",
          "details": [
            {"label": "GIỜ BẮT ĐẦU", "value": "12-02-2026 10:00"},
            {"label": "GIỜ KẾT THÚC", "value": "12-02-2026 15:00"},
            {"label": "CÁC NGÀY CHẤM HỘ", "value": "12-02-2026"},
            {
              "label": "LÝ DO",
              "value": "Kính gửi anh/chị, Ngày 12/02 em có ca làm từ 10h-15h. Vì lý do app lỗi nên không đăng nhập và chấm công được. Nhờ anh/chị hỗ trợ duyệt phiếu giúp em.",
              "isFullWidth": true
            },
          ]
        }
      ]
    }
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

  @override
  Widget build(BuildContext context) {
    int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    String monthStr = _selectedMonth.month.toString().padLeft(2, '0');
    String yearStr = _selectedMonth.year.toString();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Yêu cầu của tôi",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: "Chờ duyệt"),
              Tab(text: "Chấp thuận"),
              Tab(text: "Từ chối"),
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
                  _buildTabContent("pending", Colors.orange, "Chờ duyệt"),
                  _buildTabContent("approved", Colors.green, "Đồng ý"),
                  _buildTabContent("rejected", Colors.red, "Từ chối"),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChooseRequest()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildTabContent(String statusKey, Color statusColor, String statusText) {
    String currentMonthKey = "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}";

    var monthData = _mockRequests[currentMonthKey];
    List<dynamic> requests = (monthData != null && monthData[statusKey] != null)
        ? monthData[statusKey]!
        : [];

    if (requests.isEmpty) {
      return const Center(
        child: Text(
          "Không có yêu cầu nào",
          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        var req = requests[index];
        return _buildRequestCard(
          statusText: statusText,
          statusColor: statusColor,
          title: req["title"],
          date: req["date"],
          details: req["details"],
        );
      },
    );
  }

  Widget _buildRequestCard({
    required String statusText,
    required Color statusColor,
    required String title,
    required String date,
    required List<dynamic> details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('https://avatar.talk.zdn.vn/default.jpg'),
                ),
                const SizedBox(width: 10),
                const Text("Trương Tô Đình Phước", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: statusColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                double halfWidth = (constraints.maxWidth / 2) - 5;
                return Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: details.map((item) {
                    bool isFullWidth = item['isFullWidth'] == true;
                    return SizedBox(
                      width: isFullWidth ? constraints.maxWidth : halfWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'],
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['value'],
                            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}