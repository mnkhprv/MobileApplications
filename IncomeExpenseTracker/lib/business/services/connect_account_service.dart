import '../../domain/domain.dart';

/// Use case: link an outside account to the wallet
/// (Connect Wallet → "Аккаунт" tab: Bank Link, Microdeposits or Paypal).
class ConnectAccountService {
  ConnectAccountService(this._wallet);

  final WalletRepo _wallet;

  Future<void> execute(LinkedAccountType type) =>
      _wallet.saveLinkedAccount(type);

  /// The account linked earlier, or null if none yet.
  Future<LinkedAccountType?> current() => _wallet.findLinkedAccount();
}
