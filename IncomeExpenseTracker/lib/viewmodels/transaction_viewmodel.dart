import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/transaction_service.dart';

/// ViewModel: the transaction list and the totals shown on the home card.
/// Totals are computed from the data, so adding a transaction anywhere in
/// the app updates every screen that watches this ViewModel.
class TransactionViewModel extends ChangeNotifier {
  TransactionViewModel(this._service);

  final TransactionService _service;

  List<Transaction> _transactions = const [];
  bool _isLoading = false;
  bool _loaded = false;

  /// Newest first.
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _sum(TransactionType.income);
  double get totalExpense => _sum(TransactionType.expense);
  double get balance => totalIncome - totalExpense;

  /// Loads once; later calls do nothing unless [force] is true.
  Future<void> load({bool force = false}) async {
    if (_isLoading || (_loaded && !force)) return;
    _isLoading = true;
    notifyListeners();
    final items = await _service.fetchAll();
    _transactions = [...items]..sort((a, b) => b.date.compareTo(a.date));
    _loaded = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(Transaction transaction) async {
    await _service.add(transaction);
    await load(force: true);
  }

  double _sum(TransactionType type) => _transactions
      .where((t) => t.type == type)
      .fold(0.0, (total, t) => total + t.amount);
}
