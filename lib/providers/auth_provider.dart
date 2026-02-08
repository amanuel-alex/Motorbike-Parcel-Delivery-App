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
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> setRole(String role) async {
    if (_user != null) {
      _isLoading = true;
      notifyListeners();
      await _authService.setUserRole(_user!.uid, role);
      _userRole = role;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
