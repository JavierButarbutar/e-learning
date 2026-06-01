import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/storage/shared_pref.dart';
import '../../data/models/jadwal_model.dart';
import '../../../notifikasi/presentation/screens/notifikasi_guru_screen.dart';
import '../../../notifikasi/provider/notifikasi_guru_provider.dart';

class DashboardGuruScreen extends StatefulWidget {
  const DashboardGuruScreen({super.key});

  @override
  State<DashboardGuruScreen> createState() => _DashboardGuruScreenState();
}

class _DashboardGuruScreenState extends State<DashboardGuruScreen> {
  late String _selectedHari;
  late List<String> _weekDays;
  late DateTime _today;

  bool _isLoading = true;
  String? _error;

  Map<String, List<JadwalItem>> _jadwalMap = {};

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedHari = namaHari(_today);
    _weekDays = _buildWeekDays();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await SharedPref.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = "Token tidak ditemukan";
        });
        return;
      }

      final result = await ApiService.getJadwalGuru(token: token);

      if (result.isEmpty) {
        setState(() {
          _error = "Data jadwal kosong";
        });
        return;
      }

      setState(() {
        _jadwalMap = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  List<String> _buildWeekDays() {
    final monday = _today.subtract(Duration(days: _today.weekday - 1));
    return List.generate(5, (i) => namaHari(monday.add(Duration(days: i))));
  }

  List<JadwalItem> get _jadwalHariIni => _jadwalMap[_selectedHari] ?? [];

  JadwalItem? get _jadwalAktif {
    for (final j in _jadwalHariIni) {
      if (j.sedangBerlangsung) return j;
    }
    return null;
  }

  String _tanggalHariIni() {
    const hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${hari[_today.weekday - 1]}, ${_today.day} ${bulan[_today.month - 1]} ${_today.year}';
  }

  @override
  Widget build(BuildContext context) {
    final jadwal = _jadwalHariIni;
    final aktif = _jadwalAktif;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context, aktif),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : RefreshIndicator(
                    onRefresh: _loadJadwal,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _DayPicker(
                            weekDays: _weekDays,
                            today: _today,
                            selected: _selectedHari,
                            onSelect: (h) => setState(() => _selectedHari = h),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'MATA PELAJARAN BERIKUTNYA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF888888),
                                  letterSpacing: 0.8,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (jadwal.isEmpty)
                            _EmptyJadwal()
                          else
                            ...jadwal.map((j) => _JadwalCard(item: j)),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JadwalItem? aktif) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 14,
        20,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'SMKN 1 TAMANAN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotifikasiGuruScreen(),
                    ),
                  );

                  if (context.mounted) {
                    context.read<NotifikasiGuruProvider>().loadNotifikasi(
                      refresh: true,
                    );
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    Consumer<NotifikasiGuruProvider>(
                      builder: (context, prov, _) {
                        if (prov.unreadCount == 0)
                          return const SizedBox.shrink();
                        return Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              prov.unreadCount > 99
                                  ? '99+'
                                  : '${prov.unreadCount}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Jadwal Mengajar',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 4),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _tanggalHariIni(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.72),
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (aktif != null) ...[
            _ActiveClassBanner(item: aktif),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ActiveClassBanner extends StatelessWidget {
  final JadwalItem item;
  const _ActiveClassBanner({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF5A623),
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saatnya mengajar di',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${item.namaKelas} ${item.mataPelajaran}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Sedang Berlangsung',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
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

class _DayPicker extends StatelessWidget {
  final List<String> weekDays;
  final DateTime today;
  final String selected;
  final ValueChanged<String> onSelect;

  const _DayPicker({
    required this.weekDays,
    required this.today,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: List.generate(weekDays.length, (i) {
          final hari = weekDays[i];
          final date = monday.add(Duration(days: i));
          final isToday = hari == namaHari(today);
          final isSel = hari == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(hari),
              child: Column(
                children: [
                  Text(
                    singkatanHari(hari),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSel
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF888888),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      border: isToday && !isSel
                          ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSel
                              ? Colors.white
                              : isToday
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF1A1A1A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _JadwalCard extends StatelessWidget {
  final JadwalItem item;
  const _JadwalCard({required this.item});

  bool get _isRapat => item.mataPelajaran == 'Rapat Guru';
  Color get _iconBg =>
      _isRapat ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
  Color get _iconColor =>
      _isRapat ? const Color(0xFFF5A623) : const Color(0xFF2E7D32);
  IconData get _icon =>
      _isRapat ? Icons.groups_outlined : Icons.menu_book_outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.jamMulai,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.jamSelesai,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaKelas,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.mataPelajaran,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                    fontFamily: 'Poppins',
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

class _EmptyJadwal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: Color(0xFF2E7D32),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada jadwal hari ini',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nikmati hari libur mengajarmu!',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
