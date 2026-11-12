enum TransactionType { income, expense }

/// Model: one income or expense entry. [amount] is always positive;
/// [type] says which direction the money went.
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.iconAsset,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;

  /// Optional logo shown in the list (e.g. Upwork, PayPal).
  final String? iconAsset;

  bool get isIncome => type == TransactionType.income;

  /// Positive for income, negative for expense.
  double get signedAmount => isIncome ? amount : -amount;
}
