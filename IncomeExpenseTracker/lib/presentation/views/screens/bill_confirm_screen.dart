import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../viewmodels/bill_payment_viewmodel.dart';
import '../widgets/detail_rows.dart';
import '../widgets/pill_buttons.dart';
import '../widgets/sheet_scaffold.dart';
import 'bill_receipt_screen.dart';

/// Screen 12 — Bill Payment, confirm step (Figma frame 1:3223): a summary
/// and "Баталгаажуулах". Paying happens only here, after the user confirms.
class BillConfirmScreen extends StatelessWidget {
  const BillConfirmScreen({super.key});

  static const route = '/bill-confirm';

  Future<void> _confirm(BuildContext context, BillPaymentViewModel vm) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await vm.pay();
    if (ok) {
      BillReceiptScreen.showAfterPayment(navigator, vm.receipt!);
    } else if (vm.errorMessage != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final vm = context.watch<BillPaymentViewModel>();
    final bill = vm.bill;

    return SheetScaffold(
      title: 'Bill Payment',
      trailing: TopBarTrailing.dots,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(30 * s, 40 * s, 30 * s, 16 * s),
              children: [
                Center(
                  child: BillLogo(s: s, asset: bill.iconAsset),
                ),
                SizedBox(height: 15 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 29 * s),
                  child: Text(
                    'Та ${bill.title}-ийн төлбөрийг ${paymentMethodInstrumental(vm.method)} төлөх гэж байна',
                    textAlign: TextAlign.center,
                    style: inter(
                      size: 16 * s,
                      weight: FontWeight.w500,
                      color: AppColors.secondary,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 47 * s),
                DetailRow(
                  s: s,
                  label: 'Үнэ',
                  value: Formatters.money(bill.amount),
                ),
                DetailRow(
                  s: s,
                  label: 'Хураамж',
                  value: Formatters.money(bill.fee),
                ),
                DetailDivider(s: s),
                DetailRow(
                  s: s,
                  label: 'Нийт',
                  value: Formatters.money(bill.total),
                  emphasis: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(28 * s, 4 * s, 28 * s, 20 * s),
            child: GradientPillButton(
              s: s,
              label: 'Баталгаажуулах',
              isLoading: vm.isPaying,
              onPressed: () => _confirm(context, vm),
            ),
          ),
        ],
      ),
    );
  }
}
