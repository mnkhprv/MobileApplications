import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'business/services/add_card_service.dart';
import 'business/services/add_transaction_service.dart';
import 'business/services/connect_account_service.dart';
import 'business/services/get_receipt_service.dart';
import 'business/services/list_cards_service.dart';
import 'business/services/list_pending_bills_service.dart';
import 'business/services/list_transactions_service.dart';
import 'business/services/login_service.dart';
import 'business/services/pay_bill_service.dart';
import 'business/services/register_service.dart';
import 'business/services/top_up_wallet_service.dart';
import 'domain/domain.dart';
import 'firebase_options.dart';
import 'infrastructure/repositories/firebase/firebase_auth_repo.dart';
import 'infrastructure/repositories/firebase/firestore_repos.dart';
import 'infrastructure/repositories/in_memory/in_memory_repos.dart';
import 'infrastructure/repositories/in_memory/seed.dart';
import 'presentation/core/theme.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/transaction_viewmodel.dart';
import 'presentation/viewmodels/wallet_viewmodel.dart';
import 'presentation/views/screens/add_expense_screen.dart';
import 'presentation/views/screens/connect_wallet_screen.dart';
import 'presentation/views/screens/home_screen.dart';
import 'presentation/views/screens/login_screen.dart';
import 'presentation/views/screens/onboarding_screen.dart';
import 'presentation/views/screens/register_screen.dart';
import 'presentation/views/screens/splash_screen.dart';
import 'presentation/views/screens/wallet_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Usually: `flutterfire configure` has not been run yet.
    runApp(_FirebaseSetupNeeded(error: '$e'));
    return;
  }
  runApp(
    MultiProvider(
      providers: buildDependencies(),
      child: const IncomeExpenseApp(),
    ),
  );
}

/// Which adapters to plug into the ports.
/// The app uses Firebase; tests and offline demos use memory.
enum Backend { firebase, inMemory }

/// Composition root — the only place that knows every layer.
/// Same steps, in the same order, as `main.ts` in the course's library system.
///
/// Switching [backend] swaps *only* step 1. Steps 3 and 4 are identical for
/// both, because services and ViewModels depend on ports, not on Firebase.
List<SingleChildWidget> buildDependencies({
  Backend backend = Backend.firebase,
  DateTime Function()? clock,
}) {
  final now = clock ?? DateTime.now;

  // 1. Infrastructure (adapters for the domain ports)
  final AuthRepo authRepo;
  final TransactionRepo transactionRepo;
  final BillRepo billRepo;
  final WalletRepo walletRepo;
  final ReceiptRepo receiptRepo;
  switch (backend) {
    case Backend.firebase:
      final auth = fb.FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;
      authRepo = FirebaseAuthRepo(auth, db, clock: now);
      transactionRepo = FirestoreTransactionRepo(db, auth);
      billRepo = FirestoreBillRepo(db, auth);
      walletRepo = FirestoreWalletRepo(db, auth);
      receiptRepo = FirestoreReceiptRepo(db, auth);
    case Backend.inMemory:
      final transactions = InMemoryTransactionRepo();
      final bills = InMemoryBillRepo();
      final wallet = InMemoryWalletRepo();
      // 2. Seed data (Firebase accounts get their starter bills on sign-up)
      seedDemoData(
        transactions: transactions,
        bills: bills,
        wallet: wallet,
        now: now(),
      );
      authRepo = InMemoryAuthRepo();
      transactionRepo = transactions;
      billRepo = bills;
      walletRepo = wallet;
      receiptRepo = InMemoryReceiptRepo();
  }

  // 3. Business layer (use cases)
  final register = RegisterService(authRepo);
  final login = LoginService(authRepo);
  final listTransactions = ListTransactionsService(transactionRepo);
  final addTransaction = AddTransactionService(transactionRepo);
  final listPendingBills = ListPendingBillsService(billRepo);
  final payBill = PayBillService(
    billRepo,
    transactionRepo,
    walletRepo,
    receiptRepo,
    clock: now,
  );
  final getReceipt = GetReceiptService(receiptRepo);
  final topUp = TopUpWalletService(walletRepo, transactionRepo, clock: now);
  final listCards = ListCardsService(walletRepo);
  final addCard = AddCardService(walletRepo, topUp, clock: now);
  final connectAccount = ConnectAccountService(walletRepo);

  // 4. Presentation layer
  return [
    // App-wide ViewModels the screens watch.
    ChangeNotifierProvider(create: (_) => AuthViewModel(register, login)),
    ChangeNotifierProvider(
      create: (_) => TransactionViewModel(listTransactions, addTransaction),
    ),
    ChangeNotifierProvider(create: (_) => WalletViewModel(listPendingBills)),
    // Use cases for flows that create their own short-lived ViewModel
    // (Add Expense, Connect Wallet, the bill flow, receipts).
    Provider.value(value: addTransaction),
    Provider.value(value: payBill),
    Provider.value(value: getReceipt),
    Provider.value(value: topUp),
    Provider.value(value: listCards),
    Provider.value(value: addCard),
    Provider.value(value: connectAccount),
  ];
}

/// Хувь хүний орлого, зарлагыг хянах апп.
/// Splash → Onboarding → Register → Login → Home → Wallet →
/// Add Expense / Connect Wallet / Bill Details → Bill Payment.
class IncomeExpenseApp extends StatelessWidget {
  const IncomeExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Орлого, зарлага',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        OnboardingScreen.route: (_) => const OnboardingScreen(),
        RegisterScreen.route: (_) => const RegisterScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
        WalletScreen.route: (_) => const WalletScreen(),
        AddExpenseScreen.route: (_) => AddExpenseScreen.create(),
        ConnectWalletScreen.route: (_) => ConnectWalletScreen.create(),
      },
    );
  }
}

/// Shown instead of the app when Firebase could not start — usually because
/// `flutterfire configure` has not been run for this project yet.
class _FirebaseSetupNeeded extends StatelessWidget {
  const _FirebaseSetupNeeded({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Firebase тохируулагдаагүй байна',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Төслийн хавтаст дараахыг ажиллуулна уу:\n\n'
                  'dart pub global activate flutterfire_cli\n'
                  'flutterfire configure',
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
