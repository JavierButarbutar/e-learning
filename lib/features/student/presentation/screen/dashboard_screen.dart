import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../notifikasi/provider/notifikasi_provider.dart';
import '../../../mapel/provider/mapel_provider.dart';
import '../../../notifikasi/presentation/screens/notifikasi_screen.dart';
import '../../../mapel/presentation/screens/mapel_screen.dart';
import '../../../mapel/presentation/screens/materi_screen.dart';
import '../../../mapel/data/models/mapel_model.dart';
import '../../../mapel/data/models/progress_materi.dart';
import '../../../mapel/presentation/screens/detail_materi_screen.dart';
import '../../../../core/storage/shared_pref.dart';
import '../../../presensi/provider/presensi_provider.dart';
import '../../../kuis/presentation/screens/kuis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _MateriWithMapel {
  final MateriItem materi;
  final MapelModel mapel;

  const _MateriWithMapel({
    required this.materi,
    required this.mapel,
  });
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<MapelModel> _filteredMapel = [];
  List<_MateriWithMapel> _filteredMateri = [];

  bool _isSearching = false;
  bool _isLoadingSearch = false;

  String _name = 'User';
  String _initials = 'U';
  String _foto = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _loadUser();

    Future.microtask(() {
      context.read<PresensiProvider>().fetchActivePresensi();
      context.read<PresensiProvider>().fetchRiwayat();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchTopic(String keyword) async {
    final provider = context.read<MapelProvider>();

    keyword = keyword.toLowerCase().trim();

    if (keyword.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _isLoadingSearch = false;
        _filteredMapel = [];
        _filteredMateri = [];
      });

      return;
    }

    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
    });

    if (provider.mapel.isEmpty) {
      await provider.getMapel();
    }

    await provider.fetchAllMateri();

    final mapelResult = provider.mapel.where((m) {
      return m.nama.toLowerCase().contains(keyword) ||
          m.deskripsi.toLowerCase().contains(keyword);
    }).toList();

    List<_MateriWithMapel> materiResult = [];

    for (final mapel in provider.mapel) {
      final cached = provider.materiCache[mapel.id] ?? [];

      final matched = cached.where((materi) {
        return materi.judul
                .toLowerCase()
                .contains(keyword) ||
            (materi.konten ?? '')
                .toLowerCase()
                .contains(keyword) ||
            materi.nomor
                .toLowerCase()
                .contains(keyword);
      });

      materiResult.addAll(
        matched.map(
          (m) => _MateriWithMapel(
            materi: m,
            mapel: mapel,
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoadingSearch = false;
      _filteredMapel = mapelResult;
      _filteredMateri = materiResult;
    });
  }

  Future<void> _loadUser() async {
    final user = await SharedPref.getUser();

    if (!mounted) return;

    final name = user?['name'] as String? ?? 'User';

    setState(() {
      _name = name;
      _initials = _getInitials(name);
      _foto = user?['foto'] as String? ?? '';
    });
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'
          .toUpperCase();
    }

    return name.isNotEmpty
        ? name[0].toUpperCase()
        : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapelProvider>();
    final mapelList = provider.mapel;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  16, 20, 16, 16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // SEARCH BAR
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE8F5E9),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            const Color(0xFFB7DDB9),
                      ),
                    ),
                    child: TextField(
                      controller:
                          _searchController,
                      onChanged: (val) {
                        _debounce?.cancel();

                        if (val.trim().isEmpty) {
                          setState(() {
                            _isSearching =
                                false;
                            _isLoadingSearch =
                                false;
                            _filteredMapel =
                                [];
                            _filteredMateri =
                                [];
                          });

                          return;
                        }

                        _debounce = Timer(
                          const Duration(
                              milliseconds: 400),
                          () {
                            _searchTopic(val);
                          },
                        );
                      },
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color:
                            Color(0xFF1B5E20),
                      ),
                      decoration:
                          const InputDecoration(
                        border:
                            InputBorder.none,
                        icon: Icon(
                          Icons.search_rounded,
                          color: Color(
                              0xFF2E7D32),
                        ),
                        hintText:
                            'Cari mapel atau materi...',
                        hintStyle: TextStyle(
                          color:
                              Color(0xFF7AA87D),
                          fontFamily:
                              'Poppins',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // HASIL SEARCH
                  if (_isSearching) ...[
                    if (_isLoadingSearch)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                                vertical: 30),
                        child: Center(
                          child:
                              CircularProgressIndicator(
                            color: Color(
                                0xFF2E7D32),
                          ),
                        ),
                      )
                    else ...[
                      if (_filteredMapel
                              .isEmpty &&
                          _filteredMateri
                              .isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                                  vertical: 30),
                          child: Center(
                            child: Text(
                              'Tidak ada hasil ditemukan',
                              style: TextStyle(
                                color: Color(
                                    0xFF888888),
                                fontFamily:
                                    'Poppins',
                              ),
                            ),
                          ),
                        ),

                      // MAPEL
                      if (_filteredMapel
                          .isNotEmpty) ...[
                        const Text(
                          'Hasil Mata Pelajaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color: Color(
                                0xFF1A1A1A),
                            fontFamily:
                                'Poppins',
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        ..._filteredMapel.map(
                          (m) => _MapelCard(
                            mapel: m,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MateriScreen(
                                    mapel: m,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // MATERI
                      if (_filteredMateri
                          .isNotEmpty) ...[
                        const SizedBox(
                            height: 16),

                        const Text(
                          'Hasil Materi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            color: Color(
                                0xFF1A1A1A),
                            fontFamily:
                                'Poppins',
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        ..._filteredMateri.map(
                          (entry) =>
                              GestureDetector(
                            onTap: () {
                              if (entry.materi
                                      .type ==
                                  MateriType
                                      .kuis) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        KuisScreen(
                                      kuisId:
                                          int.parse(
                                        entry
                                            .materi
                                            .id,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailMateriScreen(
                                      item: entry
                                          .materi,
                                      namaMapel:
                                          entry
                                              .mapel
                                              .nama,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom: 10,
                              ),
                              padding:
                                  const EdgeInsets
                                      .all(14),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            14),
                                border: Border.all(
                                  color: const Color(
                                      0xFFEAEAEA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          entry
                                              .materi
                                              .judul,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                            fontFamily:
                                                'Poppins',
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                2),

                                        Text(
                                          entry
                                              .mapel
                                              .nama,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                11,
                                            color: Color(
                                                0xFF2E7D32),
                                            fontFamily:
                                                'Poppins',
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),

                                        if (entry
                                                .materi
                                                .konten !=
                                            null) ...[
                                          const SizedBox(
                                              height:
                                                  2),

                                          Text(
                                            entry
                                                .materi
                                                .konten!,
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  12,
                                              color:
                                                  Color(
                                                      0xFF777777),
                                              fontFamily:
                                                  'Poppins',
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons
                                        .chevron_right_rounded,
                                    color: Color(
                                        0xFFCCCCCC),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ],

                  // AKTIVITAS
                  if (!_isSearching &&
                      ProgressStore.aktivitas
                          .where(
                              (e) =>
                                  !e.isCompleted)
                          .isNotEmpty) ...[
                    const Text(
                      'Aktivitas terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF1A1A1A),
                        fontFamily:
                            'Poppins',
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...ProgressStore.aktivitas
                        .where(
                          (e) =>
                              !e.isCompleted,
                        )
                        .map(
                          (a) =>
                              _AktivitasCard(
                            mapel: a.mapel,
                            materi:
                                a.materi,
                            onLanjut: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailMateriScreen(
                                    item: a.item,
                                    namaMapel:
                                        a.mapel,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ],

                  // MAPEL UTAMA
                  if (!_isSearching) ...[
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'Mata Pelajaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w700,
                            color: Color(
                                0xFF1A1A1A),
                            fontFamily:
                                'Poppins',
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MapelScreen(
                                  standalone:
                                      true,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'LIHAT SEMUA ›',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color: Color(
                                  0xFF2E7D32),
                              fontFamily:
                                  'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (provider.isLoading)
                      const Center(
                        child: Padding(
                          padding:
                              EdgeInsets.all(
                                  20),
                          child:
                              CircularProgressIndicator(),
                        ),
                      )
                    else if (provider.error !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets
                                .all(20),
                        child: Text(
                          provider.error!,
                          style:
                              const TextStyle(
                            fontFamily:
                                'Poppins',
                          ),
                        ),
                      )
                    else
                      ...mapelList.take(3).map(
                        (m) => _MapelCard(
                          mapel: m,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MateriScreen(
                                  mapel: m,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context)
                .padding
                .top +
            16,
        20,
        20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo! $_name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    color: Colors.white,
                    fontFamily:
                        'Poppins',
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Selamat Datang di Aplikasi',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Color(0xB3FFFFFF),
                    fontFamily:
                        'Poppins',
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotifikasiScreen(),
                ),
              );

              if (context.mounted) {
                context
                    .read<
                        NotifikasiProvider>()
                    .loadNotifikasi(
                        refresh: true);
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: Colors.white
                        .withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons
                        .notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                Consumer<
                    NotifikasiProvider>(
                  builder:
                      (context, prov, _) {
                    if (prov.unreadCount ==
                        0) {
                      return const SizedBox
                          .shrink();
                    }

                    return Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        constraints:
                            const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      8),
                          border: Border.all(
                            color: const Color(
                                0xFF2E7D32),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          prov.unreadCount >
                                  99
                              ? '99+'
                              : '${prov.unreadCount}',
                          style:
                              const TextStyle(
                            fontSize: 9,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color:
                                Colors.white,
                            fontFamily:
                                'Poppins',
                          ),
                          textAlign:
                              TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color:
                    const Color(0xFFF5A623),
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: _foto.isNotEmpty
                  ? Image.network(
                      _foto,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return Center(
                          child: Text(
                            _initials,
                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color: Color(
                                  0xFF2E7D32),
                              fontFamily:
                                  'Poppins',
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        _initials,
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                          color: Color(
                              0xFF2E7D32),
                          fontFamily:
                              'Poppins',
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _AktivitasCard extends StatelessWidget {
  final String mapel;
  final String materi;
  final VoidCallback onLanjut;

  const _AktivitasCard({
    required this.mapel,
    required this.materi,
    required this.onLanjut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  mapel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF1A1A1A),
                    fontFamily:
                        'Poppins',
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  materi,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        Color(0xFF888888),
                    fontFamily:
                        'Poppins',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onLanjut,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF5A623),
                borderRadius:
                    BorderRadius.circular(
                        10),
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color: Colors.white,
                  fontFamily:
                      'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapelCard extends StatelessWidget {
  final MapelModel mapel;
  final VoidCallback onTap;

  const _MapelCard({
    required this.mapel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: mapel.iconBg,
                borderRadius:
                    BorderRadius.circular(
                        12),
              ),
              child: Icon(
                mapel.icon,
                color: mapel.iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    mapel.nama,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF1A1A1A),
                      fontFamily:
                          'Poppins',
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${mapel.jumlahMateri} Materi · ${mapel.jumlahProyek} Proyek',
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF888888),
                      fontFamily:
                          'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}