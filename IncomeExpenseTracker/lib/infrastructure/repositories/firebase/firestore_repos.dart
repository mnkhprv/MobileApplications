import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../domain/domain.dart';
import 'firestore_mappers.dart';

/// Adapters: the ports from `domain/port/`, implemented with Cloud Firestore.
///
/// Every user's data lives under their own document, so security rules can
/// allow each user to read and write only their own data:
///
/// ```
/// users/{uid}                      fullName, email, createdAt, linkedAccount
/// users/{uid}/transactions/{id}    income & expense history (incl. top-ups)
/// users/{uid}/bills/{id}           pending and paid bills
/// users/{uid}/cards/{id}           linked cards (last 4 digits only)
/// users/{uid}/receipts/{number}    payment receipts
/// ```
abstract class _UserScoped {
  _UserScoped(this._db, this._auth);

  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _user {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const DomainException('Нэвтэрч орно уу');
    return _db.collection('users').doc(uid);
  }

  /// Firestore errors (offline, permission) → a readable domain error.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw DomainException(
        e.code == 'permission-denied'
            ? 'Firestore хандах эрхгүй байна (security rules-ээ шалгана уу)'
            : 'Өгөгдлийн сантай холбогдож чадсангүй (${e.code})',
      );
    }
  }
}

class FirestoreTransactionRepo extends _UserScoped implements TransactionRepo {
  FirestoreTransactionRepo(super.db, super.auth);

  CollectionReference<Map<String, dynamic>> get _col =>
      _user.collection('transactions');

  /// Live: Firestore pushes a new snapshot after every change, including
  /// changes made on another device.
  @override
  Stream<List<Transaction>> watchAll() {
    final CollectionReference<Map<String, dynamic>> col;
    try {
      col = _col;
    } on DomainException catch (e) {
      return Stream.error(e); // not signed in: report through the stream
    }
    return col
        .snapshots()
        .map(
          (snap) => snap.docs.map(transactionFromDoc).toList(growable: false),
        )
        .handleError(
          (Object e) => throw DomainException('Гүйлгээ ачаалж чадсангүй ($e)'),
          test: (e) => e is FirebaseException,
        );
  }

  @override
  Future<void> save(Transaction transaction) =>
      _guard(() => _col.doc(transaction.id).set(transactionToMap(transaction)));
}

class FirestoreBillRepo extends _UserScoped implements BillRepo {
  FirestoreBillRepo(super.db, super.auth);

  CollectionReference<Map<String, dynamic>> get _col =>
      _user.collection('bills');

  @override
  Future<List<Bill>> findPending() => _guard(() async {
    final snap = await _col.where('isPaid', isEqualTo: false).get();
    return snap.docs.map(billFromDoc).toList(growable: false);
  });

  @override
  Future<Bill?> findById(String id) => _guard(() async {
    final doc = await _col.doc(id).get();
    return doc.exists ? billFromDoc(doc) : null;
  });

  @override
  Future<void> save(Bill bill) =>
      _guard(() => _col.doc(bill.id).set(billToMap(bill)));
}

class FirestoreWalletRepo extends _UserScoped implements WalletRepo {
  FirestoreWalletRepo(super.db, super.auth);

  CollectionReference<Map<String, dynamic>> get _cards =>
      _user.collection('cards');

  @override
  Future<List<PaymentCard>> findCards() => _guard(() async {
    final snap = await _cards.orderBy('addedAt').get();
    return snap.docs.map(cardFromDoc).toList(growable: false);
  });

  @override
  Future<void> saveCard(PaymentCard card) =>
      _guard(() => _cards.doc(card.id).set(cardToMap(card)));

  @override
  Future<LinkedAccountType?> findLinkedAccount() => _guard(() async {
    final name = (await _user.get()).data()?['linkedAccount'] as String?;
    return name == null ? null : LinkedAccountType.values.asNameMap()[name];
  });

  @override
  Future<void> saveLinkedAccount(LinkedAccountType type) => _guard(
    () => _user.set({'linkedAccount': type.name}, SetOptions(merge: true)),
  );
}

class FirestoreReceiptRepo extends _UserScoped implements ReceiptRepo {
  FirestoreReceiptRepo(super.db, super.auth);

  CollectionReference<Map<String, dynamic>> get _col =>
      _user.collection('receipts');

  @override
  Future<void> save(BillReceipt receipt) =>
      _guard(() => _col.doc(receipt.number).set(receiptToMap(receipt)));

  @override
  Future<BillReceipt?> findByNumber(String number) => _guard(() async {
    final doc = await _col.doc(number).get();
    return doc.exists ? receiptFromDoc(doc) : null;
  });
}
