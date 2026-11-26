/// Entity: a signed-in app user, safe to show in the UI (no password —
/// passwords are handled only by the auth adapter, e.g. Firebase Auth).
class User {
  const User({required this.id, required this.fullName, required this.email});

  /// Stable id from the auth provider (Firebase uid).
  final String id;
  final String fullName;
  final String email;
}
