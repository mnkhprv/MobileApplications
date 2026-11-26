import '../../domain/domain.dart';

/// Use case: the cards linked to the wallet, newest first
/// (the newest is the one drawn in front on Connect Wallet).
class ListCardsService {
  ListCardsService(this._wallet);

  final WalletRepo _wallet;

  Future<List<PaymentCard>> execute() async =>
      (await _wallet.findCards()).reversed.toList();
}
