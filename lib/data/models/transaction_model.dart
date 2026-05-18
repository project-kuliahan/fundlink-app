class TransactionModel {
  final int id;
  final String type;
  final int amount;
  final String category;
  final String description;
  final String transactionDate;
  final String createdAt;
  final String? imageUrl;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.transactionDate,
    required this.createdAt,
    this.imageUrl,
  });

  bool get isIncome => type == 'pemasukan';

  static int _toInt(dynamic v) =>
      v == null ? 0 : (num.tryParse(v.toString()) ?? 0).toInt();

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _toInt(json['id']),
      type: json['type'] ?? 'pemasukan',
      amount: _toInt(json['amount']),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      transactionDate: json['transaction_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
