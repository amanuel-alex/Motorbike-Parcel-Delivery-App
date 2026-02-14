import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notifications data
    final List<Map<String, String>> notifications = [
      {
        'title': 'Delivery Accepted',
        'body': 'A rider has accepted your delivery request to Bole.',
        'time': '2 mins ago',
        'icon': 'check_circle',
      },
      {
        'title': 'Payment Verified',
        'body': 'Your payment for Order #1234 has been successfully verified.',
        'time': '1 hour ago',
        'icon': 'payments',
      },
      {
        'title': 'New Feature: Zone Pricing',
        'body': 'You can now see exact pricing for different zones in Addis!',
        'time': '2 days ago',
        'icon': 'location_on',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(item['icon']!),
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['body']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(item['time']!, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'check_circle': return Icons.check_circle_outline;
      case 'payments': return Icons.payments_outlined;
      case 'location_on': return Icons.location_on_outlined;
      default: return Icons.notifications_outlined;
    }
  }
}
