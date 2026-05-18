import 'package:flutter/material.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/presentation/ui/home/widgets/input_transaction_sheet.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      {
        'label': 'Catat\nPemasukan',
        'icon': Icons.add_circle_outline,
        'color': AppColors.primary,
        'onTap': () => showInputTransactionSheet(context, isPemasukan: true),
      },
      {
        'label': 'Catat\nPengeluaran',
        'icon': Icons.remove_circle_outline,
        'color': Colors.red,
        'onTap': () => showInputTransactionSheet(context, isPemasukan: false),
      },
      {
        'label': 'Laporan\nBulanan',
        'icon': Icons.bar_chart_outlined,
        'color': AppColors.primary,
        'onTap': () {},
      },
      {
        'label': 'Anggaran',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.primary,
        'onTap': () {},
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: menus.map((menu) {
          return _MenuItem(
            label: menu['label'] as String,
            icon: menu['icon'] as IconData,
            color: menu['color'] as Color,
            onTap: menu['onTap'] as VoidCallback,
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
