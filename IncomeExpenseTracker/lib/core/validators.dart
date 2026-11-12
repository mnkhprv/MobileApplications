/// Form field validators shared by the auth screens.
/// Each returns an error message, or null when the value is valid.
class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Заавал бөглөнө үү' : null;

  static String? email(String? v) {
    final empty = required(v);
    if (empty != null) return empty;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim());
    return ok ? null : 'Имэйл хаяг буруу байна';
  }

  static String? password(String? v) {
    final empty = required(v);
    if (empty != null) return empty;
    return v!.length < 6 ? 'Хамгийн багадаа 6 тэмдэгт' : null;
  }

  static String? Function(String?) matches(String Function() other) =>
      (v) => v != other() ? 'Нууц үг таарахгүй байна' : null;
}
