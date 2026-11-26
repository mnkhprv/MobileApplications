import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import '../../../domain/domain.dart';

/// Entity ⇄ Firestore document conversion. Only this folder knows how data
/// looks in the database; entities stay free of Firebase types.

Map<String, Object?> transactionToMap(Transaction t) => {
  'title': t.title,
  'amount': t.amount,
  'type': t.type.name,
  'date': Timestamp.fromDate(t.date),
  'iconAsset': t.iconAsset,
  'iconSize': t.iconSize,
  'kind': t.kind.name,
  'receiptNumber': t.receiptNumber,
};

Transaction transactionFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data()!;
  return Transaction(
    id: doc.id,
    title: d['title'] as String,
    amount: (d['amount'] as num).toDouble(),
    type: TransactionType.values.byName(d['type'] as String),
    date: (d['date'] as Timestamp).toDate(),
    iconAsset: d['iconAsset'] as String?,
    iconSize: (d['iconSize'] as num?)?.toDouble(),
    kind:
        TransactionKind.values.asNameMap()[d['kind']] ??
        TransactionKind.general,
    receiptNumber: d['receiptNumber'] as String?,
  );
}

Map<String, Object?> billToMap(Bill b) => {
  'title': b.title,
  'amount': b.amount,
  'fee': b.fee,
  'dueDate': Timestamp.fromDate(b.dueDate),
  'iconAsset': b.iconAsset,
  'iconSize': b.iconSize,
  'isPaid': b.isPaid,
};

Bill billFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data()!;
  return Bill(
    id: doc.id,
    title: d['title'] as String,
    amount: (d['amount'] as num).toDouble(),
    fee: (d['fee'] as num? ?? 0).toDouble(),
    dueDate: (d['dueDate'] as Timestamp).toDate(),
    iconAsset: d['iconAsset'] as String,
    iconSize: (d['iconSize'] as num).toDouble(),
    paid: d['isPaid'] as bool? ?? false,
  );
}

/// Only the last 4 digits are ever written — never the full number or CVC.
Map<String, Object?> cardToMap(PaymentCard c) => {
  'holderName': c.holderName,
  'last4': c.last4,
  'expiryYear': c.expiryYear,
  'expiryMonth': c.expiryMonth,
  'addedAt': FieldValue.serverTimestamp(),
};

PaymentCard cardFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data()!;
  return PaymentCard(
    id: doc.id,
    holderName: d['holderName'] as String,
    last4: d['last4'] as String,
    expiryYear: d['expiryYear'] as int,
    expiryMonth: d['expiryMonth'] as int,
  );
}

Map<String, Object?> receiptToMap(BillReceipt r) => {
  'billTitle': r.billTitle,
  'billIconAsset': r.billIconAsset,
  'method': r.method.name,
  'paidAt': Timestamp.fromDate(r.paidAt),
  'price': r.price,
  'fee': r.fee,
  'total': r.total,
};

BillReceipt receiptFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data()!;
  return BillReceipt(
    number: doc.id,
    billTitle: d['billTitle'] as String,
    billIconAsset: d['billIconAsset'] as String,
    method: PaymentMethod.values.byName(d['method'] as String),
    paidAt: (d['paidAt'] as Timestamp).toDate(),
    price: (d['price'] as num).toDouble(),
    fee: (d['fee'] as num).toDouble(),
  );
}
