import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

/// 50px rounded tile used in transaction and bill rows.
///
/// With [iconSize] the asset is drawn centred on the light-green background
/// (bills). Without it the asset is a full tile image (seed transactions).
/// With no asset at all, [fallback] is shown.
class LogoTile extends StatelessWidget {
  const LogoTile({
    super.key,
    required this.s,
    this.asset,
    this.iconSize,
    this.fallback,
  });

  final double s;
  final String? asset;
  final double? iconSize;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final asset = this.asset;
    final Widget child;
    if (asset == null) {
      child = ColoredBox(
        color: AppColors.iconTile,
        child: Center(child: fallback),
      );
    } else if (iconSize == null) {
      child = Image.asset(asset, fit: BoxFit.cover);
    } else {
      final size = iconSize! * s;
      child = ColoredBox(
        color: AppColors.iconTile,
        child: Center(
          child: asset.endsWith('.svg')
              ? SvgPicture.asset(asset, width: size, height: size)
              : Image.asset(
                  asset,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8 * s),
      child: SizedBox.square(dimension: 50 * s, child: child),
    );
  }
}
