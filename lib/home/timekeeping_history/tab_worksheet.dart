import 'package:flutter/material.dart';

class TabBangCong extends StatelessWidget {
  final Map<String, dynamic>? data;

  const TabBangCong({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final d = data ?? {
      "ngayCong": "0",
      "gioTieuChuan": "0 giờ 0 phút 0s",
      "gioThucTe": "0 giờ 0 phút 0s",
      "tongGioChamHo": "0 giờ 0 phút 0s",
      "gioChamHo": "0 giờ 0 phút 0s",
      "gioDuocThem": "0 giờ 0 phút 0s",
      "tongGioDuyet": "0 giờ 0 phút 0s",
      "gioQuen": "0 giờ 0 phút 0s",
      "gioNghiBu": "0 giờ 0 phút 0s",
      "gioNghiPhep": "0 giờ 0 phút 0s",
      "gioCongTac": "0 giờ 0 phút 0s",
      "gioTangCa": "0 giờ 0 phút 0s",
      "gioLeTet": "0 giờ 0 phút 0s",
      "gioDiLamSom": "0 giờ 0 phút 0s",
      "gioDiLamSomMuon": "0 giờ 0 phút 0s",
      "gioVeSomMuon": "0 giờ 0 phút 0s",
    };

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        _buildStatRow("Ngày công thực tế", d["ngayCong"]),
        _buildStatRow("Giờ công tiêu chuẩn", d["gioTieuChuan"]),
        _buildStatRow("Giờ công thực tế", d["gioThucTe"], hasArrow: true),

        _buildStatRow("Giờ công chấm hộ/thêm:", d["tongGioChamHo"], hasArrow: true),
        _buildSubItemRow("Giờ công chấm hộ", d["gioChamHo"]),
        _buildSubItemRow("Giờ công được thêm", d["gioDuocThem"]),

        _buildStatRow("Giờ công được duyệt:", d["tongGioDuyet"], hasArrow: true),
        _buildSubItemRow("Giờ công quên chấm công", d["gioQuen"]),
        _buildSubItemRow("Giờ công nghỉ bù", d["gioNghiBu"]),
        _buildSubItemRow("Giờ công nghỉ phép", d["gioNghiPhep"]),
        _buildSubItemRow("Giờ công công tác", d["gioCongTac"]),
        _buildSubItemRow("Giờ công tăng ca/thêm giờ", d["gioTangCa"]),

        _buildStatRow("Giờ công lễ tết", d["gioLeTet"]),
        _buildStatRow("Số giờ đi làm sớm", d["gioDiLamSom"]),

        _buildStatRow("Số giờ đi làm sớm/muộn", d["gioDiLamSomMuon"]),
        _buildStatRow("Số giờ về sớm/muộn", d["gioVeSomMuon"]),
      ],
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
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
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
              Row(
                children: [
                  const Text("• ", style: TextStyle(fontSize: 18, color: Colors.black87)),
                  Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}