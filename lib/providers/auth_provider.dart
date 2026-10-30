import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Runs an action with loading/error handling. Returns true on success.
  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Une erreur est survenue. Réessayez.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) =>
      _run(() async => _user = await _service.signIn(email, password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) =>
      _run(() async => _user = await _service.register(
          name: name, email: email, password: password, role: role));

  /// Returns the demo code, or null on error (see [error]).
  Future<String?> requestResetCode(String email) async {
    String? code;
    final ok = await _run(() async => code = await _service.requestResetCode(email));
    return ok ? code : null;
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _run(() => _service.resetPassword(
          email: email, code: code, newPassword: newPassword));

  void signOut() {
    _user = null;
    notifyListeners();
  }
}