import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';
import 'package:fundlink_app/presentation/bloc/dashboard_bloc.dart';
import 'package:fundlink_app/presentation/bloc/transaction_bloc.dart';
import 'package:fundlink_app/presentation/ui/home/pages/transaction_detail_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedPeriod = 'Bulanan';
  int _selectedMonth = DateTime.now().month; // 1-12
  int _selectedYear = DateTime.now().year;
  int _selectedWeek = 1; // 1-4

  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<TransactionBloc>().add(LoadTransactions(refresh: true));
  }

  // ── Filter logic ────────────────────────────────────────────
  List<TransactionModel> _filter(List<TransactionModel> all) {
    return all.where((t) {
      final parts = t.transactionDate.split('-');
      if (parts.length < 3) {
        return false;
      }
      final y = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final d = int.tryParse(parts[2]) ?? 0;

      switch (_selectedPeriod) {
        case 'Tahunan':
          return y == _selectedYear;
        case 'Mingguan':
          if (y != _selectedYear || m != _selectedMonth) {
            return false;
          }
          // week 1=1-7, 2=8-14, 3=15-21, 4=22-end
          final weekOfDay = ((d - 1) ~/ 7) + 1;
          return weekOfDay == _selectedWeek;
        default: // Bulanan
          return y == _selectedYear && m == _selectedMonth;
      }
    }).toList();
  }

  // ── Bar chart data ───────────────────────────────────────────
  List<BarChartGroupData> _buildBarGroups(List<TransactionModel> filtered) {
    if (_selectedPeriod == 'Tahunan') {
      // Group by month (0-11)
      final inM = List<double>.filled(12, 0);
      final outM = List<double>.filled(12, 0);
      for (final t in filtered) {
        final m = (int.tryParse(t.transactionDate.split('-')[1]) ?? 1) - 1;
        if (t.isIncome) {
          inM[m] += t.amount / 1000000;
        } else {
          outM[m] += t.amount / 1000000;
        }
      }
      return List.generate(12, (i) => _group(i, inM[i], outM[i]));
    } else if (_selectedPeriod == 'Bulanan') {
      // Group by week of month (0-3)
      final inW = List<double>.filled(4, 0);
      final outW = List<double>.filled(4, 0);
      for (final t in filtered) {
        final d = int.tryParse(t.transactionDate.split('-')[2]) ?? 1;
        final w = ((d - 1) ~/ 7).clamp(0, 3);
        if (t.isIncome) {
          inW[w] += t.amount / 1000000;
        } else {
          outW[w] += t.amount / 1000000;
        }
      }
      return List.generate(4, (i) => _group(i, inW[i], outW[i]));
    } else {
      // Mingguan: group by day of week (0-6)
      final inD = List<double>.filled(7, 0);
      final outD = List<double>.filled(7, 0);
      for (final t in filtered) {
        final parts = t.transactionDate.split('-');
        if (parts.length < 3) {
          continue;
        }
        final dt = DateTime.tryParse(t.transactionDate);
        if (dt == null) {
          continue;
        }
        final dow = dt.weekday - 1; // 0=Mon..6=Sun
        if (t.isIncome) {
          inD[dow] += t.amount / 1000000;
        } else {
          outD[dow] += t.amount / 1000000;
        }
      }
      return List.generate(7, (i) => _group(i, inD[i], outD[i]));
    }
  }

  BarChartGroupData _group(int x, double inVal, double outVal) =>
      BarChartGroupData(
        x: x,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: inVal,
            width: 8,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(3),
          ),
          BarChartRodData(
            toY: outVal,
            width: 8,
            color: AppColors.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );

  List<String> get _bottomLabels {
    if (_selectedPeriod == 'Tahunan') {
      return [
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
    } else if (_selectedPeriod == 'Bulanan') {
      return ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4'];
    } else {
      return ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    }
  }

  double _maxY(List<TransactionModel> txs) {
    double max = 1;
    for (final t in txs) {
      final v = t.amount / 1000000;
      if (v > max) {
        max = v;
      }
    }
    return (max * 1.3).ceilToDouble();
  }

  // ── Second dropdown options ──────────────────────────────────
  Widget _buildSecondDropdown() {
    if (_selectedPeriod == 'Tahunan') {
      final years = List.generate(5, (i) => DateTime.now().year - i);
      return _DropdownBox<int>(
        value: _selectedYear,
        items: years,
        label: (y) => y.toString(),
        onChanged: (v) => setState(() => _selectedYear = v!),
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
      return _DropdownBox<int>(
        value: _selectedMonth,
        items: List.generate(12, (i) => i + 1),
        label: (m) => months[m - 1],
        onChanged: (v) => setState(() => _selectedMonth = v!),
      );
    } else {
      return _DropdownBox<int>(
        value: _selectedWeek,
        items: [1, 2, 3, 4],
        label: (w) => 'Minggu ke-$w',
        onChanged: (v) => setState(() => _selectedWeek = v!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Statistik',
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
                      child: _DropdownBox<String>(
                        value: _selectedPeriod,
                        items: _periods,
                        label: (v) => v,
                        onChanged: (v) => setState(() => _selectedPeriod = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSecondDropdown()),
                  ],
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, txState) {
                return BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, dashState) {
                    final allTxs = txState is TransactionsLoaded
                        ? txState.transactions
                        : <TransactionModel>[];
                    final filtered = _filter(allTxs);

                    final totalIn = filtered
                        .where((t) => t.isIncome)
                        .fold(0, (s, t) => s + t.amount);
                    final totalOut = filtered
                        .where((t) => !t.isIncome)
                        .fold(0, (s, t) => s + t.amount);

                    final loading =
                        txState is TransactionLoading ||
                        txState is TransactionInitial;

                    return loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Metric cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MetricCard(
                                        label: 'Pemasukan',
                                        value: compactRupiah(totalIn),
                                        isIncome: true,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _MetricCard(
                                        label: 'Pengeluaran',
                                        value: compactRupiah(totalOut),
                                        isIncome: false,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Bar chart
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.bar_chart_rounded,
                                            size: 16,
                                            color: AppColors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Trend $_selectedPeriod',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ClipRect(
                                        child: AspectRatio(
                                          aspectRatio: 2.0,
                                          child: filtered.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    'Tidak ada data',
                                                    style: TextStyle(
                                                      color: AppColors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )
                                              : BarChart(
                                                BarChartData(
                                                  alignment: BarChartAlignment
                                                      .spaceAround,
                                                  maxY: _maxY(filtered),
                                                  borderData: FlBorderData(
                                                    show: false,
                                                  ),
                                                  gridData: FlGridData(
                                                    show: false,
                                                  ),
                                                  titlesData: FlTitlesData(
                                                    leftTitles:
                                                        const AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                showTitles:
                                                                    false,
                                                              ),
                                                        ),
                                                    topTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: false,
                                                      ),
                                                    ),
                                                    rightTitles:
                                                        const AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                showTitles:
                                                                    false,
                                                              ),
                                                        ),
                                                    bottomTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        getTitlesWidget: (val, _) {
                                                          final labels =
                                                              _bottomLabels;
                                                          final i = val.toInt();
                                                          if (i < 0 ||
                                                              i >=
                                                                  labels
                                                                      .length) {
                                                            return const SizedBox.shrink();
                                                          }
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 6,
                                                                ),
                                                            child: Text(
                                                              labels[i],
                                                              style: const TextStyle(
                                                                fontSize: 9,
                                                                color: AppColors
                                                                    .grey,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  barGroups: _buildBarGroups(
                                                    filtered,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _LegendDot(
                                            color: AppColors.primary,
                                            label: 'Pemasukan',
                                          ),
                                          const SizedBox(width: 16),
                                          _LegendDot(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                            label: 'Pengeluaran',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Transaction list
                                if (filtered.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        'Tidak ada transaksi',
                                        style: TextStyle(color: AppColors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  ...filtered.map(
                                    (t) => _TxItem(
                                      tx: t,
                                      onTap: () => context.push(
                                        TransactionDetailPage(
                                          transactionModel: t,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────

class _DropdownBox<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.label,
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
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey,
            size: 20,
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(label(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isIncome;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.isIncome,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: TransactionTypeIcon(
                isIncome: isIncome,
                size: 18,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.grey),
        ),
      ],
    );
  }
}

class _TxItem extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onTap;
  const _TxItem({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIn = tx.isIncome;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              alignment: Alignment.centerLeft,
              child: TransactionTypeIcon(isIncome: isIn),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    tx.transactionDate,
                    style: const TextStyle(fontSize: 10, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Text(
              formatRupiah(tx.amount),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isIn ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
