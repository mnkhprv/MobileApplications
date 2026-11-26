import '../../domain/domain.dart';
import 'top_up_wallet_service.dart';

/// Use case: link a debit card to the wallet, optionally topping the wallet
/// up from it straight away.
///
/// The card's own rules (number, CVC, expiry) are checked by
/// [PaymentCard.create]. The top-up rules belong to [TopUpWalletService],
/// which this service reuses — like `TaskService` uses `StudentService` in
/// the course. The top-up amount is checked *before* the card is saved, so a
/// bad amount leaves nothing half-done.
class AddCardService {
  AddCardService(this._wallet, this._topUp, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WalletRepo _wallet;
  final TopUpWalletService _topUp;
  final DateTime Function() _clock;

  Future<PaymentCard> execute({
    required String holderName,
    required String number,
    required String cvc,
    required String expiry,
    double? topUp,
  }) async {
    final now = _clock();
    final card = PaymentCard.create(
      id: 'card-${now.microsecondsSinceEpoch}',
      holderName: holderName,
      number: number,
      cvc: cvc,
      expiry: expiry,
      now: now,
    );
    if (topUp != null && topUp <= 0) {
      throw const DomainException('Цэнэглэх дүн 0-ээс их байх ёстой');
    }

    await _wallet.saveCard(card);
    if (topUp != null) await _topUp.execute(cardId: card.id, amount: topUp);
    return card;
  }
}
