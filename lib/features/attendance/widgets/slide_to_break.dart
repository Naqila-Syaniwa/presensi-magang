import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';

/// Slider "Slide to start break": geser tombol cangkir ke kanan sampai ujung
/// untuk memicu [onCompleted]; bila dilepas sebelum ujung, tombol kembali.
/// Mengetuk slider juga memicu [onCompleted] (aksi sebenarnya menyusul).
class SlideToBreak extends StatefulWidget {
  const SlideToBreak({
    super.key,
    required this.onCompleted,
    this.label = 'Slide to start break',
  });

  final VoidCallback onCompleted;
  final String label;

  @override
  State<SlideToBreak> createState() => _SlideToBreakState();
}

class _SlideToBreakState extends State<SlideToBreak> {
  static const double _height = 48;
  static const double _thumbWidth = 56;

  double _dx = 0;
  bool _dragging = false;

  void _release(double maxDx) {
    final done = maxDx > 0 && _dx >= maxDx * 0.85;
    setState(() {
      _dragging = false;
      _dx = 0;
    });
    if (done) widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDx = (constraints.maxWidth - _thumbWidth)
            .clamp(0.0, double.infinity)
            .toDouble();
        final progress = maxDx == 0 ? 0.0 : (_dx / maxDx).clamp(0.0, 1.0);

        return Semantics(
          button: true,
          label: widget.label,
          onTap: widget.onCompleted,
          child: GestureDetector(
            onTap: widget.onCompleted,
            onHorizontalDragStart: (_) => setState(() => _dragging = true),
            onHorizontalDragUpdate: (d) => setState(() {
              _dx = (_dx + d.delta.dx).clamp(0.0, maxDx).toDouble();
            }),
            onHorizontalDragEnd: (_) => _release(maxDx),
            onHorizontalDragCancel: () => _release(0),
            child: Container(
              height: _height,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(_height / 2),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: _thumbWidth),
                      child: Center(
                        child: Opacity(
                          opacity: 1 - progress,
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration:
                        _dragging ? Duration.zero : const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    left: _dx,
                    top: 0,
                    bottom: 0,
                    width: _thumbWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_height / 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.coffee_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
