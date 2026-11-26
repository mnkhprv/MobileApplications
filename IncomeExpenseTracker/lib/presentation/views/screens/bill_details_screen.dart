import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../business/services/pay_bill_service.dart';
import '../../../domain/domain.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../viewmodels/bill_payment_viewmodel.dart';
import '../widgets/detail_rows.dart';
import '../widgets/pill_buttons.dart';
import '../widgets/selectable_tile.dart';
import '../widgets/sheet_scaffold.dart';
import 'bill_confirm_screen.dart';

/// Screen 11 — Bill Details (Figma frame 1:3144): price, fee, total and the
/// choice of payment method. Opened from Wallet → Хүлээгдэж буй → a bill.
class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  static const route = '/bill-details';

  /// Starts the bill flow. The [BillPaymentViewModel] created here is shared
  /// with the confirm and receipt screens, and disposed when the flow closes.
  /// Completes when the user returns to the Wallet.
  static Future<void> open(BuildContext context, Bill bill) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: route),
        builder: (_) => ChangeNotifierProvider(
          create: (_) =>
              BillPaymentViewModel(context.read<PayBillService>(), bill),
          child: const BillDetailsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final vm = context.watch<BillPaymentViewModel>();
    final bill = vm.bill;

    return SheetScaffold(
      title: 'Bill Details',
      trailing: TopBarTrailing.dots,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(30 * s, 30 * s, 30 * s, 16 * s),
              children: [
                Row(
                  children: [
                    BillLogo(s: s, asset: bill.iconAsset),
                    SizedBox(width: 15 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.title,
                            style: inter(
                              size: 18 * s,
                              weight: FontWeight.w600,
                              letterSpacing: -0.36 * s,
                            ),
                          ),
                          SizedBox(height: 8 * s),
                          Text(
                            Formatters.date(bill.dueDate),
                            style: inter(
                              size: 14 * s,
                              color: AppColors.secondary,
                              letterSpacing: -0.28 * s,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 37 * s),
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
                SizedBox(height: 36 * s),
                Text(
                  'Төлбөрийн хэрэгслээ сонго',
                  style: inter(
                    size: 18 * s,
                    weight: FontWeight.w500,
                    letterSpacing: -0.36 * s,
                  ),
                ),
                SizedBox(height: 20 * s),
                for (final (method, icon, size) in const [
                  (PaymentMethod.debitCard, 'assets/svg/bill/card.svg', 60.0),
                  (PaymentMethod.wallet, 'assets/svg/connect/paypal.svg', 34.0),
                ]) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5 * s),
                    child: SelectableTile(
                      s: s,
                      icon: icon,
                      iconSize: size,
                      title: paymentMethodLabel(method),
                      selected: vm.method == method,
                      onTap: () => vm.selectMethod(method),
                      indicator: RadioDot(s: s, selected: vm.method == method),
                    ),
                  ),
                  SizedBox(height: 15 * s),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(28 * s, 4 * s, 28 * s, 20 * s),
            child: GradientPillButton(
              s: s,
              label: 'Төлөх',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: BillConfirmScreen.route),
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const BillConfirmScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
