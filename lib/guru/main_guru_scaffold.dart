// lib/guru/main_guru_scaffold.dart

import 'package:flutter/material.dart';
import 'dashboard/dashboard_guru_screen.dart';
import 'profil/profil_guru_screen.dart';

class MainGuruScaffold extends StatefulWidget {
  const MainGuruScaffold({super.key});

  @override
  State<MainGuruScaffold> createState() => _MainGuruScaffoldState();
}

class _MainGuruScaffoldState extends State<MainGuruScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardGuruScreen(),
    ProfilGuruScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ),
          // Floating navbar — 2 item saja (Jadwal + Profil)
          Positioned(
            left: 40, right: 40, bottom: 16,
            child: _GuruNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuruNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GuruNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: 'Jadwal',
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profil',
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon,
    required this.label, required this.active, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(active ? activeIcon : icon,
            size: 24,
            color: active
                ? const Color(0xFF2E7D32)
                : const Color(0xFFBBBBBB)),
          const SizedBox(height: 4),
          Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFBBBBBB),
              fontFamily: 'Poppins',
            )),
        ]),
      ),
    );
  }
}