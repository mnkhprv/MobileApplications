import 'bill.dart';

/// How a bill is paid (Bill Details → "Төлбөрийн хэрэгслээ сонго").
enum PaymentMethod { debitCard, wallet }

/// Entity: proof that a bill was paid — what the Bill Payment success
/// screen shows. Created only by `PayBillService`.
class BillReceipt {
  const BillReceipt({
    required this.number,
    required this.billTitle,
    required this.billIconAsset,
    required this.method,
    required this.paidAt,
    required this.price,
    required this.fee,
  });

  factory BillReceipt.forBill(Bill bill, PaymentMethod method, DateTime at) =>
      BillReceipt(
        // 13+ digits, unique per microsecond — like a bank reference number.
        number: '${at.microsecondsSinceEpoch}',
        billTitle: bill.title,
        billIconAsset: bill.iconAsset,
        method: method,
        paidAt: at,
        price: bill.amount,
        fee: bill.fee,
      );

  /// Transaction number ("Гүйлгээний дугаар").
  final String number;
  final String billTitle;
  final String billIconAsset;
  final PaymentMethod method;
  final DateTime paidAt;
  final double price;
  final double fee;

  double get total => price + fee;
}
