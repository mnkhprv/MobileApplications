import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../domain/domain.dart';
import '../starter_bills.dart';
import 'firestore_mappers.dart';

/// Adapter: [AuthRepo] backed by Firebase Authentication (e-mail + password).
///
/// On registration it also creates the user's profile document
/// `users/{uid}` and their starter bills in Firestore, then signs out so the
/// user logs in next (the Register → Login flow from the design).
class FirebaseAuthRepo implements AuthRepo {
  FirebaseAuthRepo(this._auth, this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final DateTime Function() _clock;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user!;
      await fbUser.updateDisplayName(fullName);

      final now = _clock();
      final userDoc = _db.collection('users').doc(fbUser.uid);
      final batch = _db.batch()
        ..set(userDoc, {
          'fullName': fullName,
          'email': email,
          'createdAt': Timestamp.fromDate(now),
        });
      for (final bill in starterBills(now)) {
        batch.set(userDoc.collection('bills').doc(bill.id), billToMap(bill));
      }
      await batch.commit();
    } on fb.FirebaseAuthException catch (e) {
      throw DomainException(_message(e));
    } on FirebaseException catch (e) {
      // The account exists but the profile/bills could not be written —
      // usually Firestore is not created yet or the rules deny it.
      throw DomainException(
        'Бүртгэл үүссэн ч өгөгдөл хадгалж чадсангүй (${e.code})',
      );
    } finally {
      await _auth.signOut();
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user!;
      var name = fbUser.displayName;
      if (name == null || name.isEmpty) {
        final profile = await _db.collection('users').doc(fbUser.uid).get();
        name = profile.data()?['fullName'] as String? ?? '';
      }
      return User(id: fbUser.uid, fullName: name, email: fbUser.email ?? email);
    } on fb.FirebaseAuthException catch (e) {
      throw DomainException(_message(e));
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  User? get currentUser {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return User(
      id: fbUser.uid,
      fullName: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
    );
  }

  /// Firebase error codes → messages for the user (in Mongolian).
  static String _message(fb.FirebaseAuthException e) => switch (e.code) {
    'email-already-in-use' => 'Энэ имэйлээр бүртгэл үүссэн байна',
    'invalid-email' => 'Имэйл хаяг буруу байна',
    'weak-password' => 'Нууц үг хэт сул байна',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Имэйл эсвэл нууц үг буруу байна',
    'user-disabled' => 'Энэ бүртгэл идэвхгүй болсон байна',
    'too-many-requests' =>
      'Хэт олон оролдлого хийлээ. Түр хүлээгээд дахин оролдоно уу',
    'network-request-failed' => 'Интернэт холболтоо шалгана уу',
    'operation-not-allowed' || 'configuration-not-found' =>
      'Firebase-д имэйл/нууц үгээр нэвтрэх идэвхжээгүй байна',
    _ => 'Алдаа гарлаа (${e.code})',
  };
}
