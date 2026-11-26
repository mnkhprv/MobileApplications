/// The core of the app: entities (data + their own rules) and ports
/// (interfaces the core needs). Imports nothing from other layers.
/// Same role as `domain/index.ts` in the course's library system.
library;

export 'entity/bill.dart';
export 'entity/domain_exception.dart';
export 'entity/payment.dart';
export 'entity/payment_card.dart';
export 'entity/transaction.dart';
export 'entity/user.dart';
export 'port/bill_repo.dart';
export 'port/transaction_repo.dart';
export 'port/auth_repo.dart';
export 'port/receipt_repo.dart';
export 'port/wallet_repo.dart';
