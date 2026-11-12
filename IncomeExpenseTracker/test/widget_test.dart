import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/main.dart';
import 'package:income_expense_tracker/services/auth_service.dart';
import 'package:income_expense_tracker/services/transaction_service.dart';
import 'package:income_expense_tracker/viewmodels/auth_viewmodel.dart';
import 'package:income_expense_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';

Widget buildApp() => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(InMemoryAuthService())),
        ChangeNotifierProvider(create: (_) => TransactionViewModel(InMemoryTransactionService())),
      ],
      child: const IncomeExpenseApp(),
    );

void main() {
  testWidgets('Splash → Onboarding → Register → Login → Home', (tester) async {
    // Phone-sized screen from the Figma frames (414 x 896).
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp());
    expect(find.text('Сайн уу?'), findsOneWidget);

    // Splash moves on by itself after 2 seconds.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Эхлэх'), findsOneWidget);

    await tester.tap(find.text('Эхлэх'));
    await tester.pumpAndSettle();
    expect(find.text('Бүтэн нэрээ оруулна уу?'), findsOneWidget);

    // Empty form shows validation errors instead of continuing.
    await tester.tap(find.widgetWithText(InkWell, 'Бүртгүүлэх'));
    await tester.pumpAndSettle();
    expect(find.text('Заавал бөглөнө үү'), findsWidgets);

    // Fill in and register.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Н.Даваа');
    await tester.enterText(fields.at(1), 'davaa@mail.mn');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.widgetWithText(InkWell, 'Бүртгүүлэх'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address'), findsOneWidget);

    // Log in → home shows the user's name and the transaction history.
    await tester.enterText(find.byType(TextFormField).at(0), 'davaa@mail.mn');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.widgetWithText(InkWell, 'Нэвтрэх'));
    await tester.pumpAndSettle();

    expect(find.text('Н.Даваа'), findsOneWidget);
    expect(find.text('Гүйлгээний Түүх'), findsOneWidget);
    expect(find.text('Upwork'), findsOneWidget);
    expect(find.text('+ \$ 850.00'), findsOneWidget);
    // Totals are computed from the four seeded transactions.
    expect(find.text('\$ 2,159.01'), findsOneWidget); // balance
    expect(find.text('\$ 2,256.00'), findsOneWidget); // income
    expect(find.text('\$ 96.99'), findsOneWidget); // expense
  });
}
