import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/widgets/shimmer.dart';

/// Skeleton ClockCard: bentuknya mengikuti ClockCard asli (lokasi, jam,
/// tanggal, status, tombol) agar tidak ada lompatan layout saat data muncul.
class ClockCardSkeleton extends StatelessWidget {
  const ClockCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Shimmer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SkeletonBox(width: 20, height: 20, radius: 10),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 14),
                      SizedBox(height: 6),
                      SkeletonBox(width: 220, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(child: SkeletonBox(width: 180, height: 40, radius: 8)),
            SizedBox(height: 8),
            Center(child: SkeletonBox(width: 150, height: 14)),
            SizedBox(height: 12),
            Center(child: SkeletonBox(width: 160, height: 26, radius: 20)),
            SizedBox(height: 16),
            SkeletonBox(height: 48),
          ],
        ),
      ),
    );
  }
}
