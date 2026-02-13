import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../../data/models/category.dart' as model;
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  // Düzenleme için gerekli parametre
  final Transaction? transactionToEdit;
  // Varsayılan başlangıç tarihi (Opsiyonel)
  final DateTime? initialDate;
  // Varsayılan işlem tipi (Opsiyonel)
  final TransactionType? initialType;

  const AddTransactionModal({super.key, this.transactionToEdit, this.initialDate, this.initialType});

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  
  // Varsayılan değerler
  RecurrenceRule _recurrence = RecurrenceRule.none;
  DateTime _selectedDate = DateTime.now();
  int? _installments;

  bool _isEndDateEnabled = false;
  DateTime _endDate = DateTime.now();
  String _selectedCategory = 'Genel';
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    // EĞER DÜZENLEME MODUNDAYSA VERİLERİ DOLDUR
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      _type = t.type;
      _selectedCategory = t.category;
      _selectedColor = Color(t.colorCode);
      _recurrence = t.recurrenceRule;
      _installments = t.installmentTotal;
      _selectedDate = t.date;
    } else {
      // YENİ EKLEME: Varsayılan tip
      if (widget.initialType != null) {
        _type = widget.initialType!;
      }
      
      // YENİ EKLEME: Varsayılan tarih mantığı
      if (widget.initialDate != null) {
        final now = DateTime.now();
        // Eğer gelen tarih bu ay ise, bugünü seç (saat farkı olmaksızın)
        if (widget.initialDate!.year == now.year && widget.initialDate!.month == now.month) {
          _selectedDate = now;
        } else {
          // Farklı bir ay ise, o ayın 1'ini (veya gelen tarihi) kullan
          _selectedDate = widget.initialDate!;
        }
      }
      _endDate = _selectedDate; // Bitiş tarihini de eşitle
    }
  }



  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final userCategories = ref.watch(categoriesProvider);
    final themeColor = _type == TransactionType.income ? AppTheme.incomeColor : AppTheme.expenseColor;
    final isEditing = widget.transactionToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tutamaç
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Başlık
            Center(
              child: Text(
                isEditing ? 'İşlemi Düzenle' : 'Yeni İşlem Ekle',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gelir/Gider Toggle
            Row(
              children: [
                Expanded(child: Container(
                  height: 45,
                  decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(25)),
                  child: Row(children: [
                      _buildTypeToggle(TransactionType.income, 'Gelir', AppTheme.incomeColor),
                      _buildTypeToggle(TransactionType.expense, 'Gider', AppTheme.expenseColor),
                  ]),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Tutar
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                suffixText: settings.selectedCurrency,
                suffixStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              autofocus: !isEditing,
            ),
            
            // İşlem Adı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'İşlem Başlığı',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tarih Seçici (Başlangıç)
            _buildSelectionRow(
              label: 'Başlangıç Tarihi',
              value: DateFormat('d MMM yyyy', 'tr_TR').format(_selectedDate),
              icon: Icons.calendar_today,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(data: AppTheme.darkTheme, child: child!),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    if (_endDate.isBefore(_selectedDate)) {
                      _endDate = _selectedDate;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            // Sonlu Ödeme Switch
            if (!isEditing) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text('Sonlu Ödeme', style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    Switch(
                      value: _isEndDateEnabled,
                      onChanged: (val) => setState(() => _isEndDateEnabled = val),
                      activeColor: AppTheme.futureColor,
                    ),
                  ],
                ),
              ),
            if (_isEndDateEnabled && !isEditing) ...[
              const SizedBox(height: 12),
              _buildSelectionRow(
                label: 'Bitiş Tarihi',
                value: DateFormat('d MMM yyyy', 'tr_TR').format(_endDate),
                icon: Icons.calendar_month,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _selectedDate,
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(data: AppTheme.darkTheme, child: child!),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
              const SizedBox(height: 12),
              _buildSelectionRow(
                label: 'Taksit Sayısı',
                value: '${_calculateIterations(_selectedDate, _endDate, _recurrence)}',
                icon: Icons.list_alt,
                onTap: () {}, // Salt okunur
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 4),
                child: const Text('Bitiş tarihiyle senkronizedir', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
            ],
            const SizedBox(height: 12),

            // Kategori Listesi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kategori', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.futureColor),
                  label: const Text('Ekle', style: TextStyle(color: AppTheme.futureColor, fontSize: 13)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: userCategories.map((cat) {
                  final isSelected = _selectedCategory == cat.name;
                  final catColor = Color(cat.colorCode);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        _showEditCategoryDialog(cat);
                      } else {
                        setState(() {
                          _selectedCategory = cat.name;
                          _selectedColor = catColor;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? Border.all(color: catColor, width: 1) : Border.all(color: Colors.white10, width: 1),
                        boxShadow: isSelected ? [
                          BoxShadow(color: catColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: catColor.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
                              ]
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.name, 
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade300,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Gelişmiş Tekrar Seçici (Sadece yeni eklerken aktif edelim)
            if (!isEditing) 
              _buildSelectionRow(
                label: 'Tekrar',
                value: _getRecurrenceLabel(_recurrence),
                icon: Icons.repeat,
                onTap: _showRecurrencePicker,
              ),

            // Taksit (Sadece Giderse ve Yeni Eklemedeyse)
            if (_type == TransactionType.expense && _recurrence == RecurrenceRule.none && !isEditing) ...[
              const SizedBox(height: 12),
              _buildSelectionRow(
                label: 'Taksit Sayısı',
                value: _installments?.toString() ?? 'Yok',
                icon: Icons.credit_card,
                onTap: _showInstallmentPicker,
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _save(ref, settings.activeGroupId),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(isEditing ? 'Güncelle' : 'Kaydet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('İptal', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    String newCatName = '';
    Color selectedColor = Colors.blue;
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, 
      Colors.pink, Colors.teal, Colors.amber, Colors.indigo, Colors.brown,
      Colors.cyan, Colors.lime, Colors.lightGreen, Colors.deepOrange, Colors.deepPurple,
      Colors.blueGrey, Colors.grey, Colors.black, Colors.lightBlue, Colors.redAccent
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Yeni Kategori', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (val) => newCatName = val,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Kategori Adı',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((c) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedColor == c ? Colors.white : Colors.transparent, width: 2),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () {
                if (newCatName.trim().isNotEmpty) {
                  ref.read(categoriesProvider.notifier).addCategory(
                    model.Category(name: newCatName.trim(), colorCode: selectedColor.value)
                  );
                  setState(() {
                    _selectedCategory = newCatName.trim();
                    _selectedColor = selectedColor;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.futureColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }



  void _showEditCategoryDialog(model.Category category) {
    Color selectedColor = Color(category.colorCode);
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, 
      Colors.pink, Colors.teal, Colors.amber, Colors.indigo, Colors.brown,
      Colors.cyan, Colors.lime, Colors.lightGreen, Colors.deepOrange, Colors.deepPurple,
      Colors.blueGrey, Colors.grey, Colors.black, Colors.lightBlue, Colors.redAccent
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('${category.name} Rengini Düzenle', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((c) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedColor == c ? Colors.white : Colors.transparent, width: 2),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () {
                // Creates a copy with new color but keeps the same name (which acts as ID basically)
                final updated = category.copyWith(colorCode: selectedColor.value);
                
                // 1. Kategoriyi güncelle
                ref.read(categoriesProvider.notifier).updateCategory(updated);
                
                // 2. Bu kategoriye ait TÜM işlemlerin rengini güncelle
                ref.read(transactionsProvider.notifier).updateCategoryColor(updated.name, updated.colorCode);
                
                // Eğer seçili olan kategoriyi güncellediysek, UI'daki seçili rengi de güncelle
                if (_selectedCategory == category.name) {
                  setState(() {
                    _selectedColor = selectedColor;
                  });
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.futureColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Güncelle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Yardımcı Metotlar ---

  Widget _buildTypeToggle(TransactionType type, String label, Color color) {
    final isSelected = _type == type;
    final isEditing = widget.transactionToEdit != null;
    
    return Expanded(
      child: GestureDetector(
        onTap: isEditing ? null : () => setState(() => _type = type),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(isEditing ? 0.7 : 1.0) : Colors.transparent, 
            borderRadius: BorderRadius.circular(25)
          ),
          alignment: Alignment.center,
          child: Text(
            label, 
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey, 
              fontWeight: FontWeight.bold,
              decoration: isEditing && !isSelected ? TextDecoration.lineThrough : null,
            )
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionRow({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Text(value, style: const TextStyle(color: AppTheme.futureColor, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getRecurrenceLabel(RecurrenceRule rule) {
    switch (rule) {
      case RecurrenceRule.none: return 'Bir kez';
      case RecurrenceRule.daily: return 'Her gün';
      case RecurrenceRule.weekly: return 'Her hafta';
      case RecurrenceRule.biweekly: return 'Her 2 haftada bir';
      case RecurrenceRule.monthly: return 'Her ay';
      case RecurrenceRule.quarterly: return 'Her 3 ayda bir';
      case RecurrenceRule.semiannually: return 'Her 6 ayda bir';
      case RecurrenceRule.yearly: return 'Her yıl';
      case RecurrenceRule.firstWorkday: return 'Her ayın ilk iş günü';
      case RecurrenceRule.lastWorkday: return 'Her ayın son iş günü';
      default: return 'Bir kez';
    }
  }

  void _showRecurrencePicker() {
    final options = [
      RecurrenceRule.monthly,
      RecurrenceRule.none,
      RecurrenceRule.weekly,
      RecurrenceRule.biweekly,
      RecurrenceRule.firstWorkday,
      RecurrenceRule.lastWorkday,
      RecurrenceRule.daily,
      RecurrenceRule.quarterly,
      RecurrenceRule.semiannually,
      RecurrenceRule.yearly,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionPickerModal<RecurrenceRule>(
        title: 'Tekrar',
        options: options.map((r) => MapEntry(r, _getRecurrenceLabel(r))).toList(),
        selectedValue: _recurrence,
        onSelected: (val) => setState(() => _recurrence = val),
      ),
    );
  }

  void _showInstallmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionPickerModal<int?>(
        title: 'Taksit Sayısı',
        options: [null, 2, 3, 6, 9, 12, 18, 24, 36].map((i) => MapEntry(i, i == null ? 'Yok' : '$i Taksit')).toList(),
        selectedValue: _installments,
        onSelected: (val) => setState(() => _installments = val),
      ),
    );
  }

  void _save(WidgetRef ref, String? groupId) {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (groupId == null) {
      _showError('Lütfen bir grup seçin');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showError('Lütfen bir işlem başlığı girin');
      return;
    }
    
    final cleanAmount = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(cleanAmount) ?? 0;
    if (amount <= 0) {
      _showError('Lütfen geçerli bir tutar girin');
      return;
    }

    // --- DÜZENLEME MODU ---
    if (widget.transactionToEdit != null) {
      final existing = widget.transactionToEdit!;
      final updatedTransaction = existing.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        date: _selectedDate,
        type: _type,
        category: _selectedCategory,
        colorCode: _selectedColor.value,
        recurrenceRule: _recurrence,
      );
      ref.read(transactionsProvider.notifier).addTransaction(updatedTransaction);
      Navigator.pop(context);
      return;
    }

    // --- YENİ EKLEME (VE TEKRAR MANTIĞI) ---
    final uuid = const Uuid();
    List<Transaction> transactionsToSave = [];
    
    int iterations = 1; 
    if (_recurrence != RecurrenceRule.none) {
      if (_isEndDateEnabled) {
        iterations = _calculateIterations(_selectedDate, _endDate, _recurrence);
      } else {
        // 2026 yılında başlayan tekrarlı işlemler, yıl sonunda bitsin (Kullanıcı Talebi)
        if (_selectedDate.year == 2026) {
          final endOfYear = DateTime(2026, 12, 31);
          iterations = _calculateIterations(_selectedDate, endOfYear, _recurrence);
        } else {
          // Diğer yıllar için varsayılan limitler
          if (_recurrence == RecurrenceRule.daily) iterations = 365;
          else if (_recurrence == RecurrenceRule.weekly) iterations = 52;
          else if (_recurrence == RecurrenceRule.biweekly) iterations = 26;
          else if (_recurrence == RecurrenceRule.monthly) iterations = 12;
          else if (_recurrence == RecurrenceRule.firstWorkday) iterations = 12;
          else if (_recurrence == RecurrenceRule.lastWorkday) iterations = 12;
          else if (_recurrence == RecurrenceRule.quarterly) iterations = 4;
          else if (_recurrence == RecurrenceRule.semiannually) iterations = 2;
          else if (_recurrence == RecurrenceRule.yearly) iterations = 5;
        }
      }
    }

    DateTime currentDate = _selectedDate;

    for (int i = 0; i < iterations; i++) {
      DateTime transactionDate = currentDate;

      if (i > 0) {
        switch (_recurrence) {
          case RecurrenceRule.daily:
            transactionDate = _selectedDate.add(Duration(days: i));
            break;
          case RecurrenceRule.weekly:
            transactionDate = _selectedDate.add(Duration(days: i * 7));
            break;
          case RecurrenceRule.biweekly:
            transactionDate = _selectedDate.add(Duration(days: i * 14));
            break;
          case RecurrenceRule.monthly:
            transactionDate = DateTime(_selectedDate.year, _selectedDate.month + i, _selectedDate.day);
            break;
          case RecurrenceRule.quarterly:
            transactionDate = DateTime(_selectedDate.year, _selectedDate.month + (i * 3), _selectedDate.day);
            break;
          case RecurrenceRule.semiannually:
            transactionDate = DateTime(_selectedDate.year, _selectedDate.month + (i * 6), _selectedDate.day);
            break;
          case RecurrenceRule.yearly:
            transactionDate = DateTime(_selectedDate.year + i, _selectedDate.month, _selectedDate.day);
            break;
          case RecurrenceRule.firstWorkday:
            DateTime targetMonth = DateTime(_selectedDate.year, _selectedDate.month + i, 1);
            while (targetMonth.weekday > 5) targetMonth = targetMonth.add(const Duration(days: 1));
            transactionDate = targetMonth;
            break;
          case RecurrenceRule.lastWorkday:
            DateTime targetMonth = DateTime(_selectedDate.year, _selectedDate.month + i + 1, 0);
            while (targetMonth.weekday > 5) targetMonth = targetMonth.subtract(const Duration(days: 1));
            transactionDate = targetMonth;
            break;
          default:
            break;
        }
      }

      transactionsToSave.add(Transaction(
        id: uuid.v4(),
        groupId: groupId,
        title: _titleController.text.trim(),
        amount: amount,
        date: transactionDate,
        type: _type,
        category: _selectedCategory,
        colorCode: _selectedColor.value,
        isPaid: false,
        recurrenceRule: _recurrence,
      ));
    }

    if (_recurrence == RecurrenceRule.none && _installments != null && _installments! > 1) {
       for (int i = 0; i < _installments!; i++) {
          transactionsToSave.add(Transaction(
            id: uuid.v4(),
            groupId: groupId,
            title: '${_titleController.text.trim()} (${i + 1}/${_installments})',
            amount: amount / _installments!,
            date: DateTime(currentDate.year, currentDate.month + i, currentDate.day),
            type: _type,
            category: _selectedCategory,
            colorCode: _selectedColor.value,
            isPaid: false,
            recurrenceRule: RecurrenceRule.none,
            installmentTotal: _installments,
            installmentCurrent: i + 1,
          ));
       }
    } else if (transactionsToSave.isEmpty) { // Tek seferlik işlem veya Mevcut işlem güncelleme
       final isEditing = widget.transactionToEdit != null;
       final transactionId = isEditing 
           ? widget.transactionToEdit!.id 
           : const Uuid().v4();

       transactionsToSave.add(Transaction(
          id: transactionId,
          groupId: groupId,
          title: _titleController.text.trim(),
          amount: amount,
          date: _selectedDate,
          type: _type,
          category: _selectedCategory,
          colorCode: _selectedColor.value,
          isPaid: false,
          recurrenceRule: _recurrence,
       ));
    }

    ref.read(transactionsProvider.notifier).addTransactions(transactionsToSave);
    Navigator.pop(context);
  }

  int _calculateIterations(DateTime start, DateTime end, RecurrenceRule rule) {
    int count = 0;
    DateTime current = start;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      count++;
      switch (rule) {
        case RecurrenceRule.daily:
          current = current.add(const Duration(days: 1));
          break;
        case RecurrenceRule.weekly:
          current = current.add(const Duration(days: 7));
          break;
        case RecurrenceRule.biweekly:
          current = current.add(const Duration(days: 14));
          break;
        case RecurrenceRule.monthly:
        case RecurrenceRule.firstWorkday:
        case RecurrenceRule.lastWorkday:
          current = DateTime(current.year, current.month + 1, current.day);
          break;
        case RecurrenceRule.quarterly:
          current = DateTime(current.year, current.month + 3, current.day);
          break;
        case RecurrenceRule.semiannually:
          current = DateTime(current.year, current.month + 6, current.day);
          break;
        case RecurrenceRule.yearly:
          current = DateTime(current.year + 1, current.month, current.day);
          break;
        default:
          return 1;
      }
      if (count > 500) break; // Güvenlik sınırı
    }
    return count;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.expenseColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// --- EKSİK OLAN SINIF BURAYA EKLENDİ ---
class _OptionPickerModal<T> extends StatelessWidget {
  final String title;
  final List<MapEntry<T, String>> options;
  final T selectedValue;
  final Function(T) onSelected;

  const _OptionPickerModal({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Liste çok uzun olursa taşmasın diye Flexible ve SingleChildScrollView
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: options.map((opt) {
                  final isSelected = opt.key == selectedValue;
                  return ListTile(
                    title: Text(opt.value, style: TextStyle(color: isSelected ? AppTheme.futureColor : Colors.white)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.futureColor) : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      onSelected(opt.key);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}