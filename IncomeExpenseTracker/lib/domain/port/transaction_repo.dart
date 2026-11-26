import '../entity/transaction.dart';

/// Port: what the business layer needs from transaction storage.
/// Says *what*, never *how* — see `infrastructure/` for the adapters.
abstract class TransactionRepo {
  /// Current transactions, then a new list after every change (Observer).
  Stream<List<Transaction>> watchAll();

  Future<void> save(Transaction transaction);
}
