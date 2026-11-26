import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';
import '../navigation.dart';
import 'home_bottom_nav.dart';

/// What sits at the right of the top bar.
enum TopBarTrailing { none, bell, dots }

/// The frame shared by every inner screen in the Figma file (Wallet, Add
/// Expense, Connect Wallet, Bill Details, Bill Payment): teal curved header
/// with rings, back chevron + centred title, and a white area below it.
///
/// - Default: a full-width white sheet with 30px top corners from [sheetTop].
/// - [floatingCard]: a 358px card with 20px corners (Add Expense); the whole
///   page scrolls so the keyboard never covers the form.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing = TopBarTrailing.none,
    this.onTrailing,
    this.onBack,
    this.sheetTop = 165,
    this.floatingCard = false,
    this.showBottomNav = true,
  });

  final String title;
  final Widget child;
  final TopBarTrailing trailing;
  final VoidCallback? onTrailing;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;

  /// Design y where the white sheet starts.
  final double sheetTop;
  final bool floatingCard;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    final header = <Widget>[
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
      Positioned(
        left: -55 * s,
        top: -22 * s,
        width: 267 * s,
        height: 219 * s,
        child: SvgPicture.asset(
          'assets/svg/wallet/rings.svg',
          fit: BoxFit.fill,
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: 130 * s,
        child: _TopBar(
          s: s,
          title: title,
          trailing: trailing,
          onBack: onBack ?? () => Navigator.of(context).maybePop(),
          onTrailing: onTrailing,
        ),
      ),
    ];

    final Widget body;
    if (floatingCard) {
      body = SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(height: 287 * s, width: double.infinity),
            ...header,
            Padding(
              padding: EdgeInsets.fromLTRB(
                28 * s,
                sheetTop * s,
                28 * s,
                24 * s,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20 * s),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: Offset(0, 22 * s),
                      blurRadius: 35 * s,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ],
        ),
      );
    } else {
      body = Stack(
        children: [
          ...header,
          Positioned.fill(
            top: sheetTop * s,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30 * s),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: Offset(0, 24.484 * s),
                    blurRadius: 38.952 * s,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: showBottomNav
            ? HomeBottomNav(
                s: s,
                current: HomeTab.wallet,
                notched: false,
                onTap: (tab) => goToTab(context, tab),
              )
            : null,
        body: body,
      ),
    );
  }
}

/// Back chevron, centred title and the optional bell / dots (Figma y 78–118).
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.s,
    required this.title,
    required this.trailing,
    required this.onBack,
    required this.onTrailing,
  });

  final double s;
  final String title;
  final TopBarTrailing trailing;
  final VoidCallback onBack;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 16 * s,
          top: 73 * s,
          child: Semantics(
            button: true,
            label: 'Буцах',
            child: InkResponse(
              onTap: onBack,
              radius: 24 * s,
              child: Padding(
                padding: EdgeInsets.all(8 * s),
                child: SvgPicture.asset(
                  'assets/svg/wallet/chevron_left.svg',
                  width: 28 * s,
                  height: 28 * s,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 80 * s,
          right: 80 * s,
          top: 84 * s,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: inter(
              size: 18 * s,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        if (trailing == TopBarTrailing.bell)
          Positioned(
            left: 350 * s,
            top: 78 * s,
            child: Material(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6.667 * s),
              child: InkWell(
                borderRadius: BorderRadius.circular(6.667 * s),
                onTap: onTrailing,
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
        if (trailing == TopBarTrailing.dots)
          Positioned(
            left: 348 * s,
            top: 79 * s,
            child: Semantics(
              button: onTrailing != null,
              label: 'Цэс',
              child: InkResponse(
                onTap: onTrailing,
                radius: 22 * s,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * s,
                    vertical: 13 * s,
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/expense/dots.svg',
                    width: 26 * s,
                    height: 6 * s,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
