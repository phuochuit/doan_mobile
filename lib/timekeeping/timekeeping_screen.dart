import 'package:doan_mobile/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class ChamCongScreen extends StatefulWidget {
  const ChamCongScreen({super.key});

  @override
  State<ChamCongScreen> createState() => _ChamCongScreenState();
}

class _ChamCongScreenState extends State<ChamCongScreen> {
  double? officeLat;
  double? officeLong;
  final double allowedRadius = 10.0;

  bool isLoading = false;
  bool isCheckedIn = false;
  double currentDist = double.infinity;

  final List<Map<String, String>> _logs = [];

  @override
  void initState() {
    super.initState();
    _initFakeOfficeLocation();
  }

  Future<void> _initFakeOfficeLocation() async {
    try {
      Position pos = await _determinePosition();
      setState(() {
        officeLat = pos.latitude + 0.0005;
        officeLong = pos.longitude;
      });
      _checkCurrentLocation();
    } catch (e) {
      debugPrint("Không thể lấy vị trí: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('GPS chưa bật');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Không có quyền GPS');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _checkCurrentLocation() async {
    if (officeLat == null) return;
    try {
      Position currentPos = await _determinePosition();
      setState(() {
        currentDist = Geolocator.distanceBetween(
            currentPos.latitude, currentPos.longitude, officeLat!, officeLong!);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handleCheckIn() async {
    if (officeLat == null) return;
    setState(() => isLoading = true);

    try {
      Position currentPos = await _determinePosition();
      double distance = Geolocator.distanceBetween(
          currentPos.latitude, currentPos.longitude, officeLat!, officeLong!);

      setState(() => currentDist = distance);

      if (distance <= allowedRadius) {
        setState(() {
          isCheckedIn = !isCheckedIn;
          isLoading = false;
          _logs.insert(0, {
            "time": DateFormat('HH:mm:ss').format(DateTime.now()),
            "type": isCheckedIn ? "Vào làm" : "Tan làm",
          });
        });
        _showDialog("Thành công", "Bạn đã ${isCheckedIn ? 'Vào làm' : 'Tan làm'} thành công.\nKhoảng cách: ${distance.toStringAsFixed(0)}m");
      } else {
        setState(() => isLoading = false);
        _showDialog("Thất bại", "Bạn đang ở ngoài vùng chấm công (${distance.toStringAsFixed(0)}m).\nVui lòng di chuyển lại gần văn phòng.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showDialog("Lỗi", e.toString());
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK", style: TextStyle(color: Colors.orange)))],
      ),
    );
  }

  String _getVietnameseDate() {
    final now = DateTime.now();
    final weekdays = ["", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"];
    return "${weekdays[now.weekday]}, ${now.day} tháng ${now.month} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    bool isCorrectLocation = currentDist <= allowedRadius;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            if (isCorrectLocation && officeLat != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "HCM.Q1.16NDC - ${currentDist.toInt()}m - P.48",
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 40),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildMainCircle(isCorrectLocation),
                    const SizedBox(height: 30),
                    _buildDateAndShift(),
                    const SizedBox(height: 30),
                    _buildLogs(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const UserAvatar(radius: 25,),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Xin chào", style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text("Trương Tô Đình Phước !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_none, size: 28, color: Colors.black87),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainCircle(bool isCorrectLocation) {
    Color ringColor;
    if (isCheckedIn) {
      ringColor = Colors.red.withOpacity(0.08);
    } else {
      ringColor = Colors.green.withOpacity(0.15);
    }

    return GestureDetector(
      onTap: _handleCheckIn,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ringColor,
        ),
        child: Center(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)
                ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator(color: Colors.orange)
                else ...[
                  if (isCheckedIn)
                    const Text("Bạn đang trong ca", style: TextStyle(color: Colors.grey, fontSize: 13))
                  else if (!isCorrectLocation)
                    const Text("Không có ca trong ngày", style: TextStyle(color: Colors.grey, fontSize: 13)),

                  const SizedBox(height: 8),

                  Text(
                    isCheckedIn ? "TAN LÀM" : "VÀO LÀM",
                    style: TextStyle(
                        fontSize: 28,
                        color: isCheckedIn ? Colors.redAccent : Colors.green,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (!isCorrectLocation && !isCheckedIn)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text("Sai địa điểm", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  Text(
                    isCheckedIn ? "5h 0p" : (isCorrectLocation ? "4h 0p" : "0h 0p"),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateAndShift() {
    return Column(
      children: [
        Text(
          _getVietnameseDate(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: isCheckedIn ? Colors.green.withOpacity(0.6) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isCheckedIn ? "16:00 - 21:00" : "10:00 - 14:00",
            style: TextStyle(
                color: isCheckedIn ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 13
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _logs.map((log) {
          bool isCheckInLog = log["type"] == "Vào làm";
          Color dotColor = isCheckInLog ? Colors.green : Colors.amber;
          Color bgColor = isCheckInLog ? Colors.green.shade50 : Colors.amber.shade50;
          Color textColor = isCheckInLog ? Colors.green.shade700 : Colors.amber.shade800;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: dotColor, size: 10),
                const SizedBox(width: 10),
                Text(
                  "${log["time"]} ${log["type"]}",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}