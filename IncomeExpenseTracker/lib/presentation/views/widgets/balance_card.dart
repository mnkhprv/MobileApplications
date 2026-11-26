import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';

/// "Нийт үлдэгдэл" card (Figma group 1:418). Coordinates are relative to the
/// card's top-left corner (Figma x - 20, y - 155). Size: 374 x 201.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.s,
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double s;
  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 374 * s,
      height: 201 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft dark shadow under the lower half of the card.
          Positioned(
            left: 9 * s,
            top: 118.58 * s,
            width: 356 * s,
            height: 83.42 * s,
            child: Opacity(
              opacity: 0.8,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 24 * s, sigmaY: 24 * s),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cardShadow,
                    borderRadius: BorderRadius.circular(20 * s),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20 * s),
              ),
            ),
          ),
          // Title + chevron
          Positioned(
            left: 20 * s,
            top: 25 * s,
            child: Row(
              children: [
                Text(
                  'Нийт үлдэгдэл',
                  style: inter(
                    size: 16 * s,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.32 * s,
                  ),
                ),
                SizedBox(width: 2 * s),
                Transform.flip(
                  flipY: true,
                  child: SvgPicture.asset(
                    'assets/svg/home/chevron_down.svg',
                    width: 18 * s,
                    height: 18 * s,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 333 * s,
            top: 35 * s,
            child: SvgPicture.asset(
              'assets/svg/home/dots.svg',
              width: 21 * s,
              height: 5 * s,
            ),
          ),
          Positioned(
            left: 20 * s,
            top: 52 * s,
            child: Text(
              Formatters.money(balance),
              style: inter(
                size: 30 * s,
                weight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1.5 * s,
              ),
            ),
          ),
          // Income (left)
          Positioned(
            left: 18 * s,
            top: 118 * s,
            child: Row(
              children: [
                _ArrowBadge(s: s, up: false),
                SizedBox(width: 6 * s),
                Text(
                  'Орлого',
                  style: inter(
                    size: 16 * s,
                    weight: FontWeight.w500,
                    color: AppColors.cardLabel,
                    letterSpacing: -0.8 * s,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20 * s,
            top: 148 * s,
            child: Text(Formatters.money(income), style: _amountStyle),
          ),
          // Expense (right)
          Positioned(
            right: 20 * s,
            top: 118 * s,
            child: Row(
              children: [
                _ArrowBadge(s: s, up: true),
                SizedBox(width: 18 * s),
                Text(
                  'Зарлага',
                  style: inter(
                    size: 18 * s,
                    weight: FontWeight.w500,
                    color: AppColors.cardLabel,
                    letterSpacing: -0.9 * s,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20 * s,
            top: 148 * s,
            child: Text(Formatters.money(expense), style: _amountStyle),
          ),
        ],
      ),
    );
  }

  TextStyle get _amountStyle => inter(
    size: 20 * s,
    weight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -1 * s,
  );
}

/// 24px translucent circle with an arrow (down = income, up = expense).
class _ArrowBadge extends StatelessWidget {
  const _ArrowBadge({required this.s, required this.up});

  final double s;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24 * s,
      height: 24 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Transform.flip(
        flipY: up,
        child: SvgPicture.asset(
          'assets/svg/home/arrow_down.svg',
          width: 18 * s,
          height: 18 * s,
        ),
      ),
    );
  }
}
