import '../../domain/domain.dart';

/// Use case: open a saved receipt again (history → a paid bill).
class GetReceiptService {
  GetReceiptService(this._receipts);

  final ReceiptRepo _receipts;

  Future<BillReceipt> execute(String number) async {
    final receipt = await _receipts.findByNumber(number);
    if (receipt == null) throw const DomainException('Баримт олдсонгүй');
    return receipt;
  }
}
