import '../../../domain/domain.dart';
import '../starter_bills.dart';
import 'in_memory_repos.dart';

/// Demo data from the Figma design, so the screens have something to show.
/// Called from `main.dart` (and tests), like "2. Seed data" in the course.
void seedDemoData({
  required InMemoryTransactionRepo transactions,
  required InMemoryBillRepo bills,
  InMemoryWalletRepo? wallet,
  required DateTime now,
}) {
  for (final t in [
    Transaction(
      id: 'seed-1',
      title: 'Upwork',
      amount: 850,
      type: TransactionType.income,
      date: now,
      iconAsset: 'assets/images/transactions/upwork.png',
    ),
    Transaction(
      id: 'seed-2',
      title: 'Шилжүүлэг',
      amount: 85,
      type: TransactionType.expense,
      date: now.subtract(const Duration(days: 1)),
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
  ]) {
    transactions.seed(t);
  }

  for (final b in starterBills(now)) {
    bills.seed(b);
  }

  // The card shown in the Figma design. Only the last 4 digits are stored.
  wallet?.seed(
    PaymentCard(
      id: 'card-seed',
      holderName: 'Irvan Moses',
      last4: '8075',
      expiryYear: now.year + 2,
      expiryMonth: 1,
    ),
  );
}
