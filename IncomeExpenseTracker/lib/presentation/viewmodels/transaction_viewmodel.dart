import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../business/services/add_transaction_service.dart';
import '../../business/services/list_transactions_service.dart';
import '../../domain/domain.dart';

/// ViewModel for the transaction list and the balance card (Home + Wallet).
///
/// It *listens* to [ListTransactionsService] (Observer pattern), so when any
/// use case saves a transaction — e.g. paying a bill — this list and the
/// totals update by themselves. No ViewModel needs to know about another.
class TransactionViewModel extends ChangeNotifier {
  TransactionViewModel(this._list, this._add);

  final ListTransactionsService _list;
  final AddTransactionService _add;

  StreamSubscription<List<Transaction>>? _subscription;
  List<Transaction> _transactions = const [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Newest first.
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Display-only totals, derived from the list so they can never go stale.
  double get totalIncome => _sum(TransactionType.income);
  double get totalExpense => _sum(TransactionType.expense);
  double get balance => totalIncome - totalExpense;

  /// Starts listening once. Completes when the first list has arrived.
  Future<void> load() {
    if (_subscription != null) return Future.value();
    _isLoading = true;
    notifyListeners();
    final firstData = Completer<void>();
    void done() {
      _isLoading = false;
      if (!firstData.isCompleted) firstData.complete();
      notifyListeners();
    }

    _subscription = _list.execute().listen(
      (items) {
        _transactions = items;
        _errorMessage = null;
        done();
      },
      onError: (Object e) {
        _errorMessage = e is DomainException
            ? e.message
            : 'Гүйлгээ ачаалж чадсангүй';
        done();
      },
    );
    return firstData.future;
  }

  /// Returns true on success. On failure [errorMessage] is set.
  /// The list itself updates through the stream, not here.
  Future<bool> add(Transaction transaction) async {
    try {
      await _add.execute(transaction);
      return true;
    } on DomainException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Stops listening and forgets the list — on logout, so the next user
  /// never sees the previous user's data.
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _transactions = const [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  double _sum(TransactionType type) => _transactions
      .where((t) => t.type == type)
      .fold(0.0, (total, t) => total + t.amount);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
