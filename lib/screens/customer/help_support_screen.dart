import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            _buildContactCard(
              Icons.chat_outlined,
              'Live Chat',
              'Chat with our support team',
              () {},
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              Icons.phone_outlined,
              'Phone Support',
              '+251 911 000 000',
              () {},
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              Icons.email_outlined,
              'Email Support',
              'support@zippandgo.com',
              () {},
            ),
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildFaqItem('How do I track my order?', 'You can track your order in real-time from the "Activity" tab.'),
            _buildFaqItem('What are the delivery hours?', 'We operate 24/7 across all major zones in Addis Ababa.'),
            _buildFaqItem('How is pricing calculated?', 'Pricing is based on the distance between pickup and dropoff zones.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(answer, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
