import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/presensi/data/models/presensi_model.dart';
import '../../../../features/presensi/provider/presensi_provider.dart';

// ─────────────────────────────────────────────────────────────
// RIWAYAT SCREEN
//
// Menampilkan riwayat presensi dari API dengan status:
//   • hadir     → masuk tepat waktu
//   • terlambat → masuk dalam batas keterlambatan (≤30 menit)
//   • alfa      → melewati batas keterlambatan, tidak presensi
//   • sakit     → diubah guru (tidak hadir karena sakit)
//   • izin      → diubah guru (tidak hadir karena izin)
//
// Status 'alfa', 'sakit', 'izin' dapat diubah oleh guru di sisi web.
// Statistik diambil dari RekapModel via fetchRekap().
// ─────────────────────────────────────────────────────────────
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch data pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PresensiProvider>();
      provider.fetchRiwayat();
      provider.fetchRekap();
    });

    // Infinite scroll: load more saat scroll mendekati bawah
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PresensiProvider>().loadMoreRiwayat();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<PresensiProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Header hijau ──
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF2E7D32),
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 12, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Riwayat Presensi',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Poppins')),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(Icons.filter_list_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Statistik akademik dari RekapModel ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _StatistikCard(
                    rekap: provider.rekap,
                    isLoading: provider.isLoadingRekap,
                  ),
                ),
              ),

              // ── Loading riwayat pertama ──
              if (provider.riwayatStatus == PresensiStatus.loading &&
                  provider.riwayat.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32)),
                    ),
                  ),
                )

              // ── Error state ──
              else if (provider.riwayatStatus == PresensiStatus.error &&
                  provider.riwayat.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Color(0xFFBBBBBB), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          provider.riwayatError ??
                              'Gagal memuat riwayat presensi.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                              fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              provider.fetchRiwayat(),
                          child: const Text('Coba Lagi',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                )

              // ── Empty state ──
              else if (provider.riwayat.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_outlined,
                            color: Color(0xFFBBBBBB), size: 48),
                        SizedBox(height: 12),
                        Text('Belum ada riwayat presensi.',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888888),
                                fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                )

              // ── Daftar riwayat dikelompokkan per bulan ──
              else
                ..._buildGroupedSliver(provider.riwayat),

              // ── Load more indicator ──
              if (provider.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  // ── Kelompokkan item riwayat per bulan ──────────────────────
  List<SliverToBoxAdapter> _buildGroupedSliver(
      List<RiwayatItemModel> items) {
    // Kelompokkan berdasarkan "Bulan Tahun" dari field tanggal
    final Map<String, List<RiwayatItemModel>> grouped = {};

    for (final item in items) {
      final key = _formatBulan(item.tanggal);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins')),
              const SizedBox(height: 10),
              ...entry.value
                  .map((item) => _RiwayatCard(item: item))
                  .toList(),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Format tanggal ISO (2024-01-15) → "Januari 2024"
  String _formatBulan(String? tanggal) {
    if (tanggal == null) return 'Tanggal tidak diketahui';
    try {
      final dt = DateTime.parse(tanggal);
      const bulanList = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${bulanList[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return tanggal;
    }
  }
}

// ── Card statistik dari RekapModel ───────────────────────────
class _StatistikCard extends StatelessWidget {
  final RekapModel? rekap;
  final bool isLoading;

  const _StatistikCard({required this.rekap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STATISTIK AKADEMIK',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rekap != null
                          ? '${rekap!.persentaseKehadiran.toStringAsFixed(0)}%'
                          : '-',
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          height: 1.0),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text('Kehadiran',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFF5A623),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins')),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Chip: Hadir, Terlambat, Alfa
                // Hadir + Terlambat = kehadiran aktual
                // Alfa = melewati batas keterlambatan
                // Chip: Hadir, Terlambat, Alfa
                Row(
                  children: [
                    _StatChip(
                      label: '${rekap?.hadir ?? 0}',
                      sub: 'Hadir',
                    ),

                    const SizedBox(width: 10),

                    _StatChip(
                      label: '${rekap?.terlambat ?? 0}',
                      sub: 'Terlambat',
                    ),

                    const SizedBox(width: 10),

                    _StatChip(
                      label: '${rekap?.alpha ?? 0}',
                      sub: 'Alfa',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _ExtraInfo(
                      icon: Icons.sick_outlined,
                      label: 'Sakit',
                      // Sakit & izin diubah langsung oleh guru
                      value: '${rekap?.sakit ?? 0} Pertemuan',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExtraInfo(
                      icon: Icons.event_available_outlined,
                      label: 'Izin',
                      value: '${rekap?.izin ?? 0} Pertemuan',
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, sub;
  const _StatChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins')),
        const SizedBox(height: 2),
        Text(sub,
            style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
                fontFamily: 'Poppins')),
      ]),
    );
  }
}

class _ExtraInfo extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ExtraInfo(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins')),
              ]),
        ),
      ]),
    );
  }
}

// ── Card satu item riwayat dari API ──────────────────────────
class _RiwayatCard extends StatelessWidget {
  final RiwayatItemModel item;
  const _RiwayatCard({required this.item});

  // Status dari API: hadir | terlambat | alfa | sakit | izin
  Color get _statusColor {
    switch (item.statusKehadiran) {
      case 'hadir':
        return const Color(0xFF2E7D32);
      case 'terlambat':
        return const Color(0xFFF5A623);
      case 'sakit':
        return const Color(0xFF1E88E5);
      case 'izin':
        return const Color(0xFF8E24AA);
      default: // alfa
        return const Color(0xFFE53935);
    }
  }

  Color get _statusBg {
    switch (item.statusKehadiran) {
      case 'hadir':
        return const Color(0xFFE8F5E9);
      case 'terlambat':
        return const Color(0xFFFFF3E0);
      case 'sakit':
        return const Color(0xFFE3F2FD);
      case 'izin':
        return const Color(0xFFF3E5F5);
      default: // alfa
        return const Color(0xFFFFEBEE);
    }
  }

  IconData get _statusIcon {
    switch (item.statusKehadiran) {
      case 'hadir':
        return Icons.check_circle_outline_rounded;
      case 'terlambat':
        return Icons.access_time_rounded;
      case 'sakit':
        return Icons.local_hospital_outlined;
      case 'izin':
        return Icons.info_outline_rounded;
      default: // alfa
        return Icons.cancel_outlined;
    }
  }

  // Label badge: sesuaikan teks tampilan
  String get _statusLabel {
    switch (item.statusKehadiran) {
      case 'hadir':
        return 'HADIR';
      case 'terlambat':
        return 'TERLAMBAT';
      case 'sakit':
        return 'SAKIT';
      case 'izin':
        return 'IZIN';
      default:
        return 'ALFA';
    }
  }

  // Format tanggal ISO → "Senin, 15 Jan 2024"
  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    try {
      final dt = DateTime.parse(tanggal);
      const hariList = [
        'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
      ];
      const bulanList = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final hari = hariList[dt.weekday - 1];
      final bulan = bulanList[dt.month - 1];
      return '$hari, ${dt.day} $bulan ${dt.year}';
    } catch (_) {
      return tanggal;
    }
  }

  // Format waktu "07:15:00" → "07:15 WIB"
  String _formatWaktu(String? waktu) {
    if (waktu == null) return '-';
    try {
      final parts = waktu.split(':');
      return '${parts[0]}:${parts[1]} WIB';
    } catch (_) {
      return waktu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        // Icon status
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_statusIcon, color: _statusColor, size: 22),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTanggal(item.tanggal),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        fontFamily: 'Poppins')),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 12, color: Color(0xFF888888)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.mapel,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontFamily: 'Poppins'),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.person_outlined,
                      size: 12, color: Color(0xFF888888)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.guru,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontFamily: 'Poppins'),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                // Tampilkan waktu masuk jika ada (hadir / terlambat)
                if (item.waktuPresensi != null) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text('Masuk: ${_formatWaktu(item.waktuPresensi)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                            fontFamily: 'Poppins')),
                  ]),
                ],
                // Keterangan dari guru (jika ada, misal alasan sakit/izin)
                if (item.keterangan != null &&
                    item.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.notes_rounded,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(item.keterangan!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                              fontFamily: 'Poppins'),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ],
              ]),
        ),

        // Badge status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_statusLabel,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.3)),
        ),
      ]),
    );
  }
}