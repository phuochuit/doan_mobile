import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class FormYeuCauScreen extends StatefulWidget {
  final String title;

  const FormYeuCauScreen({super.key, required this.title});

  @override
  State<FormYeuCauScreen> createState() => _FormYeuCauScreenState();
}

class _FormYeuCauScreenState extends State<FormYeuCauScreen> {
  File? _selectedImage;
  File? _selectedFile;
  bool _isSubmitting = false;

  String _userName = '';
  String _userAvatar = '';
  String _userId = '';

  final _reasonController = TextEditingController();
  final _currentSalaryController = TextEditingController();
  final _proposedSalaryController = TextEditingController();
  final _currentPositionController = TextEditingController();
  final _proposedPositionController = TextEditingController();
  final _currentBranchController = TextEditingController();
  final _targetBranchController = TextEditingController();
  final _locationController = TextEditingController();
  final _recruitPositionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _uniformTypeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _expectedLastDay;

  String? _selectedShift;
  String? _selectedLeaveType;

  static const List<String> _shifts = [
    "Sáng (6h-12h)",
    "Chiều (12h-17h)",
    "Tối (17h-22h)",
    "Phục vụ theo giờ",
  ];

  static const List<String> _leaveTypes = ["Có lương", "Không lương"];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _currentSalaryController.dispose();
    _proposedSalaryController.dispose();
    _currentPositionController.dispose();
    _proposedPositionController.dispose();
    _currentBranchController.dispose();
    _targetBranchController.dispose();
    _locationController.dispose();
    _recruitPositionController.dispose();
    _quantityController.dispose();
    _requirementsController.dispose();
    _uniformTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userId = user.uid;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _userName = data['fullName'] ?? data['name'] ?? user.displayName ?? '';
        _userAvatar = data['avatarBase64'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (file.lengthSync() > 100 * 1024 * 1024) {
        _showError("Ảnh vượt quá dung lượng 100MB cho phép.");
        return;
      }
      setState(() => _selectedImage = file);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'txt', 'doc', 'docx', 'xls', 'xlsx', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (file.lengthSync() > 100 * 1024 * 1024) {
        _showError("File đính kèm vượt quá dung lượng 100MB cho phép.");
        return;
      }
      setState(() => _selectedFile = file);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<String?> _uploadToStorage(File file, String filename) async {
    final ref = FirebaseStorage.instance
        .ref('requests/$_userId/${DateTime.now().millisecondsSinceEpoch}_$filename');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      String? attachmentUrl;

      if (_selectedImage != null) {
        imageUrl = await _uploadToStorage(_selectedImage!, 'image.jpg');
      }
      if (_selectedFile != null) {
        final filename = _selectedFile!.path.split('/').last;
        attachmentUrl = await _uploadToStorage(_selectedFile!, filename);
      }

      final Map<String, dynamic> data = {
        'type': widget.title,
        'userId': _userId,
        'userName': _userName,
        'userAvatar': _userAvatar,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'reason': _reasonController.text.trim(),
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      };

      _addTypeSpecificFields(data);

      await FirebaseFirestore.instance.collection('requests').add(data);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text("Thành công", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text("Yêu cầu của bạn đã được gửi thành công!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("ĐÓNG",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError("Gửi yêu cầu thất bại: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _addTypeSpecificFields(Map<String, dynamic> data) {
    final type = widget.title;

    if (type == 'Quên chấm công' || type == 'Làm thêm giờ' || type == 'Chấm công hộ') {
      if (_selectedDate != null) {
        data['date'] = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      }
      if (_startTime != null && _selectedDate != null) {
        final dt = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
            _startTime!.hour, _startTime!.minute);
        data['startTime'] = Timestamp.fromDate(dt);
      }
      if (_endTime != null && _selectedDate != null) {
        final dt = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
            _endTime!.hour, _endTime!.minute);
        data['endTime'] = Timestamp.fromDate(dt);
      }
      if (_startTime != null && _endTime != null) {
        final mins = _endTime!.hour * 60 + _endTime!.minute -
            _startTime!.hour * 60 - _startTime!.minute;
        data['calculatedHours'] = double.parse((mins / 60).toStringAsFixed(2));
      }
      data['shiftName'] = _selectedShift ?? '';
    }

    if (type == 'Nghỉ phép') {
      if (_startDate != null) data['startTime'] = Timestamp.fromDate(_startDate!);
      if (_endDate != null) data['endTime'] = Timestamp.fromDate(_endDate!);
      data['leaveType'] = _selectedLeaveType ?? '';
    }

    if (type == 'Đi công tác') {
      if (_startDate != null) data['startTime'] = Timestamp.fromDate(_startDate!);
      if (_endDate != null) data['endTime'] = Timestamp.fromDate(_endDate!);
      data['location'] = _locationController.text.trim();
    }

    if (type == 'Đề xuất điều chỉnh lương') {
      data['currentSalary'] = _currentSalaryController.text.trim();
      data['proposedSalary'] = _proposedSalaryController.text.trim();
    }

    if (type == 'Đề xuất thăng tiến') {
      data['currentPosition'] = _currentPositionController.text.trim();
      data['proposedPosition'] = _proposedPositionController.text.trim();
    }

    if (type == 'Đề xuất điều chuyển') {
      data['currentPosition'] = _currentBranchController.text.trim();
      data['targetBranch'] = _targetBranchController.text.trim();
    }

    if (type == 'Đơn thôi việc') {
      if (_expectedLastDay != null) {
        data['expectedLastDay'] = Timestamp.fromDate(_expectedLastDay!);
      }
    }

    if (type == 'Đề xuất tuyển dụng') {
      data['recruitPosition'] = _recruitPositionController.text.trim();
      data['quantity'] = int.tryParse(_quantityController.text.trim()) ?? 0;
      data['requirements'] = _requirementsController.text.trim();
    }

    if (type == 'Đề xuất đồng phục') {
      data['uniformType'] = _uniformTypeController.text.trim();
      data['quantity'] = int.tryParse(_quantityController.text.trim()) ?? 0;
    }
  }

  bool _validate() {
    if (_reasonController.text.trim().isEmpty) {
      _showError("Vui lòng nhập lý do.");
      return false;
    }

    final type = widget.title;

    if (type == 'Quên chấm công' || type == 'Làm thêm giờ' || type == 'Chấm công hộ') {
      if (_selectedDate == null) { _showError("Vui lòng chọn ngày."); return false; }
      if (_startTime == null) { _showError("Vui lòng chọn giờ bắt đầu."); return false; }
      if (_endTime == null) { _showError("Vui lòng chọn giờ kết thúc."); return false; }
    }

    if (type == 'Nghỉ phép') {
      if (_startDate == null) { _showError("Vui lòng chọn ngày bắt đầu."); return false; }
      if (_endDate == null) { _showError("Vui lòng chọn ngày kết thúc."); return false; }
      if (_selectedLeaveType == null) { _showError("Vui lòng chọn loại nghỉ."); return false; }
    }

    if (type == 'Đi công tác') {
      if (_startDate == null) { _showError("Vui lòng chọn ngày đi."); return false; }
      if (_endDate == null) { _showError("Vui lòng chọn ngày về."); return false; }
      if (_locationController.text.trim().isEmpty) {
        _showError("Vui lòng nhập địa điểm.");
        return false;
      }
    }

    if (type == 'Đề xuất điều chỉnh lương') {
      if (_currentSalaryController.text.trim().isEmpty) {
        _showError("Vui lòng nhập mức lương hiện tại.");
        return false;
      }
      if (_proposedSalaryController.text.trim().isEmpty) {
        _showError("Vui lòng nhập mức lương đề xuất.");
        return false;
      }
    }

    if (type == 'Đề xuất thăng tiến') {
      if (_currentPositionController.text.trim().isEmpty) {
        _showError("Vui lòng nhập vị trí hiện tại.");
        return false;
      }
      if (_proposedPositionController.text.trim().isEmpty) {
        _showError("Vui lòng nhập vị trí đề xuất.");
        return false;
      }
    }

    if (type == 'Đề xuất điều chuyển') {
      if (_currentBranchController.text.trim().isEmpty) {
        _showError("Vui lòng nhập chi nhánh hiện tại.");
        return false;
      }
      if (_targetBranchController.text.trim().isEmpty) {
        _showError("Vui lòng nhập chi nhánh muốn chuyển.");
        return false;
      }
    }

    if (type == 'Đơn thôi việc') {
      if (_expectedLastDay == null) {
        _showError("Vui lòng chọn ngày nghỉ dự kiến.");
        return false;
      }
    }

    if (type == 'Đề xuất tuyển dụng') {
      if (_recruitPositionController.text.trim().isEmpty) {
        _showError("Vui lòng nhập vị trí cần tuyển.");
        return false;
      }
      if (_quantityController.text.trim().isEmpty) {
        _showError("Vui lòng nhập số lượng.");
        return false;
      }
    }

    if (type == 'Đề xuất đồng phục') {
      if (_uniformTypeController.text.trim().isEmpty) {
        _showError("Vui lòng nhập loại đồng phục.");
        return false;
      }
    }

    return true;
  }

  Future<void> _selectDate(BuildContext context,
      {required Function(DateTime) onSelected}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _selectTime(BuildContext context,
      {required Function(TimeOfDay) onSelected}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.orange),
        ),
        child: child!,
      ),
    );
    if (picked != null) onSelected(picked);
  }

  String _fmt(DateTime? d) =>
      d != null ? DateFormat('dd/MM/yyyy').format(d) : '';
  String _fmtTime(TimeOfDay? t) =>
      t != null ? t.format(context) : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaticField(
                        Icons.people_outline,
                        _userName.isNotEmpty ? _userName : "Đang tải..."),
                    const SizedBox(height: 12),
                    ..._buildTypeSpecificFields(),
                    const SizedBox(height: 12),
                    _buildReasonField(),
                    const SizedBox(height: 20),
                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    _buildFilePicker(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeSpecificFields() {
    final type = widget.title;

    if (type == 'Quên chấm công' ||
        type == 'Làm thêm giờ' ||
        type == 'Chấm công hộ') {
      return [
        _buildTapField(Icons.calendar_today_outlined, "Ngày", _fmt(_selectedDate),
            onTap: () => _selectDate(context,
                onSelected: (d) => setState(() => _selectedDate = d))),
        const SizedBox(height: 12),
        _buildTapField(Icons.access_time, "Giờ bắt đầu", _fmtTime(_startTime),
            onTap: () => _selectTime(context,
                onSelected: (t) => setState(() => _startTime = t))),
        const SizedBox(height: 12),
        _buildTapField(Icons.access_time_filled, "Giờ kết thúc", _fmtTime(_endTime),
            onTap: () => _selectTime(context,
                onSelected: (t) => setState(() => _endTime = t))),
        const SizedBox(height: 12),
        _buildDropdown(Icons.timelapse, "Chọn ca làm", _shifts, _selectedShift,
            onChanged: (v) => setState(() => _selectedShift = v)),
      ];
    }

    if (type == 'Nghỉ phép') {
      return [
        _buildTapField(Icons.calendar_today_outlined, "Ngày bắt đầu", _fmt(_startDate),
            onTap: () => _selectDate(context,
                onSelected: (d) => setState(() => _startDate = d))),
        const SizedBox(height: 12),
        _buildTapField(Icons.calendar_today_outlined, "Ngày kết thúc", _fmt(_endDate),
            onTap: () => _selectDate(context,
                onSelected: (d) => setState(() => _endDate = d))),
        const SizedBox(height: 12),
        _buildDropdown(Icons.category_outlined, "Loại nghỉ", _leaveTypes,
            _selectedLeaveType,
            onChanged: (v) => setState(() => _selectedLeaveType = v)),
      ];
    }

    if (type == 'Đi công tác') {
      return [
        _buildTapField(Icons.flight_takeoff, "Ngày đi", _fmt(_startDate),
            onTap: () => _selectDate(context,
                onSelected: (d) => setState(() => _startDate = d))),
        const SizedBox(height: 12),
        _buildTapField(Icons.flight_land, "Ngày về", _fmt(_endDate),
            onTap: () => _selectDate(context,
                onSelected: (d) => setState(() => _endDate = d))),
        const SizedBox(height: 12),
        _buildTextField(Icons.location_on_outlined, "Địa điểm",
            _locationController),
      ];
    }

    if (type == 'Đề xuất điều chỉnh lương') {
      return [
        _buildTextField(Icons.attach_money, "Mức lương hiện tại",
            _currentSalaryController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _buildTextField(Icons.monetization_on_outlined, "Mức lương đề xuất",
            _proposedSalaryController,
            keyboardType: TextInputType.number),
      ];
    }

    if (type == 'Đề xuất thăng tiến') {
      return [
        _buildTextField(
            Icons.work_outline, "Vị trí hiện tại", _currentPositionController),
        const SizedBox(height: 12),
        _buildTextField(Icons.trending_up, "Vị trí đề xuất",
            _proposedPositionController),
      ];
    }

    if (type == 'Đề xuất điều chuyển') {
      return [
        _buildTextField(Icons.store_outlined, "Chi nhánh hiện tại",
            _currentBranchController),
        const SizedBox(height: 12),
        _buildTextField(Icons.swap_horiz, "Chi nhánh muốn chuyển",
            _targetBranchController),
      ];
    }

    if (type == 'Đơn thôi việc') {
      return [
        _buildTapField(Icons.event_busy, "Ngày nghỉ dự kiến",
            _fmt(_expectedLastDay),
            onTap: () => _selectDate(context,
                onSelected: (d) => setState(() => _expectedLastDay = d))),
      ];
    }

    if (type == 'Đề xuất tuyển dụng') {
      return [
        _buildTextField(Icons.person_add_alt_1_outlined, "Vị trí cần tuyển",
            _recruitPositionController),
        const SizedBox(height: 12),
        _buildTextField(Icons.format_list_numbered, "Số lượng",
            _quantityController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _buildTextField(Icons.list_alt_outlined, "Yêu cầu",
            _requirementsController,
            maxLines: 3),
      ];
    }

    if (type == 'Đề xuất đồng phục') {
      return [
        _buildTextField(
            Icons.checkroom, "Loại đồng phục", _uniformTypeController),
        const SizedBox(height: 12),
        _buildTextField(Icons.format_list_numbered, "Số lượng",
            _quantityController,
            keyboardType: TextInputType.number),
      ];
    }

    return [];
  }

  Widget _buildStaticField(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapField(IconData icon, String label, String value,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            const Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value.isEmpty ? label : value,
                style: TextStyle(
                  color: value.isEmpty ? Colors.grey.shade600 : Colors.black87,
                  fontSize: 14,
                  fontWeight:
                      value.isEmpty ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(IconData icon, String label, List<String> items,
      String? value,
      {required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14)),
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 14))))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label,
      TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 8),
          const Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Icon(Icons.chat_bubble_outline,
                color: Colors.grey.shade400, size: 20),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child:
                Text("*", style: TextStyle(color: Colors.red, fontSize: 16)),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Nhập vào lý do",
                hintStyle:
                    TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              image: _selectedImage != null
                  ? DecorationImage(
                      image: FileImage(_selectedImage!), fit: BoxFit.cover)
                  : null,
            ),
            child: _selectedImage == null
                ? const Center(
                    child: Icon(Icons.camera_alt_outlined,
                        color: Colors.orange, size: 30))
                : null,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ảnh mô tả",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87)),
              SizedBox(height: 4),
              Text(
                  "Bấm vào ô bên trái để chọn ảnh từ thư viện. Tối đa 100MB.",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFilePicker() {
    return Center(
      child: _selectedFile == null
          ? TextButton.icon(
              onPressed: _pickFile,
              icon: const Text("File đính kèm",
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
              label: const Icon(Icons.add, color: Colors.orange, size: 18),
            )
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _selectedFile!.path.split('/').last,
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFile = null),
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text("GỬI YÊU CẦU",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
        ),
      ),
    );
  }
}
