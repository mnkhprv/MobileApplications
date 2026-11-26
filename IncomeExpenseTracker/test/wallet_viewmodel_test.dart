import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/business/services/add_card_service.dart';
import 'package:income_expense_tracker/business/services/add_transaction_service.dart';
import 'package:income_expense_tracker/business/services/connect_account_service.dart';
import 'package:income_expense_tracker/business/services/list_cards_service.dart';
import 'package:income_expense_tracker/business/services/list_pending_bills_service.dart';
import 'package:income_expense_tracker/business/services/list_transactions_service.dart';
import 'package:income_expense_tracker/business/services/pay_bill_service.dart';
import 'package:income_expense_tracker/business/services/top_up_wallet_service.dart';
import 'package:income_expense_tracker/domain/domain.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/in_memory_repos.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/seed.dart';
import 'package:income_expense_tracker/presentation/viewmodels/add_expense_viewmodel.dart';
import 'package:income_expense_tracker/presentation/viewmodels/bill_payment_viewmodel.dart';
import 'package:income_expense_tracker/presentation/viewmodels/connect_wallet_viewmodel.dart';
import 'package:income_expense_tracker/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:income_expense_tracker/presentation/viewmodels/wallet_viewmodel.dart';

/// ViewModels for the Wallet area. Each one is built from real services and
/// in-memory repos — the same wiring as main.dart, minus the UI.
void main() {
  final now = DateTime(2026, 11, 19, 8, 15);
  late InMemoryTransactionRepo transactionRepo;
  late InMemoryBillRepo billRepo;
  late InMemoryWalletRepo walletRepo;
  late InMemoryReceiptRepo receiptRepo;
  late TransactionViewModel transactions;

  setUp(() async {
    transactionRepo = InMemoryTransactionRepo();
    billRepo = InMemoryBillRepo();
    walletRepo = InMemoryWalletRepo();
    receiptRepo = InMemoryReceiptRepo();
    seedDemoData(transactions: transactionRepo, bills: billRepo, wallet: walletRepo, now: now);
    transactions = TransactionViewModel(
      ListTransactionsService(transactionRepo),
      AddTransactionService(transactionRepo),
    );
    await transactions.load();
  });

  tearDown(() => transactions.dispose());

  group('WalletViewModel', () {
    late WalletViewModel vm;
    setUp(() => vm = WalletViewModel(ListPendingBillsService(billRepo)));

    test('starts on the transactions tab and switches tabs', () {
      expect(vm.tab, WalletTab.transactions);
      vm.selectTab(WalletTab.pending);
      expect(vm.tab, WalletTab.pending);
    });

    test('loads pending bills soonest first and refreshes after a payment', () async {
      await vm.load();
      expect(vm.pendingBills.map((b) => b.title), ['Youtube Premium', 'Цахилгаан', 'Байрны түрээс', 'Spotify']);
      await PayBillService(billRepo, transactionRepo, walletRepo, receiptRepo).execute('bill-rent', PaymentMethod.debitCard);
      await vm.load(force: true);
      expect(vm.pendingBills.map((b) => b.id), isNot(contains('bill-rent')));
    });
  });

  group('BillPaymentViewModel', () {
    late BillPaymentViewModel vm;

    setUp(() async {
      final bill = (await billRepo.findById('bill-youtube'))!;
      vm = BillPaymentViewModel(PayBillService(billRepo, transactionRepo, walletRepo, receiptRepo, clock: () => now), bill);
    });

    test('defaults to debit card and pays, updating the balance elsewhere', () async {
      final before = transactions.balance;
      expect(vm.method, PaymentMethod.debitCard);

      final future = vm.pay();
      expect(vm.isPaying, isTrue);
      expect(await vm.pay(), isFalse, reason: 'double tap is ignored');
      expect(await future, isTrue);

      expect(vm.receipt!.total, closeTo(13.98, 1e-9));
      await Future<void>.delayed(Duration.zero); // let the stream deliver
      expect(transactions.balance, closeTo(before - 13.98, 1e-9));
    });

    test('method cannot change after paying', () async {
      vm.selectMethod(PaymentMethod.wallet);
      await vm.pay();
      vm.selectMethod(PaymentMethod.debitCard);
      expect(vm.method, PaymentMethod.wallet);
      expect(vm.receipt!.method, PaymentMethod.wallet);
    });

    test('a refused payment sets an error and no receipt', () async {
      final noCards = BillPaymentViewModel(
        PayBillService(billRepo, transactionRepo, InMemoryWalletRepo(), receiptRepo),
        (await billRepo.findById('bill-spotify'))!,
      );
      expect(await noCards.pay(), isFalse);
      expect(noCards.errorMessage, isNotNull);
      expect(noCards.receipt, isNull);
    });
  });

  group('AddExpenseViewModel', () {
    late AddExpenseViewModel vm;
    setUp(() => vm = AddExpenseViewModel(AddTransactionService(transactionRepo), clock: () => now));

    test('saves the chosen payee, amount and date', () async {
      vm.selectPayee(AddExpenseViewModel.payees[2]); // Spotify
      vm.selectDate(DateTime(2026, 11, 1));
      expect(await vm.save('12,50'), isTrue);
      await Future<void>.delayed(Duration.zero);
      final saved = transactions.transactions.firstWhere((t) => t.title == 'Spotify' && t.amount == 12.5);
      expect(saved.type, TransactionType.expense);
      expect(saved.date.day, 1);
    });

    test('empty or zero amounts are refused with a message', () async {
      expect(await vm.save(''), isFalse);
      expect(vm.errorMessage, 'Үнийн дүнгээ оруулна уу');
      expect(await vm.save('0'), isFalse);
      expect(vm.errorMessage, 'Дүн 0-ээс их байх ёстой');
    });
  });

  group('ConnectWalletViewModel', () {
    late ConnectWalletViewModel vm;
    setUp(() async {
      final topUp = TopUpWalletService(walletRepo, transactionRepo, clock: () => now);
      vm = ConnectWalletViewModel(
        ListCardsService(walletRepo),
        AddCardService(walletRepo, topUp, clock: () => now),
        ConnectAccountService(walletRepo),
        topUp,
      );
      await vm.load();
    });

    test('shows the seeded card and defaults to Bank Link', () {
      expect(vm.cards.single.last4, '8075');
      expect(vm.selectedAccount, LinkedAccountType.bankLink);
    });

    test('adding a card puts it in front and tops up the balance', () async {
      final before = transactions.balance;
      final message = await vm.submitCardsForm(
        holderName: 'Bat Dorj',
        number: '4242 4242 4242 4242',
        cvc: '123',
        expiry: '2028/01',
        topUpText: '100',
      );
      expect(message, contains('4242'));
      expect(vm.cards.first.last4, '4242');
      await Future<void>.delayed(Duration.zero);
      expect(transactions.balance, closeTo(before + 100, 1e-9));
    });

    test('a bad card sets an error', () async {
      final message = await vm.submitCardsForm(holderName: 'Bat', number: '1234', cvc: '1', expiry: 'x', topUpText: '');
      expect(message, isNull);
      expect(vm.errorMessage, 'Картын дугаар буруу байна');
    });

    test('only Value filled tops up from the front card', () async {
      final before = transactions.balance;
      final message = await vm.submitCardsForm(holderName: '', number: '', cvc: '', expiry: '', topUpText: '50');
      expect(message, contains('8075'));
      await Future<void>.delayed(Duration.zero);
      expect(transactions.balance, closeTo(before + 50, 1e-9));
    });

    test('an empty form asks for input', () async {
      expect(await vm.submitCardsForm(holderName: '', number: '', cvc: '', expiry: '', topUpText: ''), isNull);
      expect(vm.errorMessage, isNotNull);
    });

    test('connecting an account remembers it', () async {
      vm.selectAccount(LinkedAccountType.paypal);
      expect(await vm.connectSelectedAccount(), isTrue);
      expect(await ConnectAccountService(walletRepo).current(), LinkedAccountType.paypal);
    });
  });
}
