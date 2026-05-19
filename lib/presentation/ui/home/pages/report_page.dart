import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';
import 'package:fundlink_app/presentation/bloc/transaction_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedPeriod = 'Bulanan';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _selectedWeek = 1;
  bool _isExporting = false;

  final List<String> _periods = ['Mingguan', 'Bulanan', 'Tahunan'];

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

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final allList = state is TransactionsLoaded
            ? state.transactions
            : <TransactionModel>[];
        final list = filterTransactions(
          all: allList,
          period: _selectedPeriod,
          month: _selectedMonth,
          year: _selectedYear,
          week: _selectedWeek,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FF),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ekspor Transaksi',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Daftar Transaksi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada transaksi',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        itemCount: list.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _TxCard(tx: list[index]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isExporting ? null : _export,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Ekspor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      final txState = context.read<TransactionBloc>().state;
      final allList = txState is TransactionsLoaded
          ? txState.transactions
          : <TransactionModel>[];
      final list = filterTransactions(
        all: allList,
        period: _selectedPeriod,
        month: _selectedMonth,
        year: _selectedYear,
        week: _selectedWeek,
      );
      final totalIn = list
          .where((t) => t.isIncome)
          .fold(0, (s, t) => s + t.amount);
      final totalOut = list
          .where((t) => !t.isIncome)
          .fold(0, (s, t) => s + t.amount);
      final dir = await getTemporaryDirectory();
      final rows = <List<dynamic>>[
        ['Tanggal', 'Keterangan', 'Kategori', 'Jenis', 'Nominal'],
        ...list.map(
          (t) => [
            t.transactionDate,
            t.description,
            t.category,
            t.isIncome ? 'Pemasukan' : 'Pengeluaran',
            t.isIncome ? t.amount : -t.amount,
          ],
        ),
        [],
        ['', '', '', 'Total Pemasukan', totalIn],
        ['', '', '', 'Total Pengeluaran', totalOut],
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final file = File(
        '${dir.path}/laporan_${_selectedPeriod}_${_selectedYear}_${_selectedMonth}_w$_selectedWeek.csv',
      );
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Laporan Transaksi $_selectedPeriod $_selectedWeek');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
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

class _TxCard extends StatelessWidget {
  final TransactionModel tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIn = tx.isIncome;
    return Container(
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
    );
  }
}
