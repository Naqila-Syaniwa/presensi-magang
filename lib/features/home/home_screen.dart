import 'package:flutter/material.dart';
import 'package:presensimagang/features/home/widgets/announcement_section.dart';
import 'package:presensimagang/features/home/widgets/clock_card.dart';

// STUB: diganti implementasi sebenarnya

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Home'),
            SizedBox(height: 16),
            ClockCard(),
            SizedBox(height: 16),
            AnnouncementSection(),
          ],
        ),
      ),
    );
  }
}