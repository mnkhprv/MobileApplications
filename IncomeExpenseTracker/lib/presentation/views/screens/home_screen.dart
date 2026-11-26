import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/transaction_tile.dart';
import '../navigation.dart';
import 'bill_receipt_screen.dart';

/// Screen 5 — "Homepage" (Figma node 1:390).
/// View only: data comes from [AuthViewModel] (name) and
/// [TransactionViewModel] (balance, income, expense, history).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TransactionViewModel>().load();
    });
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Удахгүй нэмэгдэнэ')));
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final name = context.select<AuthViewModel, String>(
      (vm) => vm.currentUser?.fullName ?? '',
    );
    final vm = context.watch<TransactionViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: HomeBottomNav(
          s: s,
          current: HomeTab.home,
          onTap: (tab) {
            if (tab != HomeTab.home) goToTab(context, tab);
          },
        ),
        body: Column(
          children: [
            SizedBox(
              height: 380 * s,
              child: _Header(
                s: s,
                greeting: Formatters.greeting(DateTime.now()),
                name: name,
                balance: vm.balance,
                income: vm.totalIncome,
                expense: vm.totalExpense,
                onBell: _comingSoon,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Гүйлгээний Түүх',
                      overflow: TextOverflow.ellipsis,
                      style: inter(
                        size: 18 * s,
                        weight: FontWeight.w600,
                        color: AppColors.title,
                        letterSpacing: -0.36 * s,
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * s),
                  GestureDetector(
                    onTap: _comingSoon,
                    child: Text(
                      'Бүгдийг харах',
                      style: inter(
                        size: 14 * s,
                        color: AppColors.secondary,
                        letterSpacing: -0.28 * s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 19 * s),
            Expanded(
              child: vm.isLoading && vm.transactions.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.green),
                    )
                  : vm.transactions.isEmpty
                  ? Center(
                      child: Text(
                        'Гүйлгээ алга байна',
                        style: inter(size: 14 * s, color: AppColors.secondary),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(22 * s, 0, 22 * s, 16 * s),
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teal curved header with decorative rings, greeting, bell and the card.
class _Header extends StatelessWidget {
  const _Header({
    required this.s,
    required this.greeting,
    required this.name,
    required this.balance,
    required this.income,
    required this.expense,
    required this.onBell,
  });

  final double s;
  final String greeting;
  final String name;
  final double balance;
  final double income;
  final double expense;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 287 * s,
          child: SvgPicture.asset(
            'assets/svg/header_curve.svg',
            fit: BoxFit.fill,
          ),
        ),
        // Decorative rings (mirrored horizontally in Figma).
        _ring('ellipse7', left: -55, top: -15, size: 212, mirror: true),
        _ring('ellipse8', left: 59, top: -15, size: 127, mirror: true),
        _ring('ellipse9', left: 127, top: -22, size: 85),
        Positioned(
          left: 24 * s,
          top: 74 * s,
          child: Text(
            greeting,
            style: inter(
              size: 14 * s,
              weight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          left: 24 * s,
          right: 80 * s,
          top: 98 * s,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: inter(
              size: 20 * s,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          left: 350 * s,
          top: 78 * s,
          child: Material(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6.667 * s),
            child: InkWell(
              borderRadius: BorderRadius.circular(6.667 * s),
              onTap: onBell,
              child: Padding(
                padding: EdgeInsets.all(8.333 * s),
                child: SvgPicture.asset(
                  'assets/svg/home/bell.svg',
                  width: 23.333 * s,
                  height: 23.333 * s,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20 * s,
          top: 155 * s,
          child: BalanceCard(
            s: s,
            balance: balance,
            income: income,
            expense: expense,
          ),
        ),
      ],
    );
  }

  Widget _ring(
    String name, {
    required double left,
    required double top,
    required double size,
    bool mirror = false,
  }) {
    return Positioned(
      left: left * s,
      top: top * s,
      width: size * s,
      height: size * s,
      child: Transform.flip(
        flipX: mirror,
        child: SvgPicture.asset('assets/svg/home/$name.svg', fit: BoxFit.fill),
      ),
    );
  }
}
