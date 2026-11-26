import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Grey pill with a sliding white indicator under the selected label
/// (Wallet: Гүйлгээнүүд / Хүлээгдэж буй, Connect Wallet: Картууд / Аккаунт).
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.s,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final double s;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final fraction = 1 / labels.length;
    return Container(
      height: 48 * s,
      padding: EdgeInsets.symmetric(horizontal: 5 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: AppColors.segmentBackground,
        borderRadius: BorderRadius.circular(40 * s),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              labels.length == 1 ? 0 : -1 + 2 * selected / (labels.length - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: fraction,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40 * s),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: inter(
                            size: 14 * s,
                            weight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
