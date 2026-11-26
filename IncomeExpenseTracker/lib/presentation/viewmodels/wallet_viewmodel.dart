import 'package:flutter/foundation.dart';

import '../../business/services/list_pending_bills_service.dart';
import '../../domain/domain.dart';

/// The two tabs on the Wallet screen (Figma frames 1:2530 and 1:2630).
enum WalletTab { transactions, pending }

/// ViewModel for the Wallet screen: which tab is open and the pending bills.
/// Paying a bill has its own flow and ViewModel ([BillPaymentViewModel]);
/// when it finishes, the screen calls [load] with `force: true`.
class WalletViewModel extends ChangeNotifier {
  WalletViewModel(this._listPending);

  final ListPendingBillsService _listPending;

  WalletTab _tab = WalletTab.transactions;
  List<Bill> _pending = const [];
  bool _isLoading = false;
  bool _loaded = false;
  String? _errorMessage;

  WalletTab get tab => _tab;
  List<Bill> get pendingBills => _pending;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void selectTab(WalletTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  /// Forgets everything — on logout.
  void reset() {
    _tab = WalletTab.transactions;
    _pending = const [];
    _loaded = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Loads bills once; later calls do nothing unless [force] is true.
  Future<void> load({bool force = false}) async {
    if (_isLoading || (_loaded && !force)) return;
    _isLoading = true;
    notifyListeners();
    try {
      _pending = await _listPending.execute();
      _loaded = true;
      _errorMessage = null;
    } on DomainException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
