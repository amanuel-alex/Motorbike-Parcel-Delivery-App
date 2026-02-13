import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminUsersListScreen extends StatelessWidget {
  const AdminUsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: const Text('User Management', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Customers"),
              Tab(text: "Riders"),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: AuthService().getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final allUsers = snapshot.data ?? [];
            if (allUsers.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            final customers = allUsers.where((u) => u['role'] == 'customer').toList();
            final riders = allUsers.where((u) => u['role'] == 'rider').toList();

            return TabBarView(
              children: [
                _buildUserList(allUsers),
                _buildUserList(customers),
                _buildUserList(riders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return const Center(child: Text("No users in this category", style: TextStyle(color: Colors.grey)));
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
