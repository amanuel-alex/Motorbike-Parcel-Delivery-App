import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final AuthService _authService = AuthService();

  final List<Map<String, String>> availableMethods = [
    {'name': 'Telebirr', 'icon': 'account_balance_wallet_outlined'},
    {'name': 'CBE Birr', 'icon': 'account_balance_wallet_outlined'},
    {'name': 'Amole', 'icon': 'account_balance_wallet_outlined'},
  ];

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context).user?.uid ?? 'demo_guest_id';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<List<String>>(
        stream: _authService.getLinkedPaymentMethods(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final linkedMethods = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Linked Wallets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ...availableMethods.map((method) {
                  final bool isConnected = linkedMethods.contains(method['name']);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isConnected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined, 
                          color: isConnected ? AppColors.primary : Colors.grey
                        ),
                      ),
                      title: Text(method['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        isConnected ? 'Connected' : 'Not Connected', 
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )
                      ),
                      trailing: Switch(
                        value: isConnected,
                        onChanged: (v) async {
                          final newList = List<String>.from(linkedMethods);
                          if (v) {
                            newList.add(method['name']!);
                          } else {
                            newList.remove(method['name']);
                          }
                          await _authService.updateLinkedPaymentMethods(uid, newList);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Card payments coming soon in next release!'))
                          );
                        },
                        child: const Text('Add New Card', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
