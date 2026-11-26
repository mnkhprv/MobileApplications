import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

/// "Label ........ value" line used on Bill Details and Bill Payment.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.s,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.valueColor = Colors.black,
    this.trailing,
  });

  final double s;
  final String label;
  final String value;

  /// "Нийт" row: semibold label, bold value.
  final bool emphasis;
  final Color valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final labelStyle = inter(
      size: 16 * s,
      weight: emphasis ? FontWeight.w600 : FontWeight.w500,
      color: AppColors.secondary,
      letterSpacing: -0.32 * s,
    );
    final valueStyle = inter(
      size: 16 * s,
      weight: emphasis ? FontWeight.w700 : FontWeight.w500,
      color: valueColor,
      letterSpacing: -0.32 * s,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * s),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          SizedBox(width: 16 * s),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 8 * s), trailing!],
        ],
      ),
    );
  }
}

/// Thin grey rule between detail groups.
class DetailDivider extends StatelessWidget {
  const DetailDivider({super.key, required this.s});

  final double s;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8 * s),
    child: const Divider(height: 1, thickness: 1, color: AppColors.fieldBorder),
  );
}

/// 80px light-grey circle with the bill's logo in the middle.
class BillLogo extends StatelessWidget {
  const BillLogo({
    super.key,
    required this.s,
    required this.asset,
    this.size = 80,
    this.logoSize = 40,
  });

  final double s;
  final String asset;
  final double size;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final logo = logoSize * s;
    return Container(
      width: size * s,
      height: size * s,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.tileIdle,
        shape: BoxShape.circle,
      ),
      child: asset.endsWith('.svg')
          ? SvgPicture.asset(asset, width: logo, height: logo)
          : Image.asset(asset, width: logo, height: logo, fit: BoxFit.contain),
    );
  }
}
