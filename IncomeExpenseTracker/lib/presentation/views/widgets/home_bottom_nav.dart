import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HomeTab { home, stats, wallet, profile }

/// White bottom bar. On Home it has a round notch in the middle (Figma group
/// 1:478); on Wallet it is a flat bar with evenly spaced icons (1:2599).
/// The [current] tab gets the filled green icon.
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.s,
    required this.current,
    required this.onTap,
    this.notched = true,
  });

  final double s;
  final HomeTab current;
  final ValueChanged<HomeTab> onTap;
  final bool notched;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: 80 * s + bottomInset,
      child: CustomPaint(
        painter: _BarPainter(s, notched: notched),
        child: Stack(
          children: notched
              ? [
                  _item(HomeTab.home, left: 32, top: 22, size: 36),
                  _item(HomeTab.stats, left: 104, top: 24, size: 34),
                  _item(HomeTab.wallet, left: 274, top: 26, size: 36),
                  _item(HomeTab.profile, left: 346, top: 26, size: 36),
                ]
              : [
                  _item(HomeTab.home, left: 32.75, top: 22, size: 36),
                  _item(HomeTab.stats, left: 137.5, top: 23, size: 34),
                  _item(HomeTab.wallet, left: 241.5, top: 22, size: 36),
                  _item(HomeTab.profile, left: 347.5, top: 22, size: 36),
                ],
        ),
      ),
    );
  }

  /// Home and wallet have separate active (green) and inactive (grey) icons.
  String _icon(HomeTab tab) {
    final active = tab == current;
    return switch (tab) {
      HomeTab.home => active ? 'nav_home' : 'nav_home_inactive',
      HomeTab.stats => 'nav_stats',
      HomeTab.wallet => active ? 'nav_wallet_active' : 'nav_wallet',
      HomeTab.profile => 'nav_profile',
    };
  }

  Widget _item(
    HomeTab tab, {
    required double left,
    required double top,
    required double size,
  }) {
    // Enlarged tap target around the icon.
    const pad = 8.0;
    return Positioned(
      left: (left - pad) * s,
      top: (top - pad) * s,
      child: Semantics(
        button: true,
        selected: tab == current,
        label: tab.name,
        child: InkResponse(
          onTap: () => onTap(tab),
          radius: 28 * s,
          child: Padding(
            padding: EdgeInsets.all(pad * s),
            child: SvgPicture.asset(
              'assets/svg/home/${_icon(tab)}.svg',
              width: size * s,
              height: size * s,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar shape. Notched = the Figma "Subtract" layer: a rectangle minus a circle
/// of radius 45 centred 3px above the top edge. Both have a soft upward shadow.
class _BarPainter extends CustomPainter {
  _BarPainter(this.s, {required this.notched});

  final double s;
  final bool notched;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Path()..addRect(Offset.zero & size);
    final shape = notched
        ? Path.combine(
            PathOperation.difference,
            bar,
            Path()..addOval(
              Rect.fromCircle(
                center: Offset(size.width / 2, -3 * s),
                radius: 45 * s,
              ),
            ),
          )
        : bar;

    canvas.drawPath(
      shape.shift(Offset(0, -2 * s)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.5 * s),
    );
    canvas.drawPath(shape, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.s != s || old.notched != notched;
}
