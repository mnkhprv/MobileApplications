import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:income_expense_tracker/business/services/pay_bill_service.dart';
import 'package:income_expense_tracker/domain/domain.dart';
import 'package:income_expense_tracker/infrastructure/repositories/firebase/firebase_auth_repo.dart';
import 'package:income_expense_tracker/infrastructure/repositories/firebase/firestore_repos.dart';

/// The Firebase adapters, run against in-memory fakes of Firebase Auth and
/// Cloud Firestore — no real project or network needed. Checks that data is
/// written where the security rules expect it (users/{uid}/...) and that it
/// round-trips back into the same entities.
void main() {
  final now = DateTime(2026, 11, 26, 9, 30);
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore db;
  late FirebaseAuthRepo authRepo;

  setUp(() {
    auth = MockFirebaseAuth();
    db = FakeFirebaseFirestore();
    authRepo = FirebaseAuthRepo(auth, db, clock: () => now);
  });

  Future<String> registerAndLogin() async {
    await authRepo.register(fullName: 'Бат Дорж', email: 'bat@mail.mn', password: 'secret1');
    final user = await authRepo.login(email: 'bat@mail.mn', password: 'secret1');
    return user.id;
  }

  group('FirebaseAuthRepo', () {
    test('register writes the profile and starter bills, then signs out', () async {
      await authRepo.register(fullName: 'Бат Дорж', email: 'bat@mail.mn', password: 'secret1');
      expect(auth.currentUser, isNull, reason: 'the user logs in next');

      final users = await db.collection('users').get();
      final profile = users.docs.single;
      expect(profile.data()['fullName'], 'Бат Дорж');
      expect(profile.data()['email'], 'bat@mail.mn');
      final bills = await profile.reference.collection('bills').get();
      expect(bills.docs.map((d) => d.data()['title']), contains('Youtube Premium'));
    });

    test('login returns the user with their name; logout clears the session', () async {
      final uid = await registerAndLogin();
      expect(authRepo.currentUser?.id, uid);
      expect(authRepo.currentUser?.fullName, 'Бат Дорж');
      await authRepo.logout();
      expect(authRepo.currentUser, isNull);
    });
  });

  group('Firestore repos', () {
    test('transactions are stored under the user and streamed back', () async {
      final uid = await registerAndLogin();
      final repo = FirestoreTransactionRepo(db, auth);
      await repo.save(Transaction(
        id: 't1',
        title: 'Түрийвч цэнэглэлт •4242',
        amount: 100,
        type: TransactionType.income,
        date: now,
        kind: TransactionKind.topUp,
      ));

      final stored = await db.collection('users').doc(uid).collection('transactions').doc('t1').get();
      expect(stored.data()!['kind'], 'topUp');

      final list = await repo.watchAll().first;
      expect(list.single.amount, 100);
      expect(list.single.kind, TransactionKind.topUp);
      expect(list.single.date, now);
    });

    test('watchAll reports "not signed in" through the stream', () async {
      expect(FirestoreTransactionRepo(db, auth).watchAll(), emitsError(isA<DomainException>()));
    });

    test('a paid bill stays paid after reloading', () async {
      await registerAndLogin();
      final bills = FirestoreBillRepo(db, auth);
      expect((await bills.findPending()).length, 4);

      final bill = (await bills.findById('bill-spotify'))!..markPaid();
      await bills.save(bill);

      expect((await bills.findPending()).map((b) => b.id), isNot(contains('bill-spotify')));
      final reloaded = (await bills.findById('bill-spotify'))!;
      expect(reloaded.isPaid, isTrue);
      expect(reloaded.markPaid, throwsA(isA<DomainException>()), reason: 'cannot pay twice');
    });

    test('cards store only the last 4 digits; linked account is remembered', () async {
      final uid = await registerAndLogin();
      final wallet = FirestoreWalletRepo(db, auth);
      final card = PaymentCard.create(
        id: 'c1',
        holderName: 'Bat Dorj',
        number: '4242 4242 4242 4242',
        cvc: '123',
        expiry: '2028/01',
        now: now,
      );
      await wallet.saveCard(card);

      final stored = (await db.collection('users').doc(uid).collection('cards').doc('c1').get()).data()!;
      expect(stored['last4'], '4242');
      expect(stored.values.join(' '), isNot(contains('4242424242424242')));
      expect(stored.containsKey('cvc'), isFalse);

      expect((await wallet.findCards()).single.holderName, 'Bat Dorj');
      await wallet.saveLinkedAccount(LinkedAccountType.paypal);
      expect(await wallet.findLinkedAccount(), LinkedAccountType.paypal);
    });

    test('paying a bill end to end: receipt saved and found by number', () async {
      await registerAndLogin();
      final transactions = FirestoreTransactionRepo(db, auth);
      final wallet = FirestoreWalletRepo(db, auth);
      final receipts = FirestoreReceiptRepo(db, auth);
      await wallet.saveCard(PaymentCard(id: 'c1', holderName: 'Bat', last4: '4242', expiryYear: 2028, expiryMonth: 1));

      final receipt = await PayBillService(FirestoreBillRepo(db, auth), transactions, wallet, receipts, clock: () => now)
          .execute('bill-youtube', PaymentMethod.debitCard);

      final loaded = (await receipts.findByNumber(receipt.number))!;
      expect(loaded.billTitle, 'Youtube Premium');
      expect(loaded.total, closeTo(13.98, 1e-9));
      expect(loaded.method, PaymentMethod.debitCard);
      final expense = (await transactions.watchAll().first).single;
      expect(expense.receiptNumber, receipt.number);
    });

    test("one user's data is invisible to another", () async {
      await registerAndLogin();
      await FirestoreTransactionRepo(db, auth).save(Transaction(
        id: 't1',
        title: 'Хоол',
        amount: 10,
        type: TransactionType.expense,
        date: now,
      ));
      await authRepo.logout();

      await authRepo.register(fullName: 'Болд', email: 'bold@mail.mn', password: 'secret1');
      await authRepo.login(email: 'bold@mail.mn', password: 'secret1');
      expect(await FirestoreTransactionRepo(db, auth).watchAll().first, isEmpty);
    });
  });
}
