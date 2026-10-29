import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final ok = await _service.signIn(email, password);
    if (!ok) _error = 'Incorrect e-mail or password.';

    _loading = false;
    notifyListeners();
    return ok;
  }
}