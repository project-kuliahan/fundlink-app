class DashboardModel {
  final int saldo;
  final int totalPemasukan;
  final int totalPengeluaran;
  final int unitId;
  final String unitName;

  DashboardModel({
    required this.saldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.unitId,
    required this.unitName,
  });

  static int _toInt(dynamic v) =>
      v == null ? 0 : (num.tryParse(v.toString()) ?? 0).toInt();

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      saldo: _toInt(json['saldo']),
      totalPemasukan: _toInt(json['total_pemasukan']),
      totalPengeluaran: _toInt(json['total_pengeluaran']),
      unitId: _toInt(json['unit']?['id']),
      unitName: json['unit']?['name'] ?? '',
    );
  }
}
