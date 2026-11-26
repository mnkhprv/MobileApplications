import 'package:flutter/foundation.dart';

import '../../business/services/pay_bill_service.dart';
import '../../domain/domain.dart';

/// ViewModel for the bill flow: Bill Details → Bill Payment (confirm) →
/// Bill Payment (receipt). One instance is shared by the three screens so the
/// chosen payment method and the receipt survive the navigation.
class BillPaymentViewModel extends ChangeNotifier {
  BillPaymentViewModel(this._payBill, this.bill);

  final PayBillService _payBill;
  final Bill bill;

  PaymentMethod _method = PaymentMethod.debitCard;
  bool _isPaying = false;
  String? _errorMessage;
  BillReceipt? _receipt;

  PaymentMethod get method => _method;
  bool get isPaying => _isPaying;
  String? get errorMessage => _errorMessage;

  /// Set once the payment succeeded.
  BillReceipt? get receipt => _receipt;

  void selectMethod(PaymentMethod method) {
    if (_method == method || _receipt != null) return;
    _method = method;
    notifyListeners();
  }

  /// Returns true on success. On failure [errorMessage] is set.
  Future<bool> pay() async {
    if (_isPaying || _receipt != null) return false;
    _isPaying = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _receipt = await _payBill.execute(bill.id, _method);
      return true;
    } on DomainException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isPaying = false;
      notifyListeners();
    }
  }
}

/// Display names for [PaymentMethod] (Bill Details tiles, receipt).
String paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.debitCard => 'Дебит карт',
  PaymentMethod.wallet => 'Түрийвч',
};

/// "…-аар/-ээр" form used in a sentence: "дебит картаар төлөх".
String paymentMethodInstrumental(PaymentMethod method) => switch (method) {
  PaymentMethod.debitCard => 'дебит картаар',
  PaymentMethod.wallet => 'түрийвчээр',
};
