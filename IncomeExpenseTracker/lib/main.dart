import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/onboarding_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/splash_screen.dart';

void main() {
  runApp(
    // ViewModels are created once here and shared with every screen below.
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => InMemoryAuthService()),
        Provider<TransactionService>(create: (_) => InMemoryTransactionService()),
        ChangeNotifierProvider(create: (context) => AuthViewModel(context.read<AuthService>())),
        ChangeNotifierProvider(
          create: (context) => TransactionViewModel(context.read<TransactionService>()),
        ),
      ],
      child: const IncomeExpenseApp(),
    ),
  );
}

/// Хувь хүний орлого, зарлагыг хянах апп.
/// Splash → Onboarding → Register → Login → Home.
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
      },
    );
  }
}
