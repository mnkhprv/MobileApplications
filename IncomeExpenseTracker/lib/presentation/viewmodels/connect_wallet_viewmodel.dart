import 'package:flutter/foundation.dart';

import '../../business/services/add_card_service.dart';
import '../../business/services/connect_account_service.dart';
import '../../business/services/list_cards_service.dart';
import '../../business/services/top_up_wallet_service.dart';
import '../../domain/domain.dart';

/// The two tabs on Connect Wallet (Figma frames 1:2736 and 1:2887).
enum ConnectTab { cards, account }

/// ViewModel for Connect Wallet: linked cards, the add-card form submit,
/// and choosing an outside account. Rules live in the services/entities.
class ConnectWalletViewModel extends ChangeNotifier {
  ConnectWalletViewModel(
    this._listCards,
    this._addCard,
    this._connectAccount,
    this._topUp,
  );

  final ListCardsService _listCards;
  final AddCardService _addCard;
  final ConnectAccountService _connectAccount;
  final TopUpWalletService _topUp;

  ConnectTab _tab = ConnectTab.cards;
  List<PaymentCard> _cards = const [];
  LinkedAccountType _selectedAccount = LinkedAccountType.bankLink;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  ConnectTab get tab => _tab;

  /// Newest first — `cards.first` is drawn in front.
  List<PaymentCard> get cards => _cards;
  LinkedAccountType get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void selectTab(ConnectTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    _errorMessage = null;
    notifyListeners();
  }

  void selectAccount(LinkedAccountType type) {
    _selectedAccount = type;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cards = await _listCards.execute();
      _selectedAccount = await _connectAccount.current() ?? _selectedAccount;
    } on DomainException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// The "Картууд" form. Two ways to use it:
  /// - card fields filled → link that card (and top up if Value is filled);
  /// - only Value filled → top up from the newest linked card.
  /// Returns a success message, or null with [errorMessage] set.
  Future<String?> submitCardsForm({
    required String holderName,
    required String number,
    required String cvc,
    required String expiry,
    required String topUpText,
  }) async {
    double? topUp;
    final cleaned = topUpText
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isNotEmpty) {
      topUp = double.tryParse(cleaned);
      if (topUp == null) return _fail('Цэнэглэх дүн буруу байна');
    }

    final cardFieldsEmpty = [
      holderName,
      number,
      cvc,
      expiry,
    ].every((f) => f.trim().isEmpty);
    if (cardFieldsEmpty) {
      if (topUp == null) {
        return _fail('Картын мэдээлэл эсвэл цэнэглэх дүнгээ оруулна уу');
      }
      if (_cards.isEmpty) return _fail('Эхлээд карт холбоно уу');
      final card = _cards.first;
      return _submit(() async {
        await _topUp.execute(cardId: card.id, amount: topUp!);
        return 'Түрийвч •${card.last4} картаас цэнэглэгдлээ';
      });
    }

    return _submit(() async {
      final card = await _addCard.execute(
        holderName: holderName,
        number: number,
        cvc: cvc,
        expiry: expiry,
        topUp: topUp,
      );
      _cards = await _listCards.execute();
      return topUp == null
          ? 'Карт •${card.last4} холбогдлоо'
          : 'Карт •${card.last4} холбогдож, түрийвч цэнэглэгдлээ';
    });
  }

  /// Returns true on success, false with [errorMessage] set.
  Future<bool> connectSelectedAccount() async =>
      await _submit(() async {
        await _connectAccount.execute(_selectedAccount);
        return true;
      }) ??
      false;

  Future<T?> _submit<T>(Future<T> Function() action) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } on DomainException catch (e) {
      _errorMessage = e.message;
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  T? _fail<T>(String message) {
    _errorMessage = message;
    notifyListeners();
    return null;
  }
}
