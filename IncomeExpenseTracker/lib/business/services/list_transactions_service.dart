import '../../domain/domain.dart';

/// Use case: the transaction history, newest first, updated live.
class ListTransactionsService {
  ListTransactionsService(this._transactions);

  final TransactionRepo _transactions;

  Stream<List<Transaction>> execute() => _transactions.watchAll().map(
    (items) => [...items]..sort((a, b) => b.date.compareTo(a.date)),
  );
}
