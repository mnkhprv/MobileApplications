import '../entity/payment.dart';

/// Port: where payment receipts are kept, so they can be opened again later
/// (tap a paid bill in the history → its receipt and QR code).
abstract class ReceiptRepo {
  Future<void> save(BillReceipt receipt);
  Future<BillReceipt?> findByNumber(String number);
}
