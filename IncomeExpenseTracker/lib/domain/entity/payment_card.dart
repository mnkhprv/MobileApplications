import 'domain_exception.dart';

/// Ways to link an outside account (Connect Wallet → "Аккаунт" tab).
enum LinkedAccountType { bankLink, microdeposits, paypal }

/// Entity: a debit card linked to the wallet (Connect Wallet → "Картууд").
///
/// Security rule: the full card number and the CVC are only *checked* by
/// [PaymentCard.create] — they are never stored. Only the last 4 digits are
/// kept, which is all the UI needs to show "•••• 8075".
class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.holderName,
    required this.last4,
    required this.expiryYear,
    required this.expiryMonth,
  });

  /// Validates what the user typed and builds the card, or throws a
  /// [DomainException] that says what is wrong. Like `BookCopy.markLoaned()`,
  /// the entity enforces its own rules.
  factory PaymentCard.create({
    required String id,
    required String holderName,
    required String number,
    required String cvc,
    required String expiry,
    required DateTime now,
  }) {
    final name = holderName.trim();
    if (name.isEmpty) {
      throw const DomainException('Карт дээрх нэрээ оруулна уу');
    }

    final digits = number.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{16}$').hasMatch(digits) || !_passesLuhn(digits)) {
      throw const DomainException('Картын дугаар буруу байна');
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(cvc.trim())) {
      throw const DomainException('CVC 3 эсвэл 4 оронтой байна');
    }

    final match = RegExp(r'^(\d{4})\s*/\s*(\d{1,2})$')
        .firstMatch(expiry.trim());
    final year = match == null ? null : int.parse(match.group(1)!);
    final month = match == null ? null : int.parse(match.group(2)!);
    if (year == null || month == null || month < 1 || month > 12) {
      throw const DomainException(
        'Дуусах хугацааг YYYY/MM хэлбэрээр оруулна уу',
      );
    }
    // A card is valid until the end of its expiry month.
    if (DateTime(
      year,
      month + 1,
    ).isBefore(DateTime(now.year, now.month, now.day))) {
      throw const DomainException('Картын хугацаа дууссан байна');
    }

    return PaymentCard(
      id: id,
      holderName: name,
      last4: digits.substring(12),
      expiryYear: year,
      expiryMonth: month,
    );
  }

  final String id;
  final String holderName;
  final String last4;
  final int expiryYear;
  final int expiryMonth;

  /// Standard checksum every real card number satisfies — catches typos.
  static bool _passesLuhn(String digits) {
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var d = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
    }
    return sum % 10 == 0;
  }
}
