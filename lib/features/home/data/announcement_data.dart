import 'package:presensimagang/features/home/data/announcement.dart';

/// Data pengumuman dummy (terbaru di atas). Dipakai AnnouncementSection.
final List<Announcement> mockAnnouncements = [
  Announcement(
    id: 'ann-001',
    title: 'Jadwal Libur Nasional dan Cuti Bersama Oktober 2026',
    date: DateTime(2026, 10, 6),
    summary: 'Cek daftar tanggal libur dan cuti bersama bulan ini.',
  ),
  Announcement(
    id: 'ann-002',
    title: 'Pembaruan Kebijakan Kerja Hybrid untuk Peserta Magang',
    date: DateTime(2026, 10, 3),
    summary: 'Ketentuan WFO dan WFH untuk peserta magang mulai bulan ini.',
  ),
  Announcement(
    id: 'ann-003',
    title: 'Pendaftaran Pelatihan Soft Skill Batch 3 Dibuka',
    date: DateTime(2026, 9, 29),
    summary: 'Kuota terbatas, daftar sebelum 15 Oktober 2026.',
  ),
  Announcement(
    id: 'ann-004',
    title: 'Pemeliharaan Sistem Presensi Akhir Pekan Ini',
    date: DateTime(2026, 9, 25),
    summary: 'Layanan dapat terganggu sementara pada Sabtu malam.',
  ),
  Announcement(
    id: 'ann-005',
    title: 'Penerimaan Slip Gaji dan Uang Saku Periode September',
    date: DateTime(2026, 9, 22),
    summary: 'Slip dapat diunduh mulai tanggal 25 setiap bulan.',
  ),
];