class TransactionModel {
  static const String _assetBaseUrl = 'https://bahamud.my.id';

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

  static String? _readImageUrl(Map<String, dynamic> json) {
    final value =
        json['attachment_url'] ??
        json['attachment_path'] ??
        json['attachment'] ??
        json['image_url'] ??
        json['image_path'] ??
        json['imageUrl'] ??
        json['image'] ??
        json['photo'] ??
        json['photo_url'] ??
        json['photo_path'] ??
        json['proof_image'] ??
        json['proof_image_url'] ??
        json['bukti'] ??
        json['bukti_url'] ??
        json['receipt'] ??
        json['receipt_url'] ??
        json['file'] ??
        json['file_url'] ??
        json['file_path'];

    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty || raw == 'null') return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('//')) return 'https:$raw';
    if (raw.startsWith('/')) return '$_assetBaseUrl$raw';

    final path = raw
        .replaceFirst(RegExp(r'^public/'), '')
        .replaceFirst(RegExp(r'^storage/'), '');
    return '$_assetBaseUrl/storage/$path';
  }

  static String _toDateStr(dynamic v) {
    if (v == null) return '';
    final s = v.toString();
    // Strip time part from ISO datetime e.g. "2026-05-19T00:00:00.000000Z"
    return s.contains('T') ? s.split('T').first : s;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: _toInt(json['id']),
      type: json['type'] ?? 'pemasukan',
      amount: _toInt(json['amount']),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      transactionDate: _toDateStr(json['transaction_date']),
      createdAt: json['created_at'] ?? '',
      imageUrl: _readImageUrl(json),
    );
  }
}
