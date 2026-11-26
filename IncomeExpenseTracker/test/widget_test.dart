import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/main.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Same wiring as the real app (main.dart's composition root).
Widget buildApp() => MultiProvider(
      providers: buildDependencies(backend: Backend.inMemory),
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

    // Wallet tab in the bottom bar → screen 6 (transactions tab).
    await tester.tap(find.bySemanticsLabel('wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвч'), findsOneWidget);
    expect(find.text('\$ 2,159.01'), findsOneWidget);
    expect(find.text('Upwork'), findsOneWidget);

    // Earlier snackbars would sit over the bottom buttons (they time out
    // after 4 s in the app; the test clock doesn't run that long).
    void clearSnackBars() =>
        tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).clearSnackBars();
    clearSnackBars();

    // Screen 7 (pending bills) → tap the first bill (Youtube Premium).
    await tester.tap(find.text('Хүлээгдэж буй гүйлгээ'));
    await tester.pumpAndSettle();
    expect(find.text('Youtube Premium'), findsOneWidget);
    expect(find.text('Цахилгаан'), findsOneWidget);
    await tester.tap(find.text('Төлөх').first);
    await tester.pumpAndSettle();

    // Bill Details: price, fee, total, payment method.
    expect(find.text('Bill Details'), findsOneWidget);
    expect(find.text('\$ 11.99'), findsOneWidget);
    expect(find.text('\$ 1.99'), findsOneWidget);
    expect(find.text('\$ 13.98'), findsOneWidget);
    expect(find.text('Дебит карт'), findsOneWidget);
    await tester.tap(find.text('Төлөх'));
    await tester.pumpAndSettle();

    // Bill Payment (confirm) → Баталгаажуулах → receipt.
    expect(find.text('Баталгаажуулах'), findsOneWidget);
    await tester.tap(find.text('Баталгаажуулах'));
    await tester.pumpAndSettle();
    expect(find.text('Амжилттай Төлөгдлөө'), findsOneWidget);
    expect(find.text('Хийгдсэн'), findsOneWidget);
    expect(find.text('Дебит карт'), findsOneWidget);

    // Back from the receipt goes straight to Wallet; the bill is gone and
    // the balance dropped by the total (11.99 + 1.99).
    await tester.tap(find.bySemanticsLabel('Буцах'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвч'), findsOneWidget);
    expect(find.text('Youtube Premium'), findsNothing);
    expect(find.text('\$ 2,145.03'), findsOneWidget);

    // The receipt was saved: tapping the payment in the history reopens it,
    // with its QR code.
    await tester.tap(find.text('Гүйлгээнүүд'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Youtube Premium').first);
    await tester.pumpAndSettle();
    expect(find.text('Амжилттай Төлөгдлөө'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Буцах'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвч'), findsOneWidget);

    clearSnackBars();
    // Нэмэх → Add Expense: 20 for Netflix.
    await tester.tap(find.bySemanticsLabel('Нэмэх'));
    await tester.pumpAndSettle();
    expect(find.text('ҮНИЙН ДҮН'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '20');
    await tester.tap(find.widgetWithText(InkWell, 'Төлбөр нэмэх'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвч'), findsOneWidget);
    expect(find.text('\$ 2,125.03'), findsOneWidget);

    clearSnackBars();
    // Төлбөр → Connect Wallet: link a card and top up 100.
    await tester.tap(find.bySemanticsLabel('Төлбөр'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвч цэнэглэх'), findsOneWidget);
    expect(find.text('IRVAN MOSES'), findsOneWidget); // seeded card in front
    final cardFields = find.byType(TextField);
    await tester.enterText(cardFields.at(0), 'Bat Dorj');
    await tester.enterText(cardFields.at(1), '4242424242424242');
    await tester.enterText(cardFields.at(2), '123');
    await tester.enterText(cardFields.at(3), '202801');
    await tester.enterText(cardFields.at(4), '100');
    await tester.pump();
    expect(find.text('BAT DORJ'), findsOneWidget); // live preview
    await tester.ensureVisible(find.text('ИЛГЭЭХ'));
    await tester.tap(find.text('ИЛГЭЭХ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Карт •4242'), findsOneWidget);

    clearSnackBars();
    // Аккаунт tab → pick Paypal → ДАРААХ returns to Wallet with the top-up.
    await tester.tap(find.text('Аккаунт'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвчтэй холбох'), findsOneWidget);
    await tester.tap(find.text('Paypal'));
    await tester.tap(find.text('ДАРААХ'));
    await tester.pumpAndSettle();
    expect(find.text('Түрийвч'), findsOneWidget);
    expect(find.text('\$ 2,225.03'), findsOneWidget);
  });
}
