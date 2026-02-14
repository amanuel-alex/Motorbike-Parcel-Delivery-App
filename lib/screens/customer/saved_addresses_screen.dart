import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context).user?.uid ?? 'demo_guest_id';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Saved Addresses', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _authService.getSavedAddresses(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  const Text('No saved addresses', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final item = addresses[index];
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
                      item['icon'] == 'Home' ? Icons.home_outlined : Icons.work_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(item['label'] ?? 'Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['address'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      if (await showConfirmationDialog(context, "Delete Address", "Are you sure?")) {
                         await _authService.deleteSavedAddress(uid, item['id']);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddAddressDialog(context, uid);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context, String uid) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    String selectedIcon = 'Home';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Saved Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(hintText: 'Label (e.g. Home, Office)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(hintText: 'Full Address'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _iconTypeChip(setDialogState, 'Home', Icons.home, selectedIcon, (v) => setDialogState(() => selectedIcon = v)),
                  _iconTypeChip(setDialogState, 'Office', Icons.work, selectedIcon, (v) => setDialogState(() => selectedIcon = v)),
                  _iconTypeChip(setDialogState, 'Other', Icons.location_on, selectedIcon, (v) => setDialogState(() => selectedIcon = v)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                   await _authService.addSavedAddress(uid, {
                     'label': labelController.text.trim(),
                     'address': addressController.text.trim(),
                     'icon': selectedIcon,
                   });
                   if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconTypeChip(StateSetter setDialogState, String type, IconData icon, String current, Function(String) onSelected) {
    bool isSelected = current == type;
    return GestureDetector(
      onTap: () => onSelected(type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
      ),
    );
  }
}
