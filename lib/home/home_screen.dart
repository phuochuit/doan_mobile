import 'package:flutter/material.dart';
import 'home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const HomeSearchBar(),
              const HomeDateSelector(),
              const HomeBanner(),
              const SizedBox(height: 10),

              const HomeSectionTitle(title: "Thông báo", action: "Xem thêm"),
              const HomeNotificationList(),
              const SizedBox(height: 15),

              const HomeSectionTitle(title: "Tin tức", action: "Xem thêm"),
              const HomeNewsList(),
              const SizedBox(height: 20),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: const HomeIconGrid(),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}