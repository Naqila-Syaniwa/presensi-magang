import 'dart:async';

import 'package:flutter/material.dart';
import 'package:presensimagang/features/home/data/promo_banner_item.dart';

/// Carousel banner iklan di Home. Tiap slide adalah gambar penuh
/// ([PromoBannerItem.imageAsset]); slide berikutnya sedikit mengintip di
/// kanan, geser manual atau otomatis tiap 4 detik. Tinggi carousel menyesuaikan
/// rasio gambar slide yang sedang tampil.
///
/// Pemakaian di HomeScreen (Dev A): `const PromoBanner()`.
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key, this.items = mockBanners});

  final List<PromoBannerItem> items;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  static const double _viewportFraction = 0.92;
  static const double _gap = 8;

  final PageController _controller =
      PageController(viewportFraction: _viewportFraction);
  Timer? _autoPlay;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    if (widget.items.length > 1) {
      _autoPlay = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_controller.hasClients) return;
        final next = (_current + 1) % widget.items.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double get _page {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? _current.toDouble();
    }
    return _current.toDouble();
  }

  /// Tinggi untuk lebar slide [pageWidth] pada posisi geser [page]
  /// (diinterpolasi antar dua slide agar transisi mulus).
  double _heightFor(double pageWidth, double page) {
    final items = widget.items;
    final last = items.length - 1;
    final lo = page.floor().clamp(0, last).toInt();
    final hi = (lo + 1).clamp(0, last).toInt();
    final t = (page - lo).clamp(0.0, 1.0);
    final hLo = 1 / items[lo].aspectRatio;
    final hHi = 1 / items[hi].aspectRatio;
    return pageWidth * (hLo + (hHi - hLo) * t);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth * _viewportFraction - _gap;

        return AnimatedBuilder(
          animation: _controller,
          // PageView dibangun sekali; hanya tinggi pembungkus yang berubah.
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.items.length,
            onPageChanged: (i) => _current = i,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: _gap),
              child: _BannerSlide(item: widget.items[index]),
            ),
          ),
          builder: (context, child) => SizedBox(
            height: _heightFor(pageWidth, _page),
            child: child,
          ),
        );
      },
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.item});

  final PromoBannerItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: item.semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          item.imageAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _BannerPlaceholder(),
        ),
      ),
    );
  }
}

/// Tampil bila file gambar banner tidak ditemukan.
class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE6E8EC),
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: Color(0xFF9A9A9F), size: 32),
      ),
    );
  }
}