import '../../domain/domain.dart';

/// Use case: pay a bill. Same shape as `BorrowBookService` in the course:
/// check the rules, let the entity check its own rule, then save every change.
///
/// Rules:
/// - paying by debit card needs a linked card;
/// - paying from the wallet needs enough balance for price + fee;
/// - a bill can only be paid once (checked by [Bill.markPaid]).
///
/// Paying marks the bill as paid, records an expense (so the balance on
/// Home and Wallet drops by the bill total) and saves the receipt.
class PayBillService {
  PayBillService(
    this._bills,
    this._transactions,
    this._wallet,
    this._receipts, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final BillRepo _bills;
  final TransactionRepo _transactions;
  final WalletRepo _wallet;
  final ReceiptRepo _receipts;
  final DateTime Function() _clock;

  Future<BillReceipt> execute(String billId, PaymentMethod method) async {
    final bill = await _bills.findById(billId);
    if (bill == null) throw const DomainException('Төлбөр олдсонгүй');

    switch (method) {
      case PaymentMethod.debitCard:
        if ((await _wallet.findCards()).isEmpty) {
          throw const DomainException(
            'Холбосон карт алга. Эхлээд карт нэмнэ үү',
          );
        }
      case PaymentMethod.wallet:
        if (await _balance() < bill.total) {
          throw const DomainException('Түрийвчний үлдэгдэл хүрэлцэхгүй байна');
        }
    }

    bill.markPaid(); // throws if it was already paid

    final now = _clock();
    final receipt = BillReceipt.forBill(bill, method, now);
    await _bills.save(bill);
    await _transactions.save(
      Transaction.expenseForBill(bill, now, receiptNumber: receipt.number),
    );
    await _receipts.save(receipt);
    return receipt;
  }

  Future<double> _balance() async {
    final all = await _transactions.watchAll().first;
    return all.fold<double>(0, (sum, t) => sum + t.signedAmount);
  }
}
