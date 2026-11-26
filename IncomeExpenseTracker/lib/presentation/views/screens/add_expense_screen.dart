import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../business/services/add_transaction_service.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../viewmodels/add_expense_viewmodel.dart';
import '../widgets/sheet_scaffold.dart';

/// Screen 10 — "Төлбөр нэмэх" / Add Expense (Figma frame 1:620).
/// Opened from Wallet → Нэмэх. Saving goes through [AddExpenseViewModel] →
/// `AddTransactionService`; Home and Wallet update through the stream.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  static const route = '/add-expense';

  /// Route builder: the form's ViewModel lives only as long as this screen.
  static Widget create() => ChangeNotifierProvider(
    create: (context) =>
        AddExpenseViewModel(context.read<AddTransactionService>()),
    child: const AddExpenseScreen(),
  );

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPayee(AddExpenseViewModel vm, double s) async {
    final picked = await showModalBottomSheet<ExpensePayee>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final p in AddExpenseViewModel.payees)
              ListTile(
                leading: _PayeeLogo(s: s, payee: p),
                title: Text(
                  p.title,
                  style: inter(size: 16 * s, weight: FontWeight.w500),
                ),
                trailing: p == vm.payee
                    ? const Icon(Icons.check_rounded, color: AppColors.green)
                    : null,
                onTap: () => Navigator.pop(context, p),
              ),
          ],
        ),
      ),
    );
    if (picked != null) vm.selectPayee(picked);
  }

  Future<void> _pickDate(AddExpenseViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) vm.selectDate(picked);
  }

  Future<void> _save(AddExpenseViewModel vm) async {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await vm.save(_amount.text);
    if (!mounted) return;
    if (ok) {
      // The messenger belongs to MaterialApp, so the message stays visible
      // on the Wallet screen after this route closes.
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${vm.payee.title} — зарлага нэмэгдлээ')),
        );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final vm = context.watch<AddExpenseViewModel>();

    return SheetScaffold(
      title: 'Төлбөр нэмэх',
      floatingCard: true,
      showBottomNav: false,
      trailing: TopBarTrailing.dots,
      onTrailing: () {
        _amount.clear();
        vm.reset();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 30 * s, 20 * s, 40 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Label(s: s, text: 'ГҮЙЛГЭЭНИЙ НЭР'),
            _FieldBox(
              s: s,
              onTap: () => _pickPayee(vm, s),
              semanticsLabel: 'Гүйлгээний нэр: ${vm.payee.title}',
              child: Row(
                children: [
                  _PayeeLogo(s: s, payee: vm.payee),
                  SizedBox(width: 14 * s),
                  Expanded(
                    child: Text(
                      vm.payee.title,
                      overflow: TextOverflow.ellipsis,
                      style: inter(
                        size: 14 * s,
                        weight: FontWeight.w500,
                        color: AppColors.secondary,
                        letterSpacing: -0.14 * s,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svg/expense/chevron_down.svg',
                    width: 20 * s,
                    height: 20 * s,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * s),
            _Label(s: s, text: 'ҮНИЙН ДҮН'),
            SizedBox(
              height: 50 * s,
              child: TextField(
                controller: _amount,
                focusNode: _amountFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(vm),
                style: inter(
                  size: 14 * s,
                  weight: FontWeight.w600,
                  color: AppColors.green,
                  letterSpacing: -0.14 * s,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: inter(
                    size: 14 * s,
                    weight: FontWeight.w600,
                    color: AppColors.hint,
                  ),
                  // Always visible (prefixText only shows while focused).
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 20 * s, right: 4 * s),
                    child: Text(
                      '\$',
                      style: inter(
                        size: 14 * s,
                        weight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  contentPadding: EdgeInsets.fromLTRB(
                    0,
                    15 * s,
                    20 * s,
                    15 * s,
                  ),
                  enabledBorder: _border(s, AppColors.fieldBorder, 1),
                  focusedBorder: _border(s, AppColors.green, 1.4),
                ),
              ),
            ),
            SizedBox(height: 24 * s),
            _Label(s: s, text: 'ОГНОО'),
            _FieldBox(
              s: s,
              onTap: () => _pickDate(vm),
              semanticsLabel: 'Огноо: ${Formatters.longDate(vm.date)}',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      Formatters.longDate(vm.date),
                      style: inter(
                        size: 14 * s,
                        weight: FontWeight.w500,
                        color: AppColors.secondary,
                        letterSpacing: -0.14 * s,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svg/expense/calendar.svg',
                    width: 20 * s,
                    height: 20 * s,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * s),
            _Label(s: s, text: 'ТӨЛБӨР'),
            _DashedButton(s: s, isLoading: vm.isSaving, onTap: () => _save(vm)),
            if (vm.errorMessage != null) ...[
              SizedBox(height: 12 * s),
              Text(
                vm.errorMessage!,
                style: inter(size: 13 * s, color: AppColors.expense),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static OutlineInputBorder _border(double s, Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8 * s),
        borderSide: BorderSide(color: color, width: width),
      );
}

/// "ГҮЙЛГЭЭНИЙ НЭР" style caption above each field.
class _Label extends StatelessWidget {
  const _Label({required this.s, required this.text});

  final double s;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 10 * s),
    child: Text(
      text,
      style: inter(
        size: 12 * s,
        weight: FontWeight.w500,
        color: AppColors.secondary,
        letterSpacing: 0.72 * s,
      ),
    ),
  );
}

/// Tappable 50px field with a grey border (name and date).
class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.s,
    required this.child,
    required this.onTap,
    required this.semanticsLabel,
  });

  final double s;
  final Widget child;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8 * s),
      side: const BorderSide(color: AppColors.fieldBorder),
    );
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Container(
            height: 50 * s,
            padding: EdgeInsets.only(left: 19 * s, right: 15 * s),
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Payee logo on a white circle with a soft shadow (Figma 1:644 / 1:645).
class _PayeeLogo extends StatelessWidget {
  const _PayeeLogo({required this.s, required this.payee});

  final double s;
  final ExpensePayee payee;

  @override
  Widget build(BuildContext context) {
    // SVG glyphs are drawn at most 28px (×0.8) inside the 34px circle.
    final size = payee.iconSize.clamp(0.0, 28.0) * s;
    return Container(
      width: 34 * s,
      height: 34 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: Offset(0, 4 * s),
            blurRadius: 8 * s,
          ),
        ],
      ),
      child: ClipOval(
        child: payee.iconAsset.endsWith('.svg')
            ? SvgPicture.asset(
                payee.iconAsset,
                width: size * 0.8,
                height: size * 0.8,
              )
            : Image.asset(
                payee.iconAsset,
                width: 32 * s,
                height: 32 * s,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

/// Dashed "⊕ Төлбөр нэмэх" box — saves the expense.
class _DashedButton extends StatelessWidget {
  const _DashedButton({
    required this.s,
    required this.onTap,
    required this.isLoading,
  });

  final double s;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Төлбөр нэмэх',
      excludeSemantics: true,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          radius: 8 * s,
          color: AppColors.fieldBorder,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(8 * s),
            onTap: isLoading ? null : onTap,
            child: SizedBox(
              height: 50 * s,
              child: Center(
                child: isLoading
                    ? SizedBox.square(
                        dimension: 20 * s,
                        child: const CircularProgressIndicator(
                          color: AppColors.green,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/expense/plus_circle.svg',
                            width: 24 * s,
                            height: 24 * s,
                          ),
                          SizedBox(width: 12 * s),
                          Text(
                            'Төлбөр нэмэх',
                            style: inter(
                              size: 14 * s,
                              weight: FontWeight.w500,
                              color: AppColors.secondary,
                              letterSpacing: 0.84 * s,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(0.5);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 8) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.radius != radius || old.color != color;
}
