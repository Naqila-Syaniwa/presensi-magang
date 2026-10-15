import 'package:flutter/material.dart';

class HomeMenuItem {
  const HomeMenuItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

const List<HomeMenuItem> homeMenuItems = [
  HomeMenuItem(
    label: 'Reimbursemenet',
    icon: Icons.receipt_long_outlined,
    color: Color(0xFF2EB5B8),
  ),
  HomeMenuItem(
    label: 'Time Off',
    icon: Icons.access_time_filled,
    color: Color(0xFF6F86EE),
  ),
  HomeMenuItem(
    label: 'Live Attendance',
    icon: Icons.location_on,
    color: Color(0xFFDB4F9F),
  ),
  HomeMenuItem(label: 'Overtime', icon: Icons.alarm, color: Color(0xFFD353B6)),
  HomeMenuItem(
    label: 'Mekari Flex',
    icon: Icons.add_rounded,
    color: Color(0xFF794BFE),
  ),
  HomeMenuItem(
    label: 'Attendance Log',
    icon: Icons.fact_check_outlined,
    color: Color(0xFFEE8F71),
  ),
  HomeMenuItem(
    label: 'Payslip',
    icon: Icons.payment_outlined,
    color: Color(0xFF3B86E5),
  ),
  
  HomeMenuItem(
    label: 'All Apps',
    icon: Icons.apps_rounded,
    color: Color(0xFF8E99AA),
  ),
];
