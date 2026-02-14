import 'package:flutter/material.dart';
import 'admin_dashboard_summary.dart';
import 'admin_delivery_list.dart';
import 'admin_users_list.dart';
import 'admin_zones_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    AdminDashboardSummary(onTabChange: (index) => setState(() => _currentIndex = index)), // Index 0: Overview
    const AdminDeliveryListScreen(), // Index 1: Deliveries
    const AdminUsersListScreen(), // Index 2: Users
    const AdminZonesScreen(), // Index 3: Zones
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Deliveries'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Zones'),
        ],
      ),
    );
  }
}
