import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> methods = [
      {'name': 'Telebirr', 'status': 'Connected', 'icon': 'assets/images/telebirr.png'},
      {'name': 'CBE Birr', 'status': 'Not Connected', 'icon': 'assets/images/cbe.png'},
      {'name': 'Amole', 'status': 'Not Connected', 'icon': 'assets/images/amole.png'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Linked Wallets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ...methods.map((method) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                ),
                title: Text(method['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  method['status']!, 
                  style: TextStyle(
                    color: method['status'] == 'Connected' ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
                ),
                trailing: Switch(
                  value: method['status'] == 'Connected',
                  onChanged: (v) {},
                  activeColor: AppColors.primary,
                ),
              ),
            )).toList(),
            const SizedBox(height: 24),
            const Text(
              'Credit/Debit Cards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_card_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('No cards added yet', style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Add New Card', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
