import 'package:flutter/material.dart';

class TabVaoRa extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TabVaoRa({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          "Không có dữ liệu",
          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final dayData = data[index];
        final records = dayData["records"] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dayData["date"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(dayData["status"], style: TextStyle(color: Colors.green.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...records.map((record) {
              bool isOut = record["type"] == "out";
              Color mainColor = isOut ? Colors.red.shade400 : Colors.green.shade400;
              Color iconBgColor = Colors.lightBlue.shade100;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
                      child: Icon(isOut ? Icons.logout : Icons.login, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Trương Tô Đình Phước", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(record["title"], style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(record["time"], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: mainColor, borderRadius: BorderRadius.circular(6)),
                      child: Text(record["actual"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    )
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 20, thickness: 1, color: Color(0xFFEEEEEE)),
          ],
        );
      },
    );
  }
}