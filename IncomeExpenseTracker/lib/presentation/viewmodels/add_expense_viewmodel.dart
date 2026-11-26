import 'package:flutter/foundation.dart';

import '../../business/services/add_transaction_service.dart';
import '../../domain/domain.dart';

/// A payee the user can pick in "ГҮЙЛГЭЭНИЙ НЭР". Display data only.
class ExpensePayee {
  const ExpensePayee(this.title, this.iconAsset, this.iconSize);
  final String title;
  final String iconAsset;
  final double iconSize;
}

/// ViewModel for Add Expense ("Төлбөр нэмэх"): the form's state.
/// Turning text into a number happens here (a UI concern); whether the
/// expense is allowed is decided by [AddTransactionService].
class AddExpenseViewModel extends ChangeNotifier {
  AddExpenseViewModel(this._add, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _date = _today();
  }

  final AddTransactionService _add;
  final DateTime Function() _clock;

  static const payees = [
    ExpensePayee('Netflix', 'assets/images/transactions/netflix.png', 32),
    ExpensePayee('Youtube Premium', 'assets/images/bills/youtube.png', 35),
    ExpensePayee('Spotify', 'assets/images/bills/spotify.png', 30),
    ExpensePayee('Цахилгаан', 'assets/svg/wallet/lightning.svg', 28),
    ExpensePayee('Байрны түрээс', 'assets/svg/wallet/house.svg', 30),
  ];

  ExpensePayee _payee = payees.first;
  late DateTime _date;
  bool _isSaving = false;
  String? _errorMessage;

  ExpensePayee get payee => _payee;
  DateTime get date => _date;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void selectPayee(ExpensePayee payee) {
    _payee = payee;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _date = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void reset() {
    _payee = payees.first;
    _date = _today();
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns true on success. On failure [errorMessage] is set.
  Future<bool> save(String amountText) async {
    if (_isSaving) return false;
    final amount = double.tryParse(
      amountText.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), ''),
    );
    if (amount == null) {
      _errorMessage = 'Үнийн дүнгээ оруулна уу';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final now = _clock();
      await _add.execute(
        Transaction(
          id: 'expense-${now.microsecondsSinceEpoch}',
          title: _payee.title,
          amount: amount,
          type: TransactionType.expense,
          // Chosen day, current time — keeps same-day entries in order.
          date: DateTime(
            _date.year,
            _date.month,
            _date.day,
            now.hour,
            now.minute,
            now.second,
          ),
          iconAsset: _payee.iconAsset,
          iconSize: _payee.iconSize,
        ),
      );
      return true;
    } on DomainException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  DateTime _today() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }
}
