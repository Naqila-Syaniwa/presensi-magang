/// Model pengumuman/berita untuk bagian pengumuman di Home.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.date,
    this.summary = '',
    this.imageAsset,
  });

  final String id;
  final String title;
  final DateTime date;

  /// Ringkasan singkat (opsional, untuk halaman detail kelak).
  final String summary;

  /// Path aset gambar, mis. `assets/images/announcement_1.png`.
  /// Null berarti UI menampilkan gambar pengganti (placeholder).
  final String? imageAsset;
}