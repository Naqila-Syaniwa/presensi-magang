import 'dart:async';

import 'package:flutter/material.dart';
import 'package:presensimagang/core/app_colors.dart';
import 'package:presensimagang/features/home/data/announcement.dart';
import 'package:presensimagang/features/home/data/announcement_data.dart';
import 'package:presensimagang/widgets/shimmer.dart';

/// Bagian "Announcements" di Home: judul + "View all", lalu daftar card
/// horizontal (gambar, judul, tanggal).
///
/// - Data default: [mockAnnouncements] (dummy Dev B).
/// - Skeleton shimmer tampil singkat ([loadingDuration]) sebelum data muncul.
/// - Jika daftar kosong, tampil empty state "No announcement yet".
class AnnouncementSection extends StatefulWidget {
  const AnnouncementSection({
    super.key,
    this.announcements,
    this.loadingDuration = const Duration(milliseconds: 900),
  });

  /// Null = pakai [mockAnnouncements]. Beri `[]` untuk empty state.
  final List<Announcement>? announcements;

  /// Lama skeleton tampil. `Duration.zero` = langsung tampil tanpa skeleton.
  final Duration loadingDuration;

  @override
  State<AnnouncementSection> createState() => _AnnouncementSectionState();
}

class _AnnouncementSectionState extends State<AnnouncementSection> {
  static const double _cardWidth = 200;
  static const double _imageHeight = 110;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  Timer? _loadingTimer;
  late bool _isLoading = widget.loadingDuration > Duration.zero;

  @override
  void initState() {
    super.initState();
    if (_isLoading) {
      _loadingTimer = Timer(widget.loadingDuration, () {
        if (!mounted) return;
        setState(() => _isLoading = false);
      });
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  static String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  void _showViewAll() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Halaman semua pengumuman belum tersedia')),
      );
  }

  /// Tinggi list mengikuti skala font sistem agar teks tidak overflow.
  double _listHeight(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.6);
    return _imageHeight + 20 + 58 * scale;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.announcements ?? mockAnnouncements;
    final listHeight = _listHeight(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Announcements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B2559),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('View all', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          if (_isLoading)
            _SkeletonList(
              height: listHeight,
              cardWidth: _cardWidth,
              imageHeight: _imageHeight,
            )
          else if (items.isEmpty)
            const _EmptyState()
          else
            SizedBox(
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _AnnouncementCard(
                  item: items[i],
                  dateText: _formatDate(items[i].date),
                  width: _cardWidth,
                  imageHeight: _imageHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.item,
    required this.dateText,
    required this.width,
    required this.imageHeight,
  });

  final Announcement item;
  final String dateText;
  final double width;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAMBAR: isi `imageAsset` pada data (mis. assets/images/ann_1.png).
          // Bila null / file belum ada, tampil placeholder.
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: item.imageAsset == null
                ? const _ImagePlaceholder()
                : Image.asset(
                    item.imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.lavender,
      child: Center(
        child: Icon(Icons.campaign_outlined, color: AppColors.accent, size: 36),
      ),
    );
  }
}

/// Skeleton: 3 card palsu dengan tinggi sama seperti list asli.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList({
    required this.height,
    required this.cardWidth,
    required this.imageHeight,
  });

  final double height;
  final double cardWidth;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Shimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: imageHeight, radius: 12),
                const SizedBox(height: 12),
                const SkeletonBox(height: 14),
                const SizedBox(height: 6),
                const SkeletonBox(width: 120, height: 14),
                const SizedBox(height: 8),
                const SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          // ASET: ikon catatan biru → assets/images/announcement_empty.png
          Image.asset(
            'assets/images/announcement_empty.png',
            width: 64,
            height: 64,
            errorBuilder: (_, _, _) => const Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Color(0xFF1F4FD8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No announcement yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Company announcements will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}