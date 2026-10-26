import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_text_styles.dart';
import 'package:presensimagang/features/home/widgets/announcement_section.dart';
import 'package:presensimagang/features/home/widgets/home_header.dart';
import 'package:presensimagang/features/home/widgets/home_menu_grid.dart';
import 'package:presensimagang/features/home/widgets/home_skeleton.dart';
import 'package:presensimagang/features/home/widgets/promo_banner.dart';
import 'package:presensimagang/features/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            _HomeTab(),
            _PlaceholderTab(title: 'Employees'),
            _PlaceholderTab(title: 'Request'),
            _PlaceholderTab(title: 'Inbox'),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Employees',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Request'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if(_loading)
          const HomeSkeleton()
        else ...const [
          HomeHeader(),
          SizedBox(height: 16),
          HomeMenuGrid(),
        ],
        const SizedBox(height: 12),
        const PromoBanner(),
        const SizedBox(height: 12),
        const AnnouncementSection(),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: AppTextStyles.h2));
  }
}
