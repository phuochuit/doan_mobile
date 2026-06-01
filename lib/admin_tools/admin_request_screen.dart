import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminRequestScreen extends StatefulWidget {
  const AdminRequestScreen({super.key});

  @override
  State<AdminRequestScreen> createState() => _AdminRequestScreenState();
}

class _AdminRequestScreenState extends State<AdminRequestScreen> {
  late DateTime _selectedMonth;
  String? _filterType;

  static const List<String> _allTypes = [
    "Quên chấm công",
    "Làm thêm giờ",
    "Nghỉ phép",
    "Chấm công hộ",
    "Đi công tác",
    "Đề xuất điều chỉnh lương",
    "Đề xuất thăng tiến",
    "Đề xuất điều chuyển",
    "Đơn thôi việc",
    "Đề xuất tuyển dụng",
    "Đề xuất đồng phục",
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
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
    return FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      if (createdAt == null) return false;
      final dt = (createdAt as Timestamp).toDate();
      final matchesMonth =
          dt.year == _selectedMonth.year && dt.month == _selectedMonth.month;
      final matchesType =
          _filterType == null || data['type'] == _filterType;
      return matchesMonth && matchesType;
    }).toList()
      ..sort((a, b) {
        final aTs = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
        final bTs = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
        if (aTs == null || bTs == null) return 0;
        return bTs.compareTo(aTs);
      });
  }

  Future<void> _approveRequest(DocumentSnapshot doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text("Xác nhận duyệt", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Bạn có chắc chắn muốn chấp thuận yêu cầu này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Duyệt",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final data = doc.data() as Map<String, dynamic>;
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'] as String);

      batch.update(doc.reference, {
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final type = data['type'] as String? ?? '';

      if (type == 'Quên chấm công') {
        final hours = (data['calculatedHours'] as num?)?.toDouble() ?? 0;
        batch.update(userRef, {'forgotHours': FieldValue.increment(hours)});
      } else if (type == 'Làm thêm giờ') {
        final hours = (data['calculatedHours'] as num?)?.toDouble() ?? 0;
        batch.update(userRef, {'overtimeHours': FieldValue.increment(hours)});
      } else if (type == 'Chấm công hộ') {
        final hours = (data['calculatedHours'] as num?)?.toDouble() ?? 0;
        batch.update(userRef, {'proxyHours': FieldValue.increment(hours)});
      } else if (type == 'Đơn thôi việc') {
        batch.update(userRef, {
          'isActive': false,
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Đã chấp thuận yêu cầu."),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectRequest(DocumentSnapshot doc) async {
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text("Từ chối yêu cầu",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Vui lòng nhập lý do từ chối:"),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Nhập lý do...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (noteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text("Vui lòng nhập lý do từ chối."),
                      backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text("Từ chối",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await doc.reference.update({
        'status': 'rejected',
        'adminNote': noteController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Đã từ chối yêu cầu."),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }

    noteController.dispose();
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
            "Quản lý đơn từ",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            PopupMenuButton<String?>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              tooltip: "Lọc loại phiếu",
              onSelected: (value) => setState(() => _filterType = value),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: null, child: Text("Tất cả loại phiếu")),
                ..._allTypes.map((t) => PopupMenuItem(value: t, child: Text(t))),
              ],
            ),
          ],
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Tháng",
                          style:
                              TextStyle(color: Colors.black87, fontSize: 14)),
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
                  if (_filterType != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_filterType!,
                                    style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _filterType = null),
                                  child: const Icon(Icons.close,
                                      color: Colors.orange, size: 14),
                                ),
                              ],
                            ),
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
                      showActions: true),
                  _buildStreamTab("approved", Colors.green, "Chấp thuận"),
                  _buildStreamTab("rejected", Colors.red, "Từ chối"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamTab(String status, Color statusColor, String statusText,
      {bool showActions = false}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getStream(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.orange));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text("Lỗi: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)));
        }

        final docs = _filterDocs(snapshot.data?.docs ?? []);

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
            return _buildAdminCard(
              doc: doc,
              data: data,
              statusText: statusText,
              statusColor: statusColor,
              showActions: showActions,
            );
          },
        );
      },
    );
  }

  Widget _buildAdminCard({
    required QueryDocumentSnapshot doc,
    required Map<String, dynamic> data,
    required String statusText,
    required Color statusColor,
    bool showActions = false,
  }) {
    final createdAt = data['createdAt'] as Timestamp?;
    final dateStr = createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate())
        : '';
    final details = _buildDetails(data);
    final adminNote = data['adminNote'] as String?;
    final imageUrl = data['imageUrl'] as String?;
    final attachmentUrl = data['attachmentUrl'] as String?;

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
                  radius: 18,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? 'Nhân viên',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
                        width: isFullWidth ? constraints.maxWidth : halfWidth,
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
            if (imageUrl != null || attachmentUrl != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (imageUrl != null)
                    GestureDetector(
                      onTap: () => _showImageDialog(imageUrl),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  if (attachmentUrl != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.insert_drive_file,
                                color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text("File đính kèm",
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
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
                    const Icon(Icons.info_outline, color: Colors.red, size: 16),
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
            if (showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _rejectRequest(doc),
                      child: const Text("TỪ CHỐI",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () => _approveRequest(doc),
                      child: const Text("DUYỆT",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
              title: const Text("Ảnh đính kèm",
                  style: TextStyle(color: Colors.white)),
            ),
            Image.network(imageUrl, fit: BoxFit.contain),
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
      return DateFormat('dd/MM/yyyy HH:mm').format((ts as Timestamp).toDate());
    }

    String fmtDate(dynamic ts) {
      if (ts == null) return '';
      return DateFormat('dd/MM/yyyy').format((ts as Timestamp).toDate());
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
        details.add({
          'label': 'SỐ GIỜ',
          'value': '${data['calculatedHours']} giờ'
        });
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
