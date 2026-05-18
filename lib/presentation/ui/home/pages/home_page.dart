import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';
import 'package:fundlink_app/presentation/bloc/auth_bloc.dart';
import 'package:fundlink_app/presentation/bloc/auth_event.dart';
import 'package:fundlink_app/presentation/bloc/auth_state.dart';
import 'package:fundlink_app/presentation/bloc/dashboard_bloc.dart';
import 'package:fundlink_app/presentation/bloc/transaction_bloc.dart';
import 'package:fundlink_app/presentation/ui/home/pages/notification_page.dart';
import 'package:fundlink_app/presentation/ui/home/pages/transaction_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthEvent());
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<TransactionBloc>().add(LoadTransactions(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final name = authState is AuthSuccess
                        ? authState.user.name
                        : 'User';
                    return Text(
                      'Selamat Datang, $name 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    );
                  },
                ),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => context.push(const NotificationPage()),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Scrollable body ──────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(LoadDashboard());
                context.read<TransactionBloc>().add(
                  LoadTransactions(refresh: true),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Cards ─────────────────────────────────
                    BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        final saldo = state is DashboardLoaded
                            ? state.dashboard.saldo
                            : 0;
                        final totalIn = state is DashboardLoaded
                            ? state.dashboard.totalPemasukan
                            : 0;
                        final totalOut = state is DashboardLoaded
                            ? state.dashboard.totalPengeluaran
                            : 0;
                        final loading =
                            state is DashboardLoading ||
                            state is DashboardInitial;

                        return Column(
                          children: [
                            // Saldo card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Saldo',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  loading
                                      ? const SizedBox(
                                          height: 36,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          formatRupiah(saldo),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pemasukan & Pengeluaran
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    label: 'Pemasukan',
                                    value: loading
                                        ? '...'
                                        : formatRupiah(totalIn),
                                    gradientColors: const [
                                      Color(0xFFEDF1FC),
                                      Color(0xFFFAFBFF),
                                    ],
                                    textColor: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryCard(
                                    label: 'Pengeluaran',
                                    value: loading
                                        ? '...'
                                        : formatRupiah(totalOut),
                                    gradientColors: const [
                                      Color(0xFFFFEBEB),
                                      Color(0xFFFFFAFA),
                                    ],
                                    textColor: Color(0xFFE53935),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // ── Transaksi Terbaru ─────────────────────
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoading ||
                            state is TransactionInitial) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final txs = state is TransactionsLoaded
                            ? state.transactions.take(8).toList()
                            : <TransactionModel>[];
                        if (txs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Belum ada transaksi',
                                style: TextStyle(color: AppColors.grey),
                              ),
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: txs.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, i) => _TxItem(
                              tx: txs[i],
                              onTap: () => context.push(
                                TransactionDetailPage(transactionModel: txs[i]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradientColors;
  final Color textColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TxItem extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onTap;

  const _TxItem({required this.tx, required this.onTap});

  String _formatDate(String d) {
    final parts = d.split('-');
    if (parts.length == 3) {
      const m = [
        '',
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
      final month = int.tryParse(parts[1]) ?? 0;
      return '${parts[2]},${m[month]} ${parts[0]}';
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              alignment: Alignment.centerLeft,
              child: TransactionTypeIcon(isIncome: tx.isIncome),
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
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(tx.transactionDate),
                    style: const TextStyle(fontSize: 10, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Text(
              formatRupiah(tx.amount),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
