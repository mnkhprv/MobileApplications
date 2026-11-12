import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HomeTab { home, stats, wallet, profile }

/// White bottom bar with a round notch in the middle (Figma group 1:478).
class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key, required this.s, required this.current, required this.onTap});

  final double s;
  final HomeTab current;
  final ValueChanged<HomeTab> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: 80 * s + bottomInset,
      child: CustomPaint(
        painter: _NotchedBarPainter(s),
        child: Stack(
          children: [
            _item(HomeTab.home, 'nav_home', left: 32, top: 22, size: 36),
            _item(HomeTab.stats, 'nav_stats', left: 104, top: 24, size: 34),
            _item(HomeTab.wallet, 'nav_wallet', left: 274, top: 26, size: 36),
            _item(HomeTab.profile, 'nav_profile', left: 346, top: 26, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _item(HomeTab tab, String icon, {required double left, required double top, required double size}) {
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
            child: SvgPicture.asset('assets/svg/home/$icon.svg', width: size * s, height: size * s),
          ),
        ),
      ),
    );
  }
}

/// Bar shape from the Figma "Subtract" layer: a rectangle minus a circle of
/// radius 45 centred 3px above the top edge, with a soft upward shadow.
class _NotchedBarPainter extends CustomPainter {
  _NotchedBarPainter(this.s);

  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Path()..addRect(Offset.zero & size);
    final notch = Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width / 2, -3 * s), radius: 45 * s));
    final shape = Path.combine(PathOperation.difference, bar, notch);

    canvas.drawPath(
      shape.shift(Offset(0, -2 * s)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.5 * s),
    );
    canvas.drawPath(shape, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) => old.s != s;
}
