import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class AdminUsersListScreen extends StatelessWidget {
  const AdminUsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AuthService().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final role = user['role'] ?? 'unknown';
              final phone = user['phoneNumber'] ?? 'Unknown';
              
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(role).withOpacity(0.1),
                    child: Icon(_getRoleIcon(role), color: _getRoleColor(role)),
                  ),
                  title: Text(phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Role: ${role.toUpperCase()}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (user['status'] == 'active' ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user['status']?.toUpperCase() ?? 'ACTIVE',
                      style: TextStyle(
                        color: user['status'] == 'active' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'customer': return Colors.blue;
      case 'rider': return Colors.orange;
      case 'admin': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'customer': return Icons.person;
      case 'rider': return Icons.moped;
      case 'admin': return Icons.admin_panel_settings;
      default: return Icons.help;
    }
  }
}
