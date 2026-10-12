/// Satu slide banner iklan di Home. Seluruh tampilan banner (teks, tombol,
/// ilustrasi) sudah ada di dalam gambar, jadi cukup menunjuk ke file aset.
class PromoBannerItem {
  const PromoBannerItem({
    required this.id,
    required this.imageAsset,
    required this.aspectRatio,
    this.semanticLabel = 'Banner promo',
  });

  final String id;

  /// Path aset gambar penuh banner (PNG), mis. `assets/images/banner_x.png`.
  final String imageAsset;

  /// Lebar ÷ tinggi gambar asli (piksel). Dipakai agar tinggi banner pas
  /// dengan gambar tanpa terpotong atau gepeng.
  final double aspectRatio;

  /// Deskripsi untuk pembaca layar (accessibility).
  final String semanticLabel;
}

/// Data banner dummy. Untuk menambah banner: simpan PNG di `assets/images/`,
/// lalu tambahkan satu `PromoBannerItem` di bawah (isi aspectRatio = lebar÷tinggi).
const List<PromoBannerItem> mockBanners = [
  PromoBannerItem(
    id: 'bnr-001',
    imageAsset: 'assets/images/banner_performance.png',
    aspectRatio: 731 / 149,
    semanticLabel: 'Performance review kini dapat dilakukan di Mobile App',
  ),
  PromoBannerItem(
    id: 'bnr-002',
    imageAsset: 'assets/images/banner_ewa.png',
    aspectRatio: 731 / 149,
    semanticLabel: 'Earned Wage Access dari Mekari Flex',
  ),
];