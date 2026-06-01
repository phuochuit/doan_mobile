import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'choose_request.dart';

class RequestPersonel extends StatefulWidget {
  const RequestPersonel({super.key});

  @override
  State<RequestPersonel> createState() => _RequestPersonelState();
}

class _RequestPersonelState extends State<RequestPersonel> {
  late DateTime _selectedMonth;
  int _pendingCount = 0;
  StreamSubscription<QuerySnapshot>? _countSubscription;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _subscribePendingCount();
  }

  @override
  void dispose() {
    _countSubscription?.cancel();
    super.dispose();
  }

  void _subscribePendingCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _countSubscription = FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (mounted) setState(() => _pendingCount = snapshot.docs.length);
    });
  }

  void _previousMonth() => setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
      });

  Stream<QuerySnapshot> _getStream(String status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  List<QueryDocumentSnapshot> _filterByMonth(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      if (createdAt == null) return false;
      final dt = (createdAt as Timestamp).toDate();
      return dt.year == _selectedMonth.year && dt.month == _selectedMonth.month;
    }).toList()
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aTs = aData['createdAt'] as Timestamp?;
        final bTs = bData['createdAt'] as Timestamp?;
        if (aTs == null || bTs == null) return 0;
        return bTs.compareTo(aTs);
      });
  }

  Future<void> _deleteRequest(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn có chắc chắn muốn hủy yêu cầu này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hủy yêu cầu",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('requests').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Đã hủy yêu cầu."),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Lỗi: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
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
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Chờ duyệt"),
                    ),
                    if (_pendingCount > 0)
                      Positioned(
                        top: -6,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints: const BoxConstraints(
                              minWidth: 18, minHeight: 18),
                          child: Text(
                            '$_pendingCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Tab(text: "Chấp thuận"),
              const Tab(text: "Từ chối"),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text("Tháng",
                      style: TextStyle(color: Colors.black87, fontSize: 14)),
                  const SizedBox(width: 10),
                  Container(
                      width: 1, height: 20, color: Colors.grey.shade300),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              size: 24, color: Colors.black87),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          "01 - $daysInMonth/$monthStr/$yearStr",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              size: 24, color: Colors.black87),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
                height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: TabBarView(
                children: [
                  _buildStreamTab("pending", Colors.orange, "Chờ duyệt",
                      canDelete: true),
                  _buildStreamTab("approved", Colors.green, "Chấp thuận"),
                  _buildStreamTab("rejected", Colors.red, "Từ chối"),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          shape: const CircleBorder(),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChooseRequest()),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildStreamTab(String status, Color statusColor, String statusText,
      {bool canDelete = false}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.orange));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text("Lỗi tải dữ liệu: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)));
        }

        final docs = _filterByMonth(snapshot.data?.docs ?? []);

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Không có yêu cầu nào",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildRequestCard(
              doc: doc,
              data: data,
              statusText: statusText,
              statusColor: statusColor,
              canDelete: canDelete,
            );
          },
        );
      },
    );
  }

  Widget _buildRequestCard({
    required QueryDocumentSnapshot doc,
    required Map<String, dynamic> data,
    required String statusText,
    required Color statusColor,
    bool canDelete = false,
  }) {
    final createdAt = data['createdAt'] as Timestamp?;
    final dateStr = createdAt != null
        ? DateFormat('dd/MM/yyyy').format(createdAt.toDate())
        : '';
    final details = _buildDetails(data);
    final adminNote = data['adminNote'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data['userName'] ?? 'Nhân viên',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: statusColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (canDelete) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteRequest(doc.id),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                  ),
                ],
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
                  decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['type'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = (constraints.maxWidth / 2) - 5;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: details.map((item) {
                      final isFullWidth = item['isFullWidth'] == 'true';
                      return SizedBox(
                        width:
                            isFullWidth ? constraints.maxWidth : halfWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['label']!,
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['value']!,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
            if (adminNote != null && adminNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Lý do từ chối: $adminNote",
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _buildDetails(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final List<Map<String, String>> details = [];

    String fmtTs(dynamic ts) {
      if (ts == null) return '';
      final dt = (ts as Timestamp).toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }

    String fmtDate(dynamic ts) {
      if (ts == null) return '';
      final dt = (ts as Timestamp).toDate();
      return DateFormat('dd/MM/yyyy').format(dt);
    }

    if (type == 'Quên chấm công' ||
        type == 'Làm thêm giờ' ||
        type == 'Chấm công hộ') {
      if (data['date'] != null)
        details.add({'label': 'NGÀY', 'value': data['date']});
      if (data['startTime'] != null)
        details.add({'label': 'GIỜ BẮT ĐẦU', 'value': fmtTs(data['startTime'])});
      if (data['endTime'] != null)
        details.add({'label': 'GIỜ KẾT THÚC', 'value': fmtTs(data['endTime'])});
      if (data['shiftName'] != null && data['shiftName'] != '')
        details.add({'label': 'CA LÀM', 'value': data['shiftName']});
      if (data['calculatedHours'] != null)
        details.add({'label': 'SỐ GIỜ', 'value': '${data['calculatedHours']} giờ'});
    }

    if (type == 'Nghỉ phép') {
      if (data['startTime'] != null)
        details.add({'label': 'NGÀY BẮT ĐẦU', 'value': fmtDate(data['startTime'])});
      if (data['endTime'] != null)
        details.add({'label': 'NGÀY KẾT THÚC', 'value': fmtDate(data['endTime'])});
      if (data['leaveType'] != null)
        details.add({'label': 'LOẠI NGHỈ', 'value': data['leaveType']});
    }

    if (type == 'Đi công tác') {
      if (data['startTime'] != null)
        details.add({'label': 'NGÀY ĐI', 'value': fmtDate(data['startTime'])});
      if (data['endTime'] != null)
        details.add({'label': 'NGÀY VỀ', 'value': fmtDate(data['endTime'])});
      if (data['location'] != null)
        details.add({'label': 'ĐỊA ĐIỂM', 'value': data['location']});
    }

    if (type == 'Đề xuất điều chỉnh lương') {
      if (data['currentSalary'] != null)
        details.add({'label': 'LƯƠNG HIỆN TẠI', 'value': data['currentSalary']});
      if (data['proposedSalary'] != null)
        details.add({'label': 'LƯƠNG ĐỀ XUẤT', 'value': data['proposedSalary']});
    }

    if (type == 'Đề xuất thăng tiến') {
      if (data['currentPosition'] != null)
        details.add({'label': 'VỊ TRÍ HIỆN TẠI', 'value': data['currentPosition']});
      if (data['proposedPosition'] != null)
        details.add({'label': 'VỊ TRÍ ĐỀ XUẤT', 'value': data['proposedPosition']});
    }

    if (type == 'Đề xuất điều chuyển') {
      if (data['currentPosition'] != null)
        details.add({'label': 'CHI NHÁNH HIỆN TẠI', 'value': data['currentPosition']});
      if (data['targetBranch'] != null)
        details.add({'label': 'CHI NHÁNH MUỐN CHUYỂN', 'value': data['targetBranch']});
    }

    if (type == 'Đơn thôi việc') {
      if (data['expectedLastDay'] != null)
        details.add({'label': 'NGÀY NGHỈ DỰ KIẾN', 'value': fmtDate(data['expectedLastDay'])});
    }

    if (type == 'Đề xuất tuyển dụng') {
      if (data['recruitPosition'] != null)
        details.add({'label': 'VỊ TRÍ CẦN TUYỂN', 'value': data['recruitPosition']});
      if (data['quantity'] != null)
        details.add({'label': 'SỐ LƯỢNG', 'value': '${data['quantity']}'});
      if (data['requirements'] != null && data['requirements'] != '')
        details.add({'label': 'YÊU CẦU', 'value': data['requirements'], 'isFullWidth': 'true'});
    }

    if (type == 'Đề xuất đồng phục') {
      if (data['uniformType'] != null)
        details.add({'label': 'LOẠI ĐỒNG PHỤC', 'value': data['uniformType']});
      if (data['quantity'] != null)
        details.add({'label': 'SỐ LƯỢNG', 'value': '${data['quantity']}'});
    }

    if (data['reason'] != null && data['reason'] != '')
      details.add({'label': 'LÝ DO', 'value': data['reason'], 'isFullWidth': 'true'});

    return details;
  }
}
