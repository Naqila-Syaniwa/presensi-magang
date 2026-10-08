import 'package:flutter/material.dart';
import 'package:presensimagang/features/home/widgets/announcement_section.dart';
import 'package:presensimagang/features/home/widgets/promo_banner.dart';
// import 'package:presensimagang/features/home/widgets/clock_card.dart';

/// Home sementara: baru berisi bagian milik Dev B (banner + pengumuman).
/// TODO Dev A: header sapaan, grid menu, dan bottom navigation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            // TODO Dev A: header "Good afternoon" + grid menu (8 item) di sini.
            // ClockCard(),   // aktifkan bila dipakai
            PromoBanner(),
            SizedBox(height: 16),
            // Empty state seperti referensi; hapus parameter untuk data dummy.
            AnnouncementSection(announcements: []),
          ],
        ),
      ),
    );
  }
}