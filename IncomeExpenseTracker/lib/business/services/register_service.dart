import '../../domain/domain.dart';

/// Use case: create a new account.
/// Rules: a name is required and the password has at least 6 characters.
/// "One account per e-mail" is enforced by the [AuthRepo] (Firebase Auth).
class RegisterService {
  RegisterService(this._auth);

  final AuthRepo _auth;

  Future<void> execute({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (fullName.trim().isEmpty) {
      throw const DomainException('Нэрээ оруулна уу');
    }
    if (password.length < 6) {
      throw const DomainException('Нууц үг хамгийн багадаа 6 тэмдэгт');
    }
    await _auth.register(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
    );
  }
}
