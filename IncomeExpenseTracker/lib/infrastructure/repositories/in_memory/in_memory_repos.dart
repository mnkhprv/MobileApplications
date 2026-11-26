import 'dart:async';

import '../../../domain/domain.dart';

/// Adapters: the ports from `domain/port/`, implemented with plain memory.
/// Same role as `InMemoryRepos.ts` in the course. Used by the tests; the app
/// uses the Firebase adapters in `../firebase/`. Both implement the same
/// ports, so `business/` and `presentation/` never change (Open-Closed).

/// Small fake delay so loading spinners are visible, like a real database.
Future<void> _io([int ms = 200]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

/// Auth for tests and offline demos. Passwords stay inside this adapter —
/// the domain never sees them (Firebase Auth plays this role in the app).
class InMemoryAuthRepo implements AuthRepo {
  final Map<String, ({User user, String password})> _byEmail = {};
  User? _current;

  static String _key(String email) => email.trim().toLowerCase();

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _io(400);
    final key = _key(email);
    if (_byEmail.containsKey(key)) {
      throw const DomainException('Энэ имэйлээр бүртгэл үүссэн байна');
    }
    _byEmail[key] = (
      user: User(
        id: 'user-${_byEmail.length + 1}',
        fullName: fullName,
        email: email,
      ),
      password: password,
    );
  }

  @override
  Future<User> login({required String email, required String password}) async {
    await _io(400);
    final account = _byEmail[_key(email)];
    if (account == null || account.password != password) {
      throw const DomainException('Имэйл эсвэл нууц үг буруу байна');
    }
    return _current = account.user;
  }

  @override
  Future<void> logout() async => _current = null;

  @override
  User? get currentUser => _current;
}

class InMemoryReceiptRepo implements ReceiptRepo {
  final Map<String, BillReceipt> _byNumber = {};

  @override
  Future<void> save(BillReceipt receipt) async =>
      _byNumber[receipt.number] = receipt;

  @override
  Future<BillReceipt?> findByNumber(String number) async {
    await _io();
    return _byNumber[number];
  }
}

class InMemoryTransactionRepo implements TransactionRepo {
  final List<Transaction> _items = [];
  final _changes = StreamController<List<Transaction>>.broadcast();

  void seed(Transaction transaction) => _items.add(transaction);

  List<Transaction> get _snapshot => List.unmodifiable(_items);

  @override
  Stream<List<Transaction>> watchAll() {
    // Subscribe to changes *before* the first (delayed) snapshot is sent, so
    // a save made right after listening is never missed. Every event is the
    // full current list, so receiving one twice is harmless.
    StreamSubscription<List<Transaction>>? changes;
    late final StreamController<List<Transaction>> out;
    out = StreamController<List<Transaction>>(
      onListen: () {
        changes = _changes.stream.listen(out.add);
        _io().then((_) {
          if (!out.isClosed) out.add(_snapshot);
        });
      },
      onCancel: () async {
        await changes?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }

  @override
  Future<void> save(Transaction transaction) async {
    _items.add(transaction);
    _changes.add(_snapshot);
  }
}

class InMemoryBillRepo implements BillRepo {
  final Map<String, Bill> _byId = {};

  void seed(Bill bill) => _byId[bill.id] = bill;

  @override
  Future<List<Bill>> findPending() async {
    await _io();
    return _byId.values.where((b) => !b.isPaid).toList(growable: false);
  }

  @override
  Future<Bill?> findById(String id) async => _byId[id];

  @override
  Future<void> save(Bill bill) async {
    await _io(300);
    _byId[bill.id] = bill;
  }
}

class InMemoryWalletRepo implements WalletRepo {
  final List<PaymentCard> _cards = [];
  LinkedAccountType? _linkedAccount;

  void seed(PaymentCard card) => _cards.add(card);

  @override
  Future<List<PaymentCard>> findCards() async {
    await _io();
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> saveCard(PaymentCard card) async {
    await _io(300);
    _cards.add(card);
  }

  @override
  Future<LinkedAccountType?> findLinkedAccount() async => _linkedAccount;

  @override
  Future<void> saveLinkedAccount(LinkedAccountType type) async {
    await _io(300);
    _linkedAccount = type;
  }
}
