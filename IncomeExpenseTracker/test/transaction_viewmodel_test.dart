import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/core/formatters.dart';
import 'package:income_expense_tracker/models/transaction.dart';
import 'package:income_expense_tracker/services/transaction_service.dart';
import 'package:income_expense_tracker/viewmodels/transaction_viewmodel.dart';

void main() {
  group('TransactionViewModel', () {
    late TransactionViewModel vm;

    setUp(() => vm = TransactionViewModel(InMemoryTransactionService()));

    test('loads seed data newest first and computes totals', () async {
      await vm.load();
      expect(vm.transactions.map((t) => t.title), ['Upwork', 'Шилжүүлэг', 'Paypal', 'Youtube']);
      expect(vm.totalIncome, 2256);
      expect(vm.totalExpense, closeTo(96.99, 1e-9));
      expect(vm.balance, closeTo(2159.01, 1e-9));
    });

    test('adding an expense updates the list and totals', () async {
      await vm.load();
      await vm.add(Transaction(
        id: 'new',
        title: 'Хоол',
        amount: 20,
        type: TransactionType.expense,
        date: DateTime.now().add(const Duration(minutes: 1)),
      ));
      expect(vm.transactions.first.title, 'Хоол');
      expect(vm.totalExpense, closeTo(116.99, 1e-9));
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
