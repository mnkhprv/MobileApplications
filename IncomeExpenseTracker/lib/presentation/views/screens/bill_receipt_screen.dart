import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../business/services/get_receipt_service.dart';
import '../../../domain/domain.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../viewmodels/bill_payment_viewmodel.dart' show paymentMethodLabel;
import '../../viewmodels/receipt_viewmodel.dart';
import '../widgets/detail_rows.dart';
import '../widgets/pill_buttons.dart';
import '../widgets/sheet_scaffold.dart';
import 'wallet_screen.dart';

/// Screen 13 — Bill Payment, success receipt (Figma frame 1:3281).
/// The receipt is saved (Firestore) and its QR code encodes the payment.
///
/// - Right after paying ([showAfterPayment]): back returns straight to Wallet.
/// - From the history ([open]): loads the saved receipt; back just pops.
class BillReceiptScreen extends StatefulWidget {
  const BillReceiptScreen({super.key, this.returnToWallet = false});

  static const route = '/bill-receipt';

  final bool returnToWallet;

  /// Replaces the confirm screen once [receipt] has been issued.
  static void showAfterPayment(NavigatorState navigator, BillReceipt receipt) {
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: route),
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ReceiptViewModel.ready(receipt),
          child: const BillReceiptScreen(returnToWallet: true),
        ),
      ),
    );
  }

  /// Opens a saved receipt by its number.
  static Future<void> open(BuildContext context, String number) {
    final get = context.read<GetReceiptService>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: route),
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ReceiptViewModel.load(get, number),
          child: const BillReceiptScreen(),
        ),
      ),
    );
  }

  @override
  State<BillReceiptScreen> createState() => _BillReceiptScreenState();
}

class _BillReceiptScreenState extends State<BillReceiptScreen> {
  bool _expanded = true;

  void _close() {
    final navigator = Navigator.of(context);
    if (widget.returnToWallet) {
      navigator.popUntil(
        (r) => r.settings.name == WalletScreen.route || r.isFirst,
      );
    } else {
      navigator.pop();
    }
  }

  Future<void> _copy(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _receiptText(BillReceipt r) => [
    '${r.billTitle} — амжилттай төлөгдлөө',
    'Төлбөрийн хэрэгсэл: ${paymentMethodLabel(r.method)}',
    'Огноо: ${Formatters.date(r.paidAt)} ${Formatters.time(r.paidAt)}',
    'Гүйлгээний дугаар: ${r.number}',
    'Үнэ: ${Formatters.money(r.price)}',
    'Хураамж: ${Formatters.money(r.fee)}',
    'Нийт: ${Formatters.money(r.total)}',
  ].join('\n');

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final vm = context.watch<ReceiptViewModel>();
    final receipt = vm.receipt;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: SheetScaffold(
        title: 'Bill Payment',
        trailing: TopBarTrailing.dots,
        onBack: _close,
        child: receipt == null
            ? Center(
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: AppColors.green)
                    : Text(
                        vm.errorMessage!,
                        style: inter(size: 14 * s, color: AppColors.secondary),
                      ),
              )
            : _body(receipt, s),
      ),
    );
  }

  Widget _body(BillReceipt receipt, double s) {
    return ListView(
      padding: EdgeInsets.fromLTRB(32 * s, 18 * s, 32 * s, 16 * s),
      children: [
        Text(
          'Амжилттай Төлөгдлөө',
          textAlign: TextAlign.center,
          style: inter(
            size: 22 * s,
            weight: FontWeight.w600,
            color: AppColors.green,
            letterSpacing: -0.44 * s,
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          receipt.billTitle,
          textAlign: TextAlign.center,
          style: inter(
            size: 16 * s,
            weight: FontWeight.w500,
            color: AppColors.secondary,
            letterSpacing: -0.32 * s,
          ),
        ),
        Center(
          child: SvgPicture.asset(
            'assets/svg/bill/success.svg',
            width: 56 * s,
            height: 56 * s,
          ),
        ),
        Semantics(
          button: true,
          expanded: _expanded,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4 * s),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Гүйлгээний дэлгэрэнгүй',
                      style: inter(
                        size: 18 * s,
                        weight: FontWeight.w500,
                        letterSpacing: -0.36 * s,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      'assets/svg/bill/chevron_up.svg',
                      width: 20 * s,
                      height: 20 * s,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Column(
                  children: [
                    SizedBox(height: 2 * s),
                    DetailRow(
                      s: s,
                      label: 'Төлбөрийн хэрэгсэл',
                      value: paymentMethodLabel(receipt.method),
                    ),
                    DetailRow(
                      s: s,
                      label: 'Төлөв',
                      value: 'Хийгдсэн',
                      valueColor: AppColors.green,
                    ),
                    DetailRow(
                      s: s,
                      label: 'Цаг',
                      value: Formatters.time(receipt.paidAt),
                    ),
                    DetailRow(
                      s: s,
                      label: 'Огноо',
                      value: Formatters.date(receipt.paidAt),
                    ),
                    DetailRow(
                      s: s,
                      label: 'Гүйлгээний дугаар',
                      value: receipt.number,
                      trailing: Semantics(
                        button: true,
                        label: 'Гүйлгээний дугаар хуулах',
                        child: InkResponse(
                          onTap: () => _copy(
                            receipt.number,
                            'Гүйлгээний дугаар хуулагдлаа',
                          ),
                          radius: 18 * s,
                          child: SvgPicture.asset(
                            'assets/svg/bill/copy.svg',
                            width: 20 * s,
                            height: 20 * s,
                          ),
                        ),
                      ),
                    ),
                    DetailDivider(s: s),
                    DetailRow(
                      s: s,
                      label: 'Үнэ',
                      value: Formatters.money(receipt.price),
                    ),
                    DetailRow(
                      s: s,
                      label: 'Хураамж',
                      value: Formatters.money(receipt.fee),
                    ),
                    DetailDivider(s: s),
                    DetailRow(
                      s: s,
                      label: 'Нийт',
                      value: Formatters.money(receipt.total),
                      emphasis: true,
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
        SizedBox(height: 8 * s),
        Center(
          child: Semantics(
            label: 'Баримтын QR код',
            child: QrImageView(
              data: receiptQrData(receipt),
              size: 102 * s,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 26 * s),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 34 * s),
          child: OutlinePillButton(
            s: s,
            height: 49,
            label: 'Share Receipt',
            onPressed: () => _copy(
              _receiptText(receipt),
              'Баримт хуулагдлаа — хүссэн газраа буулгаарай',
            ),
          ),
        ),
      ],
    );
  }
}
