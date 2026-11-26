import 'domain_exception.dart';

/// Entity: an upcoming bill (Wallet → "Хүлээгдэж буй гүйлгээ").
///
/// Like `BookCopy.markLoaned()` in the course, the entity guards its own rule:
/// a bill can only be paid once.
class Bill {
  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.iconAsset,
    required this.iconSize,
    this.fee = 0,
    bool paid = false, // only for adapters loading a stored bill
  }) : _isPaid = paid;

  final String id;
  final String title;

  /// Price of the service itself ("Үнэ").
  final double amount;

  /// Service fee charged on top ("Хураамж").
  final double fee;

  final DateTime dueDate;

  /// Logo drawn in the middle of the light-green tile (.svg or .png).
  final String iconAsset;

  /// Logo size inside the 50px tile, in design pixels.
  final double iconSize;

  /// What the user actually pays ("Нийт").
  double get total => amount + fee;

  // Private, like `_st` in the course's BookCopy: only [markPaid] can change it.
  bool _isPaid;
  bool get isPaid => _isPaid;

  void markPaid() {
    if (_isPaid) throw const DomainException('Энэ төлбөр аль хэдийн төлөгдсөн');
    _isPaid = true;
  }
}
