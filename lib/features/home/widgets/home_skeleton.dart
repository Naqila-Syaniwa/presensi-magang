import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _color = ColorTween(
      begin: AppColors.border,
      end: AppColors.background,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box(Color color, double width, double height, {double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _circle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _header(Color color) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _circle(color, 40),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(color, 90, 10),
              const SizedBox(height: 8),
              _box(color, 140, 14),
            ],
          ),
          const Spacer(),
          _circle(color, 24),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _gridRow(Color color) {
    return SizedBox(
      height: 92,
      child: Row(
        children: List.generate(
          4,
          (_) => Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(color, 44, 44, radius: 12),
                const SizedBox(height: 8),
                _box(color, 52, 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color, 
      builder: (context, _) {
        final color = _color.value ?? AppColors.border;
        return Column(
          children: [
            _header(color),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [_gridRow(color), _gridRow(color)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
