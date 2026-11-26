import '../../domain/domain.dart';

/// Use case: top the wallet up from a linked card ("Түрийвч цэнэглэх").
/// Rules: the amount is positive and the card is linked to this wallet.
/// The top-up is saved as an income transaction of kind [TransactionKind.topUp],
/// so the balance goes up everywhere.
class TopUpWalletService {
  TopUpWalletService(
    this._wallet,
    this._transactions, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final WalletRepo _wallet;
  final TransactionRepo _transactions;
  final DateTime Function() _clock;

  Future<Transaction> execute({
    required String cardId,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw const DomainException('Цэнэглэх дүн 0-ээс их байх ёстой');
    }
    final card = (await _wallet.findCards())
        .where((c) => c.id == cardId)
        .firstOrNull;
    if (card == null) throw const DomainException('Карт олдсонгүй');

    final now = _clock();
    final topUp = Transaction(
      id: 'topup-${now.microsecondsSinceEpoch}',
      title: 'Түрийвч цэнэглэлт •${card.last4}',
      amount: amount,
      type: TransactionType.income,
      date: now,
      kind: TransactionKind.topUp,
    );
    await _transactions.save(topUp);
    return topUp;
  }
}
