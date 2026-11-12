import '../models/transaction.dart';

/// Service: where transactions are stored. The ViewModel only knows this
/// interface, so a real database can replace the in-memory version later.
abstract class TransactionService {
  Future<List<Transaction>> fetchAll();
  Future<void> add(Transaction transaction);
}

/// Keeps transactions in memory, seeded with the examples from the Figma
/// design so the home screen has something to show.
class InMemoryTransactionService implements TransactionService {
  InMemoryTransactionService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    final today = _clock();
    _items.addAll([
      Transaction(
        id: 'seed-1',
        title: 'Upwork',
        amount: 850,
        type: TransactionType.income,
        date: today,
        iconAsset: 'assets/images/transactions/upwork.png',
      ),
      Transaction(
        id: 'seed-2',
        title: 'Шилжүүлэг',
        amount: 85,
        type: TransactionType.expense,
        date: today.subtract(const Duration(days: 1)),
        iconAsset: 'assets/images/transactions/transfer.png',
      ),
      Transaction(
        id: 'seed-3',
        title: 'Paypal',
        amount: 1406,
        type: TransactionType.income,
        date: DateTime(2022, 1, 30),
        iconAsset: 'assets/images/transactions/paypal.png',
      ),
      Transaction(
        id: 'seed-4',
        title: 'Youtube',
        amount: 11.99,
        type: TransactionType.expense,
        date: DateTime(2022, 1, 16),
        iconAsset: 'assets/images/transactions/youtube.png',
      ),
    ]);
  }

  final DateTime Function() _clock;
  final List<Transaction> _items = [];

  @override
  Future<List<Transaction>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200)); // simulate I/O
    return List.unmodifiable(_items);
  }

  @override
  Future<void> add(Transaction transaction) async {
    _items.add(transaction);
  }
}
