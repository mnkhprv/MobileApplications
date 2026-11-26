import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../../domain/domain.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../navigation.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/logo_tile.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/sheet_scaffold.dart';
import '../widgets/transaction_tile.dart';
import 'add_expense_screen.dart';
import 'bill_receipt_screen.dart';
import 'bill_details_screen.dart';
import 'connect_wallet_screen.dart';

/// Screens 6 & 7 — "Түрийвч" (Figma frames 1:2530 and 1:2630).
/// One screen with two tabs: transaction history and pending bills.
/// Presentation layer, view only: tab and bills come from [WalletViewModel],
/// balance and history from [TransactionViewModel].
///
/// Нэмэх → Add Expense, Төлбөр → Connect Wallet, a bill → Bill Details.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static const route = '/wallet';

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionViewModel>().load();
      context.read<WalletViewModel>().load();
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Bill flow: Bill Details → confirm → receipt. Refresh when it closes.
  Future<void> _openBill(Bill bill) async {
    await BillDetailsScreen.open(context, bill);
    if (mounted) context.read<WalletViewModel>().load(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final balance = context.select<TransactionViewModel, double>(
      (vm) => vm.balance,
    );
    final wallet = context.watch<WalletViewModel>();

    return SheetScaffold(
      title: 'Түрийвч',
      trailing: TopBarTrailing.bell,
      onTrailing: () => _snack('Удахгүй нэмэгдэнэ'),
      onBack: () => goToTab(context, HomeTab.home),
      child: _Sheet(
        s: s,
        balance: balance,
        wallet: wallet,
        onAdd: () => Navigator.of(context).pushNamed(AddExpenseScreen.route),
        onPayments: () =>
            Navigator.of(context).pushNamed(ConnectWalletScreen.route),
        onOpenBill: _openBill,
      ),
    );
  }
}

/// White rounded sheet: balance, the two round actions, tab switch and list.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.s,
    required this.balance,
    required this.wallet,
    required this.onAdd,
    required this.onPayments,
    required this.onOpenBill,
  });

  final double s;
  final double balance;
  final WalletViewModel wallet;
  final VoidCallback onAdd;
  final VoidCallback onPayments;
  final ValueChanged<Bill> onOpenBill;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50 * s),
        Text(
          'Нийт үлдэгдэл',
          style: inter(size: 16 * s, color: AppColors.secondary),
        ),
        SizedBox(height: 12 * s),
        Text(
          Formatters.money(balance),
          style: inter(
            size: 30 * s,
            weight: FontWeight.w700,
            color: AppColors.title,
            letterSpacing: -1.5 * s,
          ),
        ),
        SizedBox(height: 49 * s),
        Padding(
          padding: EdgeInsets.only(left: 87 * s, right: 41 * s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundAction(s: s, icon: 'plus', label: 'Нэмэх', onTap: onAdd),
              _RoundAction(
                s: s,
                icon: 'qr',
                label: 'Төлбөр',
                onTap: onPayments,
              ),
            ],
          ),
        ),
        SizedBox(height: 50 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * s),
          child: SegmentedTabs(
            s: s,
            labels: const ['Гүйлгээнүүд', 'Хүлээгдэж буй гүйлгээ'],
            selected: wallet.tab.index,
            onChanged: (i) => wallet.selectTab(WalletTab.values[i]),
          ),
        ),
        SizedBox(height: 25 * s),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: wallet.tab == WalletTab.transactions
                ? _TransactionsList(key: const ValueKey('transactions'), s: s)
                : _BillsList(
                    key: const ValueKey('bills'),
                    s: s,
                    wallet: wallet,
                    onOpen: onOpenBill,
                  ),
          ),
        ),
      ],
    );
  }
}

/// 60px outlined circle with an icon and a label underneath.
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.s,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double s;
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * s),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 114.4 * s)
              .copyWith(minHeight: 86 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60 * s,
                height: 60 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ring),
                ),
                child: SvgPicture.asset(
                  'assets/svg/wallet/$icon.svg',
                  width: 30 * s,
                  height: 30 * s,
                ),
              ),
              SizedBox(height: 8 * s),
              Text(
                label,
                style: inter(size: 14 * s, color: AppColors.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab 1 — same rows as the Home history.
class _TransactionsList extends StatelessWidget {
  const _TransactionsList({super.key, required this.s});

  final double s;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    if (vm.isLoading && vm.transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }
    if (vm.transactions.isEmpty) {
      return _Empty(s: s, text: 'Гүйлгээ алга байна');
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(26 * s, 0, 26 * s, 16 * s),
      itemCount: vm.transactions.length,
      separatorBuilder: (_, _) => SizedBox(height: 16 * s),
      itemBuilder: (_, i) {
        final t = vm.transactions[i];
        final receipt = t.receiptNumber;
        return TransactionTile(
          s: s,
          transaction: t,
          onTap: receipt == null
              ? null
              : () => BillReceiptScreen.open(context, receipt),
        );
      },
    );
  }
}

/// Tab 2 — upcoming bills. Tapping a row or "Төлөх" opens Bill Details.
class _BillsList extends StatelessWidget {
  const _BillsList({
    super.key,
    required this.s,
    required this.wallet,
    required this.onOpen,
  });

  final double s;
  final WalletViewModel wallet;
  final ValueChanged<Bill> onOpen;

  @override
  Widget build(BuildContext context) {
    final bills = wallet.pendingBills;
    if (wallet.isLoading && bills.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }
    if (bills.isEmpty) {
      return _Empty(s: s, text: 'Хүлээгдэж буй гүйлгээ алга');
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(26 * s, 0, 26 * s, 16 * s),
      itemCount: bills.length,
      separatorBuilder: (_, _) => SizedBox(height: 16 * s),
      itemBuilder: (_, i) =>
          _BillTile(s: s, bill: bills[i], onOpen: () => onOpen(bills[i])),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({required this.s, required this.bill, required this.onOpen});

  final double s;
  final Bill bill;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8 * s),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 50 * s),
        child: Row(
          children: [
            LogoTile(s: s, asset: bill.iconAsset, iconSize: bill.iconSize),
            SizedBox(width: 9 * s),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: inter(
                      size: 16 * s,
                      weight: FontWeight.w500,
                      letterSpacing: -0.32 * s,
                    ),
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                    '${Formatters.date(bill.dueDate)} · ${Formatters.money(bill.total)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: inter(
                      size: 13 * s,
                      color: AppColors.secondary,
                      letterSpacing: -0.26 * s,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * s),
            SizedBox(
              width: 100 * s,
              height: 36 * s,
              child: Material(
                color: AppColors.payButton,
                borderRadius: BorderRadius.circular(40 * s),
                child: InkWell(
                  borderRadius: BorderRadius.circular(40 * s),
                  onTap: onOpen,
                  child: Center(
                    child: Text(
                      'Төлөх',
                      style: inter(
                        size: 16 * s,
                        weight: FontWeight.w500,
                        color: AppColors.green,
                        letterSpacing: -0.64 * s,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.s, required this.text});

  final double s;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: inter(size: 14 * s, color: AppColors.secondary),
      ),
    );
  }
}
