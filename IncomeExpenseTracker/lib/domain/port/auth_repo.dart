import '../entity/user.dart';

/// Port: who the user is. Adapters: Firebase Auth (the app) and an
/// in-memory version (tests). Failures are thrown as `DomainException`
/// with a message the user can read.
abstract class AuthRepo {
  /// Creates the account. The user is NOT left signed in — they log in next,
  /// as in the Register → Login design flow.
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  /// The user from a previous session, or null. Lets the app skip login.
  User? get currentUser;
}
