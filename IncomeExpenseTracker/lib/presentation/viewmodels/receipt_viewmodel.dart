import 'package:flutter/foundation.dart';

import '../../business/services/get_receipt_service.dart';
import '../../domain/domain.dart';

/// ViewModel for the receipt screen. Either the receipt is already known
/// (right after paying) or it is loaded by number (history → a paid bill).
class ReceiptViewModel extends ChangeNotifier {
  ReceiptViewModel.ready(BillReceipt receipt) : _receipt = receipt, _get = null;

  ReceiptViewModel.load(GetReceiptService get, String number) : _get = get {
    _fetch(number);
  }

  final GetReceiptService? _get;
  BillReceipt? _receipt;
  String? _errorMessage;

  BillReceipt? get receipt => _receipt;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _receipt == null && _errorMessage == null;

  Future<void> _fetch(String number) async {
    try {
      _receipt = await _get!.execute(number);
    } on DomainException catch (e) {
      _errorMessage = e.message;
    }
    notifyListeners();
  }
}

/// Text encoded in the receipt's QR code: enough to identify and verify the
/// payment (number, what, how much, when, how).
String receiptQrData(BillReceipt r) => [
  'RECEIPT:${r.number}',
  'BILL:${r.billTitle}',
  'TOTAL:${r.total.toStringAsFixed(2)}',
  'PAID:${r.paidAt.toIso8601String()}',
  'METHOD:${r.method.name}',
].join('\n');
