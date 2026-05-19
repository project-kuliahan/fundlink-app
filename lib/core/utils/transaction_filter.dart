import 'package:fundlink_app/data/models/transaction_model.dart';

List<TransactionModel> filterTransactions({
  required List<TransactionModel> all,
  required String period,
  required int month,
  required int year,
  required int week,
}) {
  return all.where((t) {
    final parts = t.transactionDate.split('-');
    if (parts.length < 3) return false;
    final y = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final d = int.tryParse(parts[2]) ?? 0;
    switch (period) {
      case 'Tahunan':
        return y == year;
      case 'Mingguan':
        if (y != year || m != month) return false;
        return ((d - 1) ~/ 7) + 1 == week;
      default: // Bulanan
        return y == year && m == month;
    }
  }).toList()
    ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
}
