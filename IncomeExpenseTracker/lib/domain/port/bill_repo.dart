import '../entity/bill.dart';

/// Port: what the business layer needs from bill storage.
abstract class BillRepo {
  Future<List<Bill>> findPending();
  Future<Bill?> findById(String id);
  Future<void> save(Bill bill);
}
