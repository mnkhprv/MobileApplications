import 'bill.dart';

enum TransactionType { income, expense }

/// Where a transaction came from. Stored, so the history can tell a wallet
/// top-up or a bill payment apart from a manual entry.
enum TransactionKind { general, topUp, billPayment }

/// Entity: one income or expense entry. [amount] is always positive;
/// [type] says which direction the money went.
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.iconAsset,
    this.iconSize,
    this.kind = TransactionKind.general,
    this.receiptNumber,
  });

  /// The expense recorded when [bill] is paid at [at]: price + fee.
  /// [receiptNumber] links it to its receipt.
  factory Transaction.expenseForBill(
    Bill bill,
    DateTime at, {
    String? receiptNumber,
  }) => Transaction(
    id: 'paid-${bill.id}-${at.microsecondsSinceEpoch}',
    title: bill.title,
    amount: bill.total,
    type: TransactionType.expense,
    date: at,
    iconAsset: bill.iconAsset,
    iconSize: bill.iconSize,
    kind: TransactionKind.billPayment,
    receiptNumber: receiptNumber,
  );

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;

  /// Optional logo shown in the list (e.g. Upwork, PayPal).
  final String? iconAsset;

  /// When set, [iconAsset] is a small logo centred on a light tile at this
  /// size (e.g. a paid bill). When null, [iconAsset] fills the whole tile.
  final double? iconSize;

  final TransactionKind kind;

  /// Set for bill payments: opens the saved receipt.
  final String? receiptNumber;

  bool get isIncome => type == TransactionType.income;

  /// Positive for income, negative for expense.
  double get signedAmount => isIncome ? amount : -amount;
}
