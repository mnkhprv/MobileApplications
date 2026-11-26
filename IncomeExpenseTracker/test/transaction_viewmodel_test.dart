import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/business/services/add_transaction_service.dart';
import 'package:income_expense_tracker/business/services/list_transactions_service.dart';
import 'package:income_expense_tracker/domain/domain.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/in_memory_repos.dart';
import 'package:income_expense_tracker/infrastructure/repositories/in_memory/seed.dart';
import 'package:income_expense_tracker/presentation/core/formatters.dart';
import 'package:income_expense_tracker/presentation/viewmodels/transaction_viewmodel.dart';

void main() {
  group('TransactionViewModel', () {
    late TransactionViewModel vm;

    setUp(() {
      final repo = InMemoryTransactionRepo();
      seedDemoData(transactions: repo, bills: InMemoryBillRepo(), now: DateTime.now());
      vm = TransactionViewModel(ListTransactionsService(repo), AddTransactionService(repo));
    });

    tearDown(() => vm.dispose());

    test('loads seed data newest first and computes totals', () async {
      await vm.load();
      expect(vm.transactions.map((t) => t.title), ['Upwork', 'Шилжүүлэг', 'Paypal', 'Youtube']);
      expect(vm.totalIncome, 2256);
      expect(vm.totalExpense, closeTo(96.99, 1e-9));
      expect(vm.balance, closeTo(2159.01, 1e-9));
    });

    test('adding an expense updates the list and totals through the stream', () async {
      await vm.load();
      expect(
        await vm.add(Transaction(
          id: 'new',
          title: 'Хоол',
          amount: 20,
          type: TransactionType.expense,
          date: DateTime.now().add(const Duration(minutes: 1)),
        )),
        isTrue,
      );
      await Future<void>.delayed(Duration.zero); // let the stream deliver
      expect(vm.transactions.first.title, 'Хоол');
      expect(vm.totalExpense, closeTo(116.99, 1e-9));
    });

    test('a rejected transaction sets an error and changes nothing', () async {
      await vm.load();
      final ok = await vm.add(Transaction(
        id: 'bad',
        title: 'Хоол',
        amount: 0,
        type: TransactionType.expense,
        date: DateTime.now(),
      ));
      expect(ok, isFalse);
      expect(vm.errorMessage, 'Дүн 0-ээс их байх ёстой');
      expect(vm.transactions, hasLength(4));
    });
  });

  group('Formatters', () {
    test('money', () {
      expect(Formatters.money(2548), '\$ 2,548.00');
      expect(Formatters.money(11.99), '\$ 11.99');
    });

    test('relative date', () {
      final now = DateTime(2026, 11, 12, 10);
      expect(Formatters.relativeDate(DateTime(2026, 11, 12, 1), now: now), 'Өнөөдөр');
      expect(Formatters.relativeDate(DateTime(2026, 11, 11, 23), now: now), 'Өчигдөр');
      expect(Formatters.relativeDate(DateTime(2022, 1, 30), now: now), 'Jan 30, 2022');
    });

    test('greeting by hour', () {
      expect(Formatters.greeting(DateTime(2026, 1, 1, 8)), 'Өглөөний мэнд');
      expect(Formatters.greeting(DateTime(2026, 1, 1, 14)), 'Өдрийн мэнд');
      expect(Formatters.greeting(DateTime(2026, 1, 1, 21)), 'Оройн мэнд');
    });
  });
}
