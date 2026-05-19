import 'package:flutter/material.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/data/models/transaction_model.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transactionModel;

  const TransactionDetailPage({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {
    final t = transactionModel;
    final isIn = t.isIncome;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isIn
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: TransactionTypeIcon(
                          isIncome: isIn,
                          size: 30,
                          color: isIn ? AppColors.primary : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.category,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isIn ? "Pemasukan" : "Pengeluaran"} · ${t.transactionDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatRupiah(t.amount),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isIn ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: t.imageUrl != null && t.imageUrl!.isNotEmpty
                          ? Image.network(
                              t.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (_, e, s) => _photoPlaceholder(),
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            )
                          : _photoPlaceholder(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keterangan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.description.isNotEmpty
                                ? t.description
                                : 'Tidak ada keterangan',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kembali',
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
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 48,
          color: AppColors.grey.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          'Foto Bukti',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
