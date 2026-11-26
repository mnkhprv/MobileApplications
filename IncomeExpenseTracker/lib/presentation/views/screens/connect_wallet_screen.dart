import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../business/services/add_card_service.dart';
import '../../../business/services/connect_account_service.dart';
import '../../../business/services/list_cards_service.dart';
import '../../../business/services/top_up_wallet_service.dart';
import '../../../domain/domain.dart';
import '../../core/theme.dart';
import '../../viewmodels/connect_wallet_viewmodel.dart';
import '../widgets/card_stack.dart';
import '../widgets/pill_buttons.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/selectable_tile.dart';
import '../widgets/sheet_scaffold.dart';

/// Screens 8 & 9 — Connect Wallet (Figma frames 1:2736 "Картууд" and
/// 1:2887 "Аккаунт"). Opened from Wallet → Төлбөр.
class ConnectWalletScreen extends StatefulWidget {
  const ConnectWalletScreen({super.key});

  static const route = '/connect-wallet';

  static Widget create() => ChangeNotifierProvider(
    create: (context) => ConnectWalletViewModel(
      context.read<ListCardsService>(),
      context.read<AddCardService>(),
      context.read<ConnectAccountService>(),
      context.read<TopUpWalletService>(),
    ),
    child: const ConnectWalletScreen(),
  );

  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _cvc = TextEditingController();
  final _expiry = TextEditingController();
  final _topUp = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The front card previews what is typed, so redraw on every keystroke.
    for (final c in [_name, _number, _expiry]) {
      c.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ConnectWalletViewModel>().load();
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _number, _cvc, _expiry, _topUp]) {
      c.dispose();
    }
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitCard(ConnectWalletViewModel vm) async {
    FocusScope.of(context).unfocus();
    final message = await vm.submitCardsForm(
      holderName: _name.text,
      number: _number.text,
      cvc: _cvc.text,
      expiry: _expiry.text,
      topUpText: _topUp.text,
    );
    if (!mounted) return;
    if (message == null) {
      _snack(vm.errorMessage ?? 'Амжилтгүй боллоо');
      return;
    }
    for (final c in [_name, _number, _cvc, _expiry, _topUp]) {
      c.clear();
    }
    _snack(message);
  }

  Future<void> _submitAccount(ConnectWalletViewModel vm) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await vm.connectSelectedAccount();
    if (!mounted) return;
    if (!ok) {
      _snack(vm.errorMessage ?? 'Холбож чадсангүй');
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${_accountTitle(vm.selectedAccount)} холбогдлоо'),
        ),
      );
    Navigator.of(context).pop();
  }

  /// Front card: what is being typed, else the newest linked card.
  CardFace _face(ConnectWalletViewModel vm) {
    final latest = vm.cards.isEmpty ? null : vm.cards.first;
    final digits = _number.text.replaceAll(' ', '');
    final typedExpiry = RegExp(r'^(\d{4})/(\d{1,2})$').firstMatch(_expiry.text);
    return CardFace(
      holder: _name.text.trim().isNotEmpty
          ? _name.text
          : (latest?.holderName ?? 'Таны нэр'),
      number: digits.isNotEmpty
          ? _group(digits.padRight(16, '•'))
          : _group('•' * 12 + (latest?.last4 ?? '••••')),
      expiry: typedExpiry != null
          ? '${typedExpiry.group(2)!.padLeft(2, '0')}/${typedExpiry.group(1)!.substring(2)}'
          : latest == null
          ? 'MM/YY'
          : '${latest.expiryMonth.toString().padLeft(2, '0')}/${latest.expiryYear % 100}',
    );
  }

  static String _group(String sixteen) =>
      [for (var i = 0; i < 16; i += 4) sixteen.substring(i, i + 4)].join('  ');

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final vm = context.watch<ConnectWalletViewModel>();
    final onCards = vm.tab == ConnectTab.cards;

    return SheetScaffold(
      title: onCards ? 'Түрийвч цэнэглэх' : 'Түрийвчтэй холбох',
      trailing: TopBarTrailing.bell,
      onTrailing: () => _snack('Удахгүй нэмэгдэнэ'),
      sheetTop: onCards ? 115 : 165,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              40 * s,
              (onCards ? 70 : 30) * s,
              40 * s,
              0,
            ),
            child: SegmentedTabs(
              s: s,
              labels: const ['Картууд', 'Аккаунт'],
              selected: vm.tab.index,
              onChanged: (i) => vm.selectTab(ConnectTab.values[i]),
            ),
          ),
          Expanded(child: onCards ? _cardsTab(vm, s) : _accountTab(vm, s)),
        ],
      ),
    );
  }

  Widget _cardsTab(ConnectWalletViewModel vm, double s) {
    final hintStyle = inter(size: 12 * s, color: AppColors.muted);
    InputDecoration deco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12 * s,
        vertical: 14 * s,
      ),
      enabledBorder: _border(s, AppColors.fieldBorder, 1),
      focusedBorder: _border(s, AppColors.green, 1.4),
    );
    final fieldStyle = inter(
      size: 14 * s,
      weight: FontWeight.w500,
      color: AppColors.green,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(25 * s, 9 * s, 25 * s, 24 * s),
      children: [
        Center(
          child: CardStack(s: s, face: _face(vm)),
        ),
        SizedBox(height: 10 * s),
        Text(
          'Картны мэдээлэлээ нэмэх',
          style: inter(
            size: 16 * s,
            weight: FontWeight.w500,
            letterSpacing: -0.32 * s,
          ),
        ),
        SizedBox(height: 5 * s),
        Text(
          'Энд холбох карт нь зөвхөн таны нэр дээр байх ёстой.',
          style: inter(
            size: 13 * s,
            color: AppColors.secondary,
            letterSpacing: -0.26 * s,
          ),
        ),
        SizedBox(height: 16 * s),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          style: fieldStyle,
          decoration: InputDecoration(
            labelText: 'КАРТ ДЭЭРХ НЭР',
            labelStyle: inter(size: 12 * s, color: AppColors.secondary),
            floatingLabelStyle: inter(size: 12 * s, color: AppColors.secondary),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20 * s,
              vertical: 17 * s,
            ),
            enabledBorder: _border(s, AppColors.green, 1.4),
            focusedBorder: _border(s, AppColors.green, 1.4),
          ),
        ),
        SizedBox(height: 12 * s),
        Row(
          children: [
            Expanded(
              flex: 220,
              child: TextField(
                controller: _number,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                style: fieldStyle,
                decoration: deco('КАРТЫН ДУГААР'),
              ),
            ),
            SizedBox(width: 11 * s),
            Expanded(
              flex: 133,
              child: TextField(
                controller: _cvc,
                keyboardType: TextInputType.number,
                obscureText: true,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                style: fieldStyle,
                decoration: deco('CVC'),
              ),
            ),
          ],
        ),
        SizedBox(height: 11 * s),
        Row(
          children: [
            Expanded(
              flex: 220,
              child: TextField(
                controller: _expiry,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
                style: fieldStyle,
                decoration: deco('ДУУСАХ ХУГАЦАА YYYY/MM'),
              ),
            ),
            SizedBox(width: 11 * s),
            Expanded(
              flex: 133,
              child: TextField(
                controller: _topUp,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onSubmitted: (_) => _submitCard(vm),
                style: fieldStyle,
                decoration: deco('Value \$'),
              ),
            ),
          ],
        ),
        SizedBox(height: 26 * s),
        OutlinePillButton(
          s: s,
          label: 'ИЛГЭЭХ',
          isLoading: vm.isSubmitting,
          onPressed: () => _submitCard(vm),
        ),
      ],
    );
  }

  Widget _accountTab(ConnectWalletViewModel vm, double s) {
    const options = [
      (
        LinkedAccountType.bankLink,
        'assets/svg/connect/bank.svg',
        60.0,
        'Connect your bank account to deposit & fund',
      ),
      (
        LinkedAccountType.microdeposits,
        'assets/svg/connect/dollar_circle.svg',
        38.0,
        'Connect bank in 5-7 days',
      ),
      (
        LinkedAccountType.paypal,
        'assets/svg/connect/paypal.svg',
        34.0,
        'Connect you paypal account',
      ),
    ];
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(35 * s, 40 * s, 35 * s, 16 * s),
            itemCount: options.length,
            separatorBuilder: (_, _) => SizedBox(height: 15 * s),
            itemBuilder: (_, i) {
              final (type, icon, size, subtitle) = options[i];
              final selected = vm.selectedAccount == type;
              return SelectableTile(
                s: s,
                height: 100,
                titleSize: 18,
                icon: icon,
                iconSize: size,
                title: _accountTitle(type),
                subtitle: subtitle,
                selected: selected,
                onTap: () => vm.selectAccount(type),
                indicator: CheckMark(s: s, selected: selected),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(32 * s, 0, 32 * s, 40 * s),
          child: OutlinePillButton(
            s: s,
            label: 'ДАРААХ',
            isLoading: vm.isSubmitting,
            onPressed: () => _submitAccount(vm),
          ),
        ),
      ],
    );
  }

  static String _accountTitle(LinkedAccountType type) => switch (type) {
    LinkedAccountType.bankLink => 'Bank Link',
    LinkedAccountType.microdeposits => 'Microdeposits',
    LinkedAccountType.paypal => 'Paypal',
  };

  static OutlineInputBorder _border(double s, Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8 * s),
        borderSide: BorderSide(color: color, width: width),
      );
}

/// "6219861028888075" → "6219 8610 2888 8075" while typing (max 16 digits).
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final text = [
      for (var i = 0; i < capped.length; i += 4)
        capped.substring(i, (i + 4).clamp(0, capped.length)),
    ].join(' ');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// "202801" → "2028/01" while typing.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 6 ? digits.substring(0, 6) : digits;
    final text = capped.length > 4
        ? '${capped.substring(0, 4)}/${capped.substring(4)}'
        : capped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
