import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

/// ViewModel: state and logic for Register and Login.
///
/// Screens call [register] / [login] and redraw when [notifyListeners] fires.
/// No widgets here, so this class can be unit-tested without any UI.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service);

  final AuthService _service;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Returns true on success. On failure [errorMessage] is set.
  Future<bool> register({required String fullName, required String email, required String password}) {
    return _run(() => _service.register(fullName: fullName, email: email, password: password),
        signIn: false);
  }

  /// Returns true on success. On failure [errorMessage] is set.
  Future<bool> login({required String email, required String password}) {
    return _run(() => _service.login(email: email, password: password), signIn: true);
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<User> Function() action, {required bool signIn}) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await action();
      if (signIn) _currentUser = user;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
