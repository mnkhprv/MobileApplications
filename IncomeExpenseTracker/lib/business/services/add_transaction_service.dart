import '../../domain/domain.dart';

/// Use case: record an income or expense (used by the upcoming
/// "Add Expense" screen). Rules: needs a title and a positive amount.
class AddTransactionService {
  AddTransactionService(this._transactions);

  final TransactionRepo _transactions;

  Future<void> execute(Transaction transaction) async {
    if (transaction.title.trim().isEmpty) {
      throw const DomainException('Гарчиг оруулна уу');
    }
    if (transaction.amount <= 0) {
      throw const DomainException('Дүн 0-ээс их байх ёстой');
    }
    await _transactions.save(transaction);
  }
}
