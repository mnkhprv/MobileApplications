import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// What the front card shows. Built by the screen from either the form the
/// user is typing in (live preview) or the newest linked card.
class CardFace {
  const CardFace({
    required this.holder,
    required this.number,
    required this.expiry,
  });
  final String holder;

  /// Already grouped, e.g. "••••  ••••  ••••  8075".
  final String number;

  /// "MM/YY".
  final String expiry;
}

/// Two stacked debit cards from Connect Wallet (Figma "44" 1:2771 behind,
/// "Cards" 1:2795 in front). Size: 324 x 241 design px.
class CardStack extends StatelessWidget {
  const CardStack({super.key, required this.s, required this.face});

  final double s;
  final CardFace face;

  static TextStyle _mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    double? spacing,
  }) => TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: const ['Inter'],
    fontSize: size,
    fontWeight: weight,
    color: Colors.white,
    letterSpacing: spacing,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 324 * s,
      height: 241 * s,
      child: Stack(
        children: [
          // Back card — only its top strip shows.
          Positioned(
            left: 20 * s,
            top: 0,
            width: 284 * s,
            height: 183 * s,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20 * s),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF57E3B9), Color(0xFF027F87)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20 * s,
                      top: 19 * s,
                      width: 42 * s,
                      height: 13.5 * s,
                      child: SvgPicture.asset(
                        'assets/svg/connect/visa.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      right: 20 * s,
                      top: 15 * s,
                      child: Text(
                        'Mono',
                        style: _mono(13.69 * s, weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Front card.
          Positioned(
            left: 0,
            top: 32 * s,
            width: 324 * s,
            height: 209 * s,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23 * s),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1, -0.11),
                    end: Alignment(1, 0.11),
                    colors: [Color(0xFF2A7777), Color(0xFF06B6B6)],
                    stops: [0.11, 1.16],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -39 * s,
                      top: 29 * s,
                      width: 413.4 * s,
                      height: 415.7 * s,
                      child: SvgPicture.asset(
                        'assets/svg/connect/card_shape.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      left: 24 * s,
                      top: 21 * s,
                      child: Text(
                        'Debit\nCard',
                        style: _mono(11.4 * s, weight: FontWeight.w600),
                      ),
                    ),
                    Positioned(
                      right: 20 * s,
                      top: 21 * s,
                      child: Text(
                        'Mono',
                        style: _mono(13.69 * s, weight: FontWeight.w600),
                      ),
                    ),
                    Positioned(
                      left: 24 * s,
                      top: 74 * s,
                      width: 26 * s,
                      height: 20 * s,
                      child: SvgPicture.asset(
                        'assets/svg/connect/chip_front.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      left: 12 * s,
                      right: 12 * s,
                      top: 128 * s,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          face.number,
                          style: _mono(
                            13.69 * s,
                            weight: FontWeight.w700,
                            spacing: 4.56 * s,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24 * s,
                      right: 90 * s,
                      bottom: 31 * s,
                      child: Text(
                        face.holder.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _mono(13.69 * s),
                      ),
                    ),
                    Positioned(
                      right: 21 * s,
                      bottom: 31 * s,
                      child: Text(face.expiry, style: _mono(13.69 * s)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
