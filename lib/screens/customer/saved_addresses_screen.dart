import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  // Sample data
  final List<Map<String, String>> _addresses = [
    {
      'label': 'Home',
      'address': 'Bole, Near Edna Mall, Addis Ababa',
      'icon': 'home',
    },
    {
      'label': 'Office',
      'address': 'Kazanchis, UNECA Compound, Addis Ababa',
      'icon': 'work',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Saved Addresses', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final item = _addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] == 'home' ? Icons.home_outlined : Icons.work_outline,
                  color: AppColors.primary,
                ),
              ),
              title: Text(item['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['address']!, style: const TextStyle(color: AppColors.textSecondary)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  // Delete logic
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddAddressDialog(context);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Saved Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(hintText: 'Label (e.g. Home)')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(hintText: 'Full Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
