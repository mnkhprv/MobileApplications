import '../entity/payment_card.dart';

/// Port: what the business layer needs to remember about the wallet's
/// linked cards and linked outside account.
abstract class WalletRepo {
  Future<List<PaymentCard>> findCards();
  Future<void> saveCard(PaymentCard card);

  Future<LinkedAccountType?> findLinkedAccount();
  Future<void> saveLinkedAccount(LinkedAccountType type);
}
