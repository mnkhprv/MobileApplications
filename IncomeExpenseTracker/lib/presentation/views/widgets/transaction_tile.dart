import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../../domain/domain.dart';
import 'logo_tile.dart';

/// One row in "Гүйлгээний Түүх": logo tile, title, date and amount.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.s,
    required this.transaction,
    this.onTap,
  });

  final double s;
  final Transaction transaction;

  /// Set for bill payments: opens the saved receipt.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    // Min height (not fixed) so large system font sizes don't overflow.
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: 50 * s),
      child: Row(
        children: [
          LogoTile(
            s: s,
            asset: t.iconAsset,
            iconSize: t.iconSize,
            fallback: Icon(
              t.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: t.isIncome ? AppColors.income : AppColors.expense,
              size: 26 * s,
            ),
          ),
          SizedBox(width: 9 * s),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: inter(
                    size: 16 * s,
                    weight: FontWeight.w500,
                    letterSpacing: -0.32 * s,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  Formatters.relativeDate(t.date),
                  style: inter(
                    size: 13 * s,
                    color: AppColors.secondary,
                    letterSpacing: -0.26 * s,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.signedMoney(t),
            style: inter(
              size: 18 * s,
              weight: FontWeight.w600,
              color: t.isIncome ? AppColors.income : AppColors.expense,
              letterSpacing: -0.72 * s,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8 * s),
      child: row,
    );
  }
}
