import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/business/services/add_card_service.dart';
import 'package:income_expense_tracker/business/services/add_transaction_service.dart';
import 'package:income_expense_tracker/business/services/connect_account_service.dart';
import 'package:income_expense_tracker/business/services/get_receipt_service.dart';
import 'package:income_expense_tracker/business/services/list_cards_service.dart';
import 'package:income_expense_tracker/business/services/pay_bill_service.dart';
import 'package:income_expense_tracker/business/services/top_up_wallet_service.dart';
import 'package:income_expense_tracker/domain/domain.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/in_memory_repos.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/seed.dart';

/// Business rules tested on their own — no Flutter, no ViewModels, no UI.
void main() {
  final now = DateTime(2026, 11, 19, 8, 15);

  group('Bill entity', () {
    test('can only be paid once', () {
      final bill = Bill(id: 'b', title: 'Spotify', amount: 9.99, dueDate: DateTime(2026), iconAsset: 'x', iconSize: 30);
      bill.markPaid();
      expect(bill.isPaid, isTrue);
      expect(bill.markPaid, throwsA(isA<DomainException>()));
    });

    test('total is price plus fee', () {
      final bill = Bill(id: 'b', title: 'Y', amount: 11.99, fee: 1.99, dueDate: DateTime(2026), iconAsset: 'x', iconSize: 30);
      expect(bill.total, closeTo(13.98, 1e-9));
    });
  });

  group('PaymentCard entity', () {
    PaymentCard create({
      String name = 'Bat Dorj',
      String number = '4242 4242 4242 4242',
      String cvc = '123',
      String expiry = '2028/01',
    }) =>
        PaymentCard.create(id: 'c', holderName: name, number: number, cvc: cvc, expiry: expiry, now: now);

    test('keeps only the last 4 digits', () {
      final card = create();
      expect(card.last4, '4242');
      expect(card.expiryYear, 2028);
      expect(card.expiryMonth, 1);
    });

    test('rejects a missing name', () {
      expect(() => create(name: ' '), throwsA(isA<DomainException>()));
    });

    test('rejects a wrong length or a failed checksum', () {
      expect(() => create(number: '4242 4242'), throwsA(isA<DomainException>()));
      expect(() => create(number: '4242 4242 4242 4241'), throwsA(isA<DomainException>()));
    });

    test('rejects a bad CVC', () {
      expect(() => create(cvc: '12'), throwsA(isA<DomainException>()));
    });

    test('rejects a malformed or expired date, accepts the current month', () {
      expect(() => create(expiry: '01/28'), throwsA(isA<DomainException>()));
      expect(() => create(expiry: '2028/13'), throwsA(isA<DomainException>()));
      expect(() => create(expiry: '2026/10'), throwsA(isA<DomainException>()));
      expect(create(expiry: '2026/11').expiryMonth, 11);
    });
  });

  group('PayBillService', () {
    late InMemoryBillRepo bills;
    late InMemoryTransactionRepo transactions;
    late InMemoryWalletRepo wallet;
    late InMemoryReceiptRepo receipts;
    late PayBillService service;

    setUp(() {
      bills = InMemoryBillRepo();
      transactions = InMemoryTransactionRepo();
      wallet = InMemoryWalletRepo();
      receipts = InMemoryReceiptRepo();
      seedDemoData(transactions: transactions, bills: bills, wallet: wallet, now: now);
      service = PayBillService(bills, transactions, wallet, receipts, clock: () => now);
    });

    test('saves the receipt and links it from the expense', () async {
      final receipt = await service.execute('bill-youtube', PaymentMethod.debitCard);
      expect((await GetReceiptService(receipts).execute(receipt.number)).total, closeTo(13.98, 1e-9));
      final expense = (await transactions.watchAll().first).firstWhere((t) => t.receiptNumber == receipt.number);
      expect(expense.kind, TransactionKind.billPayment);
    });

    test('an unknown receipt number is reported', () {
      expect(() => GetReceiptService(receipts).execute('nope'), throwsA(isA<DomainException>()));
    });

    test('returns a receipt and records the total as an expense', () async {
      final receipt = await service.execute('bill-youtube', PaymentMethod.debitCard);
      expect(receipt.billTitle, 'Youtube Premium');
      expect(receipt.method, PaymentMethod.debitCard);
      expect(receipt.paidAt, now);
      expect(receipt.price, 11.99);
      expect(receipt.fee, 1.99);
      expect(receipt.total, closeTo(13.98, 1e-9));
      expect(receipt.number, isNotEmpty);

      expect((await bills.findById('bill-youtube'))!.isPaid, isTrue);
      final expense = (await transactions.watchAll().first).firstWhere((t) => t.title == 'Youtube Premium' && t.date == now);
      expect(expense.amount, closeTo(13.98, 1e-9));
      expect(expense.type, TransactionType.expense);
    });

    test('refuses to pay the same bill twice', () async {
      await service.execute('bill-spotify', PaymentMethod.debitCard);
      expect(() => service.execute('bill-spotify', PaymentMethod.debitCard), throwsA(isA<DomainException>()));
    });

    test('refuses an unknown bill', () {
      expect(() => service.execute('nope', PaymentMethod.debitCard), throwsA(isA<DomainException>()));
    });

    test('debit card needs a linked card', () async {
      final noCards = PayBillService(bills, transactions, InMemoryWalletRepo(), receipts, clock: () => now);
      await expectLater(noCards.execute('bill-spotify', PaymentMethod.debitCard), throwsA(isA<DomainException>()));
      expect((await bills.findById('bill-spotify'))!.isPaid, isFalse, reason: 'nothing changes on failure');
    });

    test('wallet needs enough balance', () async {
      // Seed balance is 2,159.01: rent (600) fits, then a huge bill does not.
      await service.execute('bill-rent', PaymentMethod.wallet);
      bills.seed(Bill(id: 'big', title: 'Big', amount: 5000, dueDate: now, iconAsset: 'x', iconSize: 30));
      await expectLater(service.execute('big', PaymentMethod.wallet), throwsA(isA<DomainException>()));
      expect((await bills.findById('big'))!.isPaid, isFalse);
    });
  });

  group('AddCardService', () {
    late InMemoryWalletRepo wallet;
    late InMemoryTransactionRepo transactions;
    late AddCardService service;

    setUp(() {
      wallet = InMemoryWalletRepo();
      transactions = InMemoryTransactionRepo();
      service = AddCardService(wallet, TopUpWalletService(wallet, transactions, clock: () => now), clock: () => now);
    });

    Future<PaymentCard> add({double? topUp}) => service.execute(
          holderName: 'Bat Dorj',
          number: '4242424242424242',
          cvc: '123',
          expiry: '2028/01',
          topUp: topUp,
        );

    test('links the card without a top-up', () async {
      final card = await add();
      expect(await wallet.findCards(), [card]);
      expect(await transactions.watchAll().first, isEmpty);
    });

    test('a top-up is recorded as income of kind topUp', () async {
      await add(topUp: 100);
      final income = (await transactions.watchAll().first).single;
      expect(income.type, TransactionType.income);
      expect(income.kind, TransactionKind.topUp);
      expect(income.amount, 100);
    });

    test('TopUpWalletService needs a linked card and a positive amount', () async {
      final topUp = TopUpWalletService(wallet, transactions, clock: () => now);
      await expectLater(topUp.execute(cardId: 'nope', amount: 10), throwsA(isA<DomainException>()));
      final card = await add();
      await expectLater(topUp.execute(cardId: card.id, amount: -1), throwsA(isA<DomainException>()));
      expect((await topUp.execute(cardId: card.id, amount: 25)).title, contains('4242'));
    });

    test('rejects a zero top-up and saves nothing', () async {
      await expectLater(add(topUp: 0), throwsA(isA<DomainException>()));
      expect(await wallet.findCards(), isEmpty);
    });

    test('ListCardsService shows the newest card first', () async {
      seedDemoData(transactions: InMemoryTransactionRepo(), bills: InMemoryBillRepo(), wallet: wallet, now: now);
      final added = await add();
      expect((await ListCardsService(wallet).execute()).first.id, added.id);
    });
  });

  group('ConnectAccountService', () {
    test('remembers the chosen account', () async {
      final service = ConnectAccountService(InMemoryWalletRepo());
      expect(await service.current(), isNull);
      await service.execute(LinkedAccountType.paypal);
      expect(await service.current(), LinkedAccountType.paypal);
    });
  });

  group('AddTransactionService', () {
    final service = AddTransactionService(InMemoryTransactionRepo());
    Transaction tx({String title = 'Хоол', double amount = 10}) => Transaction(
          id: 't',
          title: title,
          amount: amount,
          type: TransactionType.expense,
          date: DateTime(2026),
        );

    test('rejects an empty title', () {
      expect(() => service.execute(tx(title: '  ')), throwsA(isA<DomainException>()));
    });

    test('rejects a zero or negative amount', () {
      expect(() => service.execute(tx(amount: 0)), throwsA(isA<DomainException>()));
      expect(() => service.execute(tx(amount: -5)), throwsA(isA<DomainException>()));
    });

    test('accepts a valid transaction', () async {
      await service.execute(tx());
    });
  });
}
