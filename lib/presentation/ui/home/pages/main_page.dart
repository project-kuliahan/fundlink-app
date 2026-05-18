import 'package:flutter/material.dart';
import 'package:fundlink_app/presentation/ui/home/pages/home_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/transaction_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/stats_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    TransactionPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                currentIndex: _currentIndex,
                icon: Icons.home_outlined,
                label: 'Beranda',
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                index: 1,
                currentIndex: _currentIndex,
                icon: Icons.receipt_long_outlined,
                label: 'Transaksi',
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                index: 2,
                currentIndex: _currentIndex,
                icon: Icons.bar_chart_outlined,
                label: 'Statistik',
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                index: 3,
                currentIndex: _currentIndex,
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xff3660e0);
    const inactiveColor = Color(0xffA7AEC1);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: isActive ? 1.08 : 1,
                  child: Icon(
                    icon,
                    size: 19,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
