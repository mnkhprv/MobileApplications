/// Thrown when an entity or business service refuses an action.
/// [message] is safe to show to the user.
class DomainException implements Exception {
  const DomainException(this.message);
  final String message;

  @override
  String toString() => message;
}
