import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/wallet_viewmodel.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/wallet_screen.dart';
import 'widgets/home_bottom_nav.dart';

/// Bottom-bar navigation shared by every screen.
///
/// - Home: go back to the Home route.
/// - Wallet: go back to Wallet if it is already open underneath,
///   otherwise open it on top of Home.
/// - Profile: sign out (asks first).
/// - Stats: not built yet.
void goToTab(BuildContext context, HomeTab tab) {
  final navigator = Navigator.of(context);
  switch (tab) {
    case HomeTab.home:
      navigator.popUntil(
        (r) => r.settings.name == HomeScreen.route || r.isFirst,
      );
    case HomeTab.wallet:
      var foundWallet = false;
      navigator.popUntil((r) {
        if (r.settings.name == WalletScreen.route) foundWallet = true;
        return foundWallet || r.settings.name == HomeScreen.route || r.isFirst;
      });
      if (!foundWallet) navigator.pushNamed(WalletScreen.route);
    case HomeTab.profile:
      _confirmLogout(context);
    case HomeTab.stats:
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Удахгүй нэмэгдэнэ')));
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  final auth = context.read<AuthViewModel>();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(auth.currentUser?.fullName ?? 'Профайл'),
      content: Text('${auth.currentUser?.email ?? ''}\n\nАппаас гарах уу?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Болих'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Гарах'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final transactions = context.read<TransactionViewModel>();
  final wallet = context.read<WalletViewModel>();
  final navigator = Navigator.of(context);
  await auth.logout();
  // Forget the previous user's data before anyone else signs in.
  transactions.reset();
  wallet.reset();
  navigator.pushNamedAndRemoveUntil(LoginScreen.route, (_) => false);
}
