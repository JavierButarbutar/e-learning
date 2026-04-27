import 'package:flutter/material.dart';
import '../../home/dashboard_screen.dart';
import '../../mapel/mapel_screen.dart';
import '../../presensi/presensi_screen.dart';
import '../../riwayat/riwayat_screen.dart';
import '../../profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MapelScreen(),
    PresensiScreen(),
    RiwayatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Navbar pill 68px tinggi, floating 16px dari bawah layar
    // Total ruang yang perlu dicadangkan untuk konten = 68 + 16 + 8 = 92px
    const double reservedBottom = 92;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Konten layar — mengisi semua area minus ruang navbar
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: reservedBottom),
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ),

          // Floating navbar pill
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: _FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Floating Navbar
// Tombol Presensi menonjol ke atas menggunakan Stack bukan
// Transform.translate (Transform tidak menambah layout space
// sehingga menyebabkan overflow).
// ─────────────────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavData(icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard_rounded, label: 'Dashboard'),
    _NavData(icon: Icons.menu_book_outlined,        activeIcon: Icons.menu_book_rounded,        label: 'Mapel'),
    _NavData(icon: Icons.qr_code_scanner_rounded,  activeIcon: Icons.qr_code_scanner_rounded,  label: 'Presensi', isCenter: true),
    _NavData(icon: Icons.history_rounded,           activeIcon: Icons.history_rounded,           label: 'Riwayat'),
    _NavData(icon: Icons.person_outlined,         activeIcon: Icons.person_rounded,          label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Tinggi tombol presensi yang menonjol ke atas
    const double protrude = 22;
    const double pillHeight = 64;
    const double totalHeight = pillHeight + protrude;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Pill putih — berada di bawah
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: pillHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (i) {
                  final item = _items[i];
                  final active = i == currentIndex;

                  // Slot tengah kosong — diisi tombol menonjol via Stack
                  if (item.isCenter) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 26), // ruang untuk lingkaran
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('Presensi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF888888),
                                  fontFamily: 'Poppins',
                                )),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Item biasa
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            active ? item.activeIcon : item.icon,
                            size: 22,
                            color: active
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFBBBBBB),
                          ),
                          const SizedBox(height: 3),
                          Text(item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                              color: active
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFBBBBBB),
                              fontFamily: 'Poppins',
                            )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Tombol presensi menonjol — di atas pill menggunakan Stack Positioned
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E7D32),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenter;

  const _NavData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenter = false,
  });
}