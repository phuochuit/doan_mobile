import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChiTietNhanVienScreen extends StatefulWidget {
  const ChiTietNhanVienScreen({super.key});

  @override
  State<ChiTietNhanVienScreen> createState() => _ChiTietNhanVienScreenState();
}

class _ChiTietNhanVienScreenState extends State<ChiTietNhanVienScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _empCodeController = TextEditingController();

  String? _selectedGender;
  String? _selectedBranch;
  String? _selectedDepartment;
  String? _selectedRole;

  bool _isLoading = true;
  bool isAdmin = false; 

  final List<String> _genders = ["Nam", "Nữ", "Khác"];
  final List<String> _branches = ["HCM.Q1.16NDC", "HUIT_Tantay"];
  final List<String> _departments = ["Vận hành", "Nhà bếp", "Phục vụ", "Kế toán"];
  final List<String> _roles = ["Nhân viên", "Quản lý"];

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _empCodeController.text = data['employeeCode'] ?? '';

          _selectedGender = data['gender'];
          _selectedBranch = data['branchId'];
          _selectedDepartment = data['department'];

          _selectedRole = data['role'] == 'admin' ? 'Quản lý' : 'Nhân viên';

          isAdmin = data['role'] == 'admin';

          _isLoading = false;
        });
      }
    }
  }

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
        title: const Text("Chi tiết nhân viên",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Họ tên", _nameController),
            _buildTextField("Email", _emailController),
            _buildTextField("Số điện thoại", _phoneController),
            _buildTextField("Mã nhân viên", _empCodeController),

            _buildDropdownField("Giới tính", _selectedGender, _genders, (val) => setState(() => _selectedGender = val)),
            _buildDropdownField("Chi nhánh", _selectedBranch, _branches, (val) => setState(() => _selectedBranch = val)),
            _buildDropdownField("Phòng ban", _selectedDepartment, _departments, (val) => setState(() => _selectedDepartment = val)),
            _buildDropdownField("Phân quyền", _selectedRole, _roles, (val) => setState(() => _selectedRole = val)),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdmin ? Colors.orange : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: isAdmin ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tính năng lưu đang phát triển!")),
                  );
                }
                    : null,
                child: Text("LƯU",
                    style: TextStyle(color: isAdmin ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),

            if (!isAdmin)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text("(*) Chỉ Admin mới được quyền thay đổi thông tin",
                    style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            readOnly: !isAdmin,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              suffixIcon: isAdmin ? const Icon(Icons.edit, size: 18, color: Colors.grey) : null,
              filled: !isAdmin,
              fillColor: !isAdmin ? Colors.grey.shade100 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null, 
            onChanged: isAdmin ? onChanged : null,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              filled: !isAdmin,
              fillColor: !isAdmin ? Colors.grey.shade100 : Colors.white,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}