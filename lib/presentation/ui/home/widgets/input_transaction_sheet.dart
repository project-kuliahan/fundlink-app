import 'package:flutter/material.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/presentation/ui/home/pages/transaction_input_page.dart';

void showInputTransactionSheet(
  BuildContext context, {
  bool isPemasukan = true,
}) {
  context.push(TransactionInputPage(isPemasukan: isPemasukan));
}
