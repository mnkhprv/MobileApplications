import 'package:flutter/foundation.dart';

import '../../business/services/login_service.dart';
import '../../business/services/register_service.dart';
import '../../domain/domain.dart';

/// ViewModel for Register, Login and the session — the "controller" of the
/// course: calls business services, catches their errors, exposes UI state.
/// No rules live here; those are in [RegisterService] and [LoginService].
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._register, this._login)
    : _currentUser = _login.currentUser;

  final RegisterService _register;
  final LoginService _login;

  /// Starts as the user from an earlier session (Firebase remembers it).
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Returns true on success. On failure [errorMessage] is set.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) => _run(
    () =>
        _register.execute(fullName: fullName, email: email, password: password),
  );

  /// Returns true on success. On failure [errorMessage] is set.
  Future<bool> login({required String email, required String password}) => _run(
    () async =>
        _currentUser = await _login.execute(email: email, password: password),
  );

  Future<void> logout() async {
    await _login.logout();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on DomainException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
