import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/common_widgets.dart';

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
                showLogoutDialog(context);
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
        
        final status = user['status'] ?? 'active';
        final isDeactivated = status == 'deactivated';
        
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: ListTile(
            onLongPress: () async {
               final action = isDeactivated ? "Activate" : "Deactivate";
               if (await showConfirmationDialog(context, "$action User", "Are you sure you want to $action this user?")) {
                  await AuthService().updateUserStatus(user['uid'], isDeactivated ? 'active' : 'deactivated');
               }
            },
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(role).withOpacity(0.1),
              child: Icon(_getRoleIcon(role), color: _getRoleColor(role)),
            ),
            title: Text(phone, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role: ${role.toUpperCase()}'),
                if (role == 'rider') 
                  Text(
                    'Jobs: ${user['completedDeliveries'] ?? 0} Done / ${user['totalDeliveries'] ?? 0} Total',
                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (!isDeactivated ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: !isDeactivated ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: () => _handleDeleteUser(context, user),
                ),
              ],
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

  void _handleDeleteUser(BuildContext context, Map<String, dynamic> user) async {
    if (!await showConfirmationDialog(context, "Delete User", "Are you sure you want to delete this user? This action can be undone immediately via the snackbar.")) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final uid = user['uid'] as String;
    
    // Immediate Delete
    await AuthService().deleteUser(uid);

    messenger.showSnackBar(
      SnackBar(
        content: Text("User ${user['phoneNumber'] ?? ''} deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            // Restore user record
            final data = Map<String, dynamic>.from(user);
            data.remove('uid'); // ID is the document ID
            await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
          },
        ),
      ),
    );
  }
}
