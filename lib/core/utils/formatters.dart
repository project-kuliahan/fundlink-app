String formatRupiah(int amount) {
  final abs = amount.abs();
  final str = abs.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'Rp $str,00';
}

String compactRupiah(int value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(0)}M';
  } else if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(0)}JT';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}RB';
  }
  return value.toString();
}
