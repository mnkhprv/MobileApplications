import '../models/user.dart';

/// Thrown when registration or login fails. [message] is shown to the user.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Service: where user accounts are stored.
///
/// The ViewModel only talks to this interface, so the storage can change
/// later (local database, Firebase, REST API) without touching any screen.
abstract class AuthService {
  Future<User> register({required String fullName, required String email, required String password});
  Future<User> login({required String email, required String password});
}

/// Keeps accounts in memory while the app is running.
/// Week 1 has no database yet; swap this class out when one is added.
class InMemoryAuthService implements AuthService {
  final Map<String, ({User user, String password})> _accounts = {};

  static String _key(String email) => email.trim().toLowerCase();

  @override
  Future<User> register({required String fullName, required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400)); // simulate I/O
    final key = _key(email);
    if (_accounts.containsKey(key)) {
      throw const AuthException('Энэ имэйлээр бүртгэл үүссэн байна');
    }
    final user = User(fullName: fullName.trim(), email: email.trim());
    _accounts[key] = (user: user, password: password);
    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400)); // simulate I/O
    final account = _accounts[_key(email)];
    if (account == null || account.password != password) {
      throw const AuthException('Имэйл эсвэл нууц үг буруу байна');
    }
    return account.user;
  }
}
