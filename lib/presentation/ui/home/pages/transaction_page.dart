import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/presentation/bloc/transaction_bloc.dart';
import 'package:fundlink_app/presentation/ui/home/pages/report_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/transaction_detail_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/transaction_input_page.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Bulanan';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _selectedWeek = 1;
  bool _fabOpen = false;

  late final AnimationController _fabController;
  // FAB icon rotation: 0 → 0.125 turns = 45°
  late final Animation<double> _rotateAnim;
  // Staggered bounce for each menu item (bottom to top order: item0=Ekspor, item1=Pemasukan, item2=Pengeluaran)
  late final Animation<double> _item0Anim;
  late final Animation<double> _item1Anim;
  late final Animation<double> _item2Anim;

  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    // Staggered: item2 (Pengeluaran) first, then item1, then item0 — bottom to top
    _item2Anim = CurvedAnimation(
      parent: _fabController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _item1Anim = CurvedAnimation(
      parent: _fabController,
      curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
    );
    _item0Anim = CurvedAnimation(
      parent: _fabController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    );
    context.read<TransactionBloc>().add(LoadTransactions(refresh: true));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Widget _buildSecondDropdown() {
    if (_selectedPeriod == 'Tahunan') {
      final years = List.generate(5, (i) => DateTime.now().year - i);
      return _DropdownBox(
        value: _selectedYear.toString(),
        items: years.map((y) => y.toString()).toList(),
        onChanged: (v) => setState(() => _selectedYear = int.parse(v!)),
      );
    } else if (_selectedPeriod == 'Bulanan') {
      const months = [
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
      return _DropdownBox(
        value: months[_selectedMonth - 1],
        items: months,
        onChanged: (v) =>
            setState(() => _selectedMonth = months.indexOf(v!) + 1),
      );
    } else {
      final weeks = [
        'Minggu ke-1',
        'Minggu ke-2',
        'Minggu ke-3',
        'Minggu ke-4',
      ];
      return _DropdownBox(
        value: weeks[_selectedWeek - 1],
        items: weeks,
        onChanged: (v) => setState(() => _selectedWeek = weeks.indexOf(v!) + 1),
      );
    }
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    _fabOpen ? _fabController.forward() : _fabController.reverse();
  }

  void _closeFab() {
    setState(() => _fabOpen = false);
    _fabController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final List<TransactionModel> allTx = state is TransactionsLoaded
              ? state.transactions
              : [];
          final List<TransactionModel> transactions = filterTransactions(
            all: allTx,
            period: _selectedPeriod,
            month: _selectedMonth,
            year: _selectedYear,
            week: _selectedWeek,
          );

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DropdownBox(
                                value: _selectedPeriod,
                                items: _periods,
                                onChanged: (v) =>
                                    setState(() => _selectedPeriod = v!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: _buildSecondDropdown()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (state is TransactionLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (transactions.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Tidak ada transaksi',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _TxItem(tx: transactions[index]),
                      ),
                    ),
                ],
              ),
              if (_fabOpen)
                GestureDetector(
                  onTap: _closeFab,
                  child: Container(color: Colors.black.withValues(alpha: 0.15)),
                ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Menu items with staggered bounce
                    _AnimatedMenuItem(
                      animation: _item0Anim,
                      icon: Icons.upload_outlined,
                      label: 'Ekspor',
                      onTap: () {
                        _closeFab();
                        context.push(const ReportPage());
                      },
                    ),
                    const SizedBox(height: 12),
                    _AnimatedMenuItem(
                      animation: _item1Anim,
                      icon: Icons.trending_up_rounded,
                      label: 'Pemasukan',
                      onTap: () {
                        _closeFab();
                        context.push(
                          const TransactionInputPage(isPemasukan: true),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _AnimatedMenuItem(
                      animation: _item2Anim,
                      icon: Icons.trending_down_rounded,
                      label: 'Pengeluaran',
                      onTap: () {
                        _closeFab();
                        context.push(
                          const TransactionInputPage(isPemasukan: false),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // FAB button
                    GestureDetector(
                      onTap: _toggleFab,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _fabOpen ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: RotationTransition(
                          turns: _rotateAnim,
                          child: Icon(
                            Icons.add,
                            color: _fabOpen ? AppColors.primary : Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedMenuItem extends StatelessWidget {
  final Animation<double> animation;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedMenuItem({
    required this.animation,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - v)),
          child: Opacity(
            opacity: v,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.stroke),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey,
            size: 20,
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TxItem extends StatelessWidget {
  final TransactionModel tx;
  const _TxItem({required this.tx});

  String _formatDate(String d) {
    final parts = d.split('-');
    if (parts.length == 3) {
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final month = int.tryParse(parts[1]) ?? 0;
      return '${parts[2]} ${months[month]} ${parts[0]}';
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final isIn = tx.isIncome;
    return InkWell(
      onTap: () => context.push(TransactionDetailPage(transactionModel: tx)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isIn
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: TransactionTypeIcon(
                  isIncome: isIn,
                  color: isIn ? AppColors.primary : Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.description.isNotEmpty ? tx.description : tx.category,
                    style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIn ? '+' : '-'}${formatRupiah(tx.amount)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isIn ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx.transactionDate),
                  style: const TextStyle(fontSize: 10, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
