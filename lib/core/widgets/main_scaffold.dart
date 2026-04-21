import 'package:flutter/material.dart';
import '/home/dashboard_screen.dart';
import '/mapel/mapel_screen.dart';
import '/presensi/presensi_screen.dart';
import '/riwayat/riwayat_screen.dart';
import '/settings/settings_screen.dart';

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
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_rounded,        label: 'Dashboard', index: 0, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.menu_book_rounded,   label: 'Mapel',     index: 1, current: currentIndex, onTap: onTap),
          _NavItem(isBarcode: true,                 label: 'Presensi',  index: 2, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.calendar_month_outlined, label: 'Riwayat', index: 3, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Settings', index: 4, current: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final bool isBarcode;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    this.icon,
    this.isBarcode = false,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            active
                ? Container(
                    width: 40, height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isBarcode ? Icons.qr_code_scanner_rounded : icon,
                      color: Colors.white, size: 18),
                  )
                : Icon(
                    isBarcode ? Icons.qr_code_scanner_rounded : icon,
                    color: const Color(0xFFBBBBBB), size: 22),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? const Color(0xFF2E7D32) : const Color(0xFFBBBBBB),
                fontFamily: 'Poppins',
              )),
          ],
        ),
      ),
    );
  }
}