import '../../domain/domain.dart';

/// Use case: unpaid bills, soonest due first.
class ListPendingBillsService {
  ListPendingBillsService(this._bills);

  final BillRepo _bills;

  Future<List<Bill>> execute() async {
    final pending = await _bills.findPending();
    return [...pending]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
