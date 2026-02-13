import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _userRole;
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.user.listen((User? user) async {
      _user = user;
      if (user != null) {
        _userRole = await _authService.getUserRole(user.uid);
        await _authService.updateMetadata(user.uid);
      } else if (!AuthService.isDemoMode) {
        _userRole = null;
      }
      debugPrint('Auth Update: Role=$_userRole, Demo=${AuthService.isDemoMode}');
      notifyListeners();
    });
  }

  Future<void> setRole(String role, {String? phoneNumber}) async {
    if (_user != null || AuthService.isDemoMode) {
      _isLoading = true;
      notifyListeners();
      
      if (_user != null) {
        await _authService.setUserRole(_user!.uid, role, phoneNumber: phoneNumber);
      }
      
      _userRole = role;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    AuthService.isDemoMode = false;
    await _authService.signOut();
    notifyListeners();
  }

  void triggerDemoMode({String? phoneNumber}) {
    AuthService.isDemoMode = true;
    // Boss Hack: If phone contains 999, login as Admin.
    // If phone contains 000, login as Rider. Otherwise, Customer.
    if (phoneNumber != null && phoneNumber.contains('999')) {
      _userRole = 'admin';
    } else if (phoneNumber != null && phoneNumber.contains('000')) {
      _userRole = 'rider';
    } else {
      _userRole = 'customer';
    }
    notifyListeners();
  }
}
