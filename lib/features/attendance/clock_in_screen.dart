import 'package:flutter/material.dart';

class ClockInScreen extends StatelessWidget {
  const ClockInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Attendance')),
      body: const Center(child: Text('Halaman Clock In (dalam pengerjaan)')),
    );
  }
}
