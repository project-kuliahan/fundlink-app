import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fundlink_app/core/core.dart';
import 'package:fundlink_app/presentation/bloc/transaction_bloc.dart';

class TransactionInputPage extends StatefulWidget {
  final bool isPemasukan;
  const TransactionInputPage({super.key, this.isPemasukan = true});

  @override
  State<TransactionInputPage> createState() => _TransactionInputPageState();
}

class _TransactionInputPageState extends State<TransactionInputPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late bool _isIncome;
  String _selectedCategory = 'Pilih kategori transaksi';
  late DateTime _selectedDate;
  bool _isSubmitting = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;

  final List<String> _incomeCategories = const [
    'Donasi',
    'Iuran',
    'Pendapatan Usaha',
    'Bantuan',
    'Lainnya',
  ];
  final List<String> _expenseCategories = const [
    'Operasional',
    'Gaji',
    'Transportasi',
    'Perawatan',
    'Konsumsi',
    'Lainnya',
  ];

  List<String> get _categories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.isPemasukan;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  String get _dateDisplay {
    const months = [
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
    return '${_selectedDate.day} ${months[_selectedDate.month]} ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera', style: TextStyle(fontSize: 14)),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri', style: TextStyle(fontSize: 14)),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!_isValidImageSize(bytes.lengthInBytes)) {
      _showImageSizeError(bytes.lengthInBytes);
      return;
    }

    setState(() {
      _imageFile = picked;
      _imageBytes = bytes;
    });
  }

  void _submit() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nominal harus diisi')));
      return;
    }
    if (_selectedCategory == 'Pilih kategori transaksi') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori harus dipilih')));
      return;
    }
    if (_imageBytes != null && !_isValidImageSize(_imageBytes!.lengthInBytes)) {
      _showImageSizeError(_imageBytes!.lengthInBytes);
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<TransactionBloc>().add(
      CreateTransaction(
        data: {
          'type': _isIncome ? 'pemasukan' : 'pengeluaran',
          'amount': amount,
          'category': _selectedCategory,
          'description': _noteController.text.isNotEmpty
              ? _noteController.text
              : _selectedCategory,
          'transaction_date': _dateStr,
        },
        imageBytes: _imageBytes,
        imageName: _imageFile?.name,
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isIncome ? 'Pemasukan' : 'Pengeluaran'} berhasil disimpan',
        ),
      ),
    );
  }

  bool _isValidImageSize(int bytes) {
    return bytes <= AppLimits.maxUploadImageBytes;
  }

  void _showImageSizeError(int bytes) {
    final sizeKb = (bytes / 1024).ceil();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ukuran gambar $sizeKb KB, maksimal ${AppLimits.maxUploadImageKb} KB',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  const Text(
                    'Input Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Toggle Pemasukan / Pengeluaran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _ToggleTab(
                      label: 'Pemasukan',
                      isSelected: _isIncome,
                      onTap: () => setState(() {
                        _isIncome = true;
                        _selectedCategory = 'Pilih kategori transaksi';
                      }),
                    ),
                    _ToggleTab(
                      label: 'Pengeluaran',
                      isSelected: !_isIncome,
                      onTap: () => setState(() {
                        _isIncome = false;
                        _selectedCategory = 'Pilih kategori transaksi';
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nominal
                    const _Label('Nominal'),
                    const SizedBox(height: 6),
                    _InputField(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nominal',
                          hintStyle: TextStyle(
                            color: AppColors.grey,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Kategori
                    const _Label('Kategori'),
                    const SizedBox(height: 6),
                    _PickerField(
                      value: _selectedCategory,
                      placeholder: 'Pilih kategori transaksi',
                      onTap: () => _showPicker(
                        title: 'Pilih Kategori',
                        values: _categories,
                        onSelected: (v) =>
                            setState(() => _selectedCategory = v),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tanggal
                    const _Label('Tanggal Transaksi'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dateDisplay,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Foto Bukti
                    const _Label('Foto Bukti (maks. 250KB)'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageBytes != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(_imageBytes!, fit: BoxFit.cover),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _imageFile = null;
                                        _imageBytes = null;
                                      }),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tambahkan Gambar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const _Label('Keterangan'),
                    const SizedBox(height: 6),
                    _InputField(
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Tulis keterangan (opsional)...',
                          hintStyle: TextStyle(
                            color: AppColors.grey,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.stroke),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPicker({
    required String title,
    required List<String> values,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionSheet(title: title, values: values),
    );
    if (result != null) onSelected(result);
  }
}

// ── Reusable widgets ──────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.grey,
    ),
  );
}

class _InputField extends StatelessWidget {
  final Widget child;
  const _InputField({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.stroke),
    ),
    child: child,
  );
}

class _PickerField extends StatelessWidget {
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  const _PickerField({
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == placeholder;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: isPlaceholder ? AppColors.grey : AppColors.black,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.grey,
          ),
        ),
      ),
    ),
  );
}

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> values;

  const _OptionSheet({required this.title, required this.values});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...values.map(
          (v) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(v, style: const TextStyle(fontSize: 14)),
            onTap: () => Navigator.pop(context, v),
          ),
        ),
      ],
    ),
  );
}
