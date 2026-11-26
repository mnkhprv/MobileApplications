import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

/// Rounded option card used to pick one item from a list:
/// Connect Wallet → Аккаунт (Bank Link / Microdeposits / Paypal) and
/// Bill Details → payment method (Дебит карт / Түрийвч).
///
/// Selected: light-green card, green text, the icon in a white circle.
/// Idle: light-grey card, grey text and icon.
class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.s,
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.selected,
    required this.onTap,
    required this.indicator,
    this.subtitle,
    this.height = 90,
    this.titleSize = 16,
  });

  final double s;

  /// Single-colour SVG; it is tinted green or grey.
  final String icon;
  final double iconSize;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// What sits on the right: a radio or a check mark.
  final Widget indicator;
  final double height;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.green : AppColors.muted;
    final radius = BorderRadius.circular(20 * s);
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.tileSelected : AppColors.tileIdle,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 12 * s),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 60 * s,
                    height: 60 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.white : Colors.transparent,
                    ),
                    child: SvgPicture.asset(
                      icon,
                      width: iconSize * s,
                      height: iconSize * s,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: 15 * s),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: inter(
                            size: titleSize * s,
                            weight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 4 * s),
                          Text(
                            subtitle!,
                            style: inter(
                              size: 12 * s,
                              weight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * s),
                  indicator,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio circle from Bill Details (Figma groups 1:3192 / 1:3153).
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.s, required this.selected});

  final double s;
  final bool selected;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    selected ? 'assets/svg/bill/radio_on.svg' : 'assets/svg/bill/radio_off.svg',
    width: 20 * s,
    height: 20 * s,
  );
}

/// Green check from Connect Wallet → Аккаунт; empty space when not selected.
class CheckMark extends StatelessWidget {
  const CheckMark({super.key, required this.s, required this.selected});

  final double s;
  final bool selected;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 30 * s,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: selected ? 1 : 0,
      child: SvgPicture.asset(
        'assets/svg/connect/check_circle.svg',
        width: 30 * s,
        height: 30 * s,
      ),
    ),
  );
}
