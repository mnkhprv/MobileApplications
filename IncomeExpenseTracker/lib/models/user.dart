/// Model: a registered app user. Plain data, no UI or logic.
class User {
  const User({required this.fullName, required this.email});

  final String fullName;
  final String email;
}
