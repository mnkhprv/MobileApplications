import '../../domain/domain.dart';

/// Use cases for the session: sign in, sign out, and "who is signed in"
/// (so an earlier session skips the login screen).
class LoginService {
  LoginService(this._auth);

  final AuthRepo _auth;

  Future<User> execute({required String email, required String password}) =>
      _auth.login(email: email.trim(), password: password);

  Future<void> logout() => _auth.logout();

  User? get currentUser => _auth.currentUser;
}
