import 'package:flutter/material.dart';
import '../../features/student/presentation/screen/dashboard_screen.dart';
import '../../features/mapel/presentation/screens/mapel_screen.dart';
import '../../features/presensi/presentation/screens/presensi_scan_screen.dart';
import '../../features/riwayat/presentation/screens/riwayat_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // ✅ FIX: PresensiScreen DIHAPUS dari list ini.
  // Hanya 4 screen yang masuk IndexedStack.
  // Index mapping: 0=Dashboard, 1=Mapel, 2=Riwayat, 3=Profile
  final List<Widget> _screens = const [
    DashboardScreen(),
    MapelScreen(),
    RiwayatScreen(),
    ProfileScreen(),
  ];

  // ✅ Buka PresensiScreen via Navigator.push
  // → widget baru dibuat HANYA saat tombol ditekan
  // → kamera aktif HANYA saat halaman presensi terbuka
  // → otomatis dispose saat kembali ke dashboard
  void _openPresensi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PresensiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double reservedBottom = 92;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Konten layar — 4 screen saja, tanpa Presensi
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
              onTap: (i) {
                if (i == 2) {
                  // ✅ Index 2 = tombol Presensi → push, jangan setState
                  _openPresensi();
                  return;
                }
                // Remap index karena slot 2 (Presensi) di-skip di _screens:
                // tap 0 → _screens[0] Dashboard
                // tap 1 → _screens[1] Mapel
                // tap 2 → openPresensi (handled above)
                // tap 3 → _screens[2] Riwayat
                // tap 4 → _screens[3] Profile
                final mapped = i > 2 ? i - 1 : i;
                setState(() => _currentIndex = mapped);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Floating Navbar — tidak ada perubahan visual
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
    _NavData(icon: Icons.person_outlined,           activeIcon: Icons.person_rounded,            label: 'Profile'),
  ];

  // ✅ Mapping: currentIndex dari _screens (0-3) → highlight index di navbar (0-4)
  // _screens[0]=Dashboard → navbar[0]
  // _screens[1]=Mapel     → navbar[1]
  // _screens[2]=Riwayat   → navbar[3]
  // _screens[3]=Profile   → navbar[4]
  // navbar[2]=Presensi    → tidak pernah "active" karena push, bukan tab
  int _navbarIndex(int screensIndex) {
    if (screensIndex >= 2) return screensIndex + 1;
    return screensIndex;
  }

  @override
  Widget build(BuildContext context) {
    const double protrude = 22;
    const double pillHeight = 64;
    const double totalHeight = pillHeight + protrude;

    final activeNavbar = _navbarIndex(currentIndex);

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Pill putih
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
                  final active = i == activeNavbar;

                  // Slot tengah — tombol presensi
                  if (item.isCenter) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 26),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('Presensi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  // Presensi tidak pernah "active" sebagai tab
                                  color: const Color(0xFF888888),
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

          // Tombol presensi menonjol
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