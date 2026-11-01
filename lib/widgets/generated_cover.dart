import 'dart:math';
import 'package:flutter/material.dart';

/// Cover digambar dari judul lagu. Judul sama + variant sama = tampilan sama.
/// Ganti [variant] buat dapet tampilan lain dari judul yang sama.
class GeneratedCover extends StatelessWidget {
  final String title;
  final int variant;

  const GeneratedCover({super.key, required this.title, this.variant = 0});

  int _seed() {
    var h = 17;
    for (final c in title.trim().toLowerCase().codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h + variant * 7919;
  }

  @override
  Widget build(BuildContext context) {
    final rnd = Random(_seed());

    final hue1 = rnd.nextDouble() * 360;
    final hue2 = (hue1 + 40 + rnd.nextDouble() * 80) % 360;
    final c1 = HSLColor.fromAHSL(1, hue1, 0.75, 0.45).toColor();
    final c2 = HSLColor.fromAHSL(1, hue2, 0.80, 0.25).toColor();
    final angle = rnd.nextDouble() * 2 * pi;

    // Posisi & ukuran lingkaran dekorasi
    final circles = List.generate(4, (_) {
      return (
        align: Alignment(rnd.nextDouble() * 2 - 1, rnd.nextDouble() * 2 - 1),
        scale: 0.3 + rnd.nextDouble() * 0.5,
        opacity: 0.08 + rnd.nextDouble() * 0.14,
      );
    });

    return LayoutBuilder(
      builder: (context, box) {
        final s = box.maxWidth;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(cos(angle), sin(angle)),
                  end: Alignment(-cos(angle), -sin(angle)),
                  colors: [c1, c2],
                ),
              ),
            ),
            for (final c in circles)
              Align(
                alignment: c.align,
                child: Container(
                  width: s * c.scale,
                  height: s * c.scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(c.opacity),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(s * 0.08),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title.trim(),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: s * 0.13,
                    height: 1.15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
