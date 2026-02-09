import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login/phone_number_login_screen.dart';
import '../screens/login/role_selection_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/rider/available_jobs_screen.dart';
import '../core/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Check if user is logged in (or in Demo Mode)
    if (authProvider.user == null && !AuthService.isDemoMode) {
      return const PhoneNumberLoginScreen();
    }

    // 2. Check if user has a role selected
    if (authProvider.userRole == null) {
      return const RoleSelectionScreen();
    }

    // 3. Route to specific home based on role
    if (authProvider.userRole == 'customer') {
      return const CustomerHomeScreen();
    } else {
      return const AvailableJobsScreen();
    }
  }
}
