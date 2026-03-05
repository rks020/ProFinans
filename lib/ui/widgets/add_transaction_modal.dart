import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/models/transaction.dart';
import '../../data/models/enums.dart';
import '../../data/models/category.dart' as model;
import '../../providers/app_providers.dart';
import '../../data/services/receipt_scanner_service.dart';
import '../../data/services/notification_service.dart';
import '../theme/app_theme.dart';
import '../screens/live_receipt_scanner_screen.dart';

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
  TimeOfDay _selectedTime = TimeOfDay.now();
  int? _installments;
  ReminderInterval _reminderInterval = ReminderInterval.none;

  bool _isEndDateEnabled = false;
  DateTime _endDate = DateTime.now();
  String _selectedCategory = 'Genel';
  Color _selectedColor = Colors.blue;
  String _selectedCurrency = 'TRY';
  double? _currentExchangeRate;

  bool _isScanning = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _hasShownDialog = false; // Prevents double dialog from onStatus firing twice
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
      _selectedTime = TimeOfDay.fromDateTime(t.date);
      _reminderInterval = t.reminderInterval;
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
          _selectedTime = TimeOfDay.fromDateTime(now);
        } else {
          // Farklı bir ay ise, o ayın 1'ini (veya gelen tarihi) kullan
          _selectedDate = widget.initialDate!;
          _selectedTime = const TimeOfDay(hour: 12, minute: 0);
        }
      } else {
        _selectedTime = TimeOfDay.now();
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
    final themeColor = _type == TransactionType.income 
      ? AppTheme.incomeColor 
      : (_type == TransactionType.investment ? const Color(0xFFFFD700) : AppTheme.expenseColor);
    final isEditing = widget.transactionToEdit != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onHorizontalDragUpdate: (_) => FocusScope.of(context).unfocus(),
      child: Container(
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      _buildTypeToggle(TransactionType.investment, 'Yatırım', const Color(0xFFFFD700)),
                  ]),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Provider'dan kurları çek
            ...[
              ref.watch(currencyRatesProvider).when(
                data: (rates) {
                  return Column(
                     children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: ['TRY', 'USD', 'EUR'].map((c) {
                            final isSelected = _selectedCurrency == c;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(c, style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
                                selected: isSelected,
                                selectedColor: themeColor,
                                backgroundColor: AppTheme.surfaceColor,
                                onSelected: isEditing ? null : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCurrency = c;
                                      _currentExchangeRate = rates[c]?.buying ?? 1.0;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedCurrency != 'TRY') ...[
                           const SizedBox(height: 8),
                           Text(
                             'Kur: 1 $_selectedCurrency = ${_currentExchangeRate?.toStringAsFixed(4) ?? "?"} TRY',
                             style: const TextStyle(color: Colors.grey, fontSize: 12),
                           ),
                        ]
                     ]
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (e, s) => Text('Kurlar alınamadı', style: TextStyle(color: AppTheme.expenseColor)),
              )
            ],
            const SizedBox(height: 20),

            // Taksit (Sadece Giderse ve Yeni Eklemedeyse)
            // Tutar Alanı - Currency Badge her zaman görünür olacak
            // Tutar Alanı - Currency Badge her zaman görünür olacak
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      textAlign: TextAlign.center,
                      autofocus: !isEditing,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedCurrency,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  if (_type == TransactionType.expense && !isEditing) ...[
                    const SizedBox(width: 8),
                    _isScanning 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.document_scanner, color: AppTheme.futureColor),
                          onPressed: _scanReceipt,
                          tooltip: 'Fiş Tara',
                        ),
                    const SizedBox(width: 4),
                  ],
                  if (!isEditing) ...[
                    IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none, 
                          color: _isListening ? Colors.redAccent : AppTheme.futureColor
                        ),
                        onPressed: _listen,
                        tooltip: _isListening ? 'Dinleniyor...' : 'Sesle Ekle',
                    )
                  ]
                ],
              ),
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

            // İşlem Saati Seçici
            _buildSelectionRow(
              label: 'İşlem Saati',
              value: _selectedTime.format(context),
              icon: Icons.access_time,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) => Theme(data: AppTheme.darkTheme, child: child!),
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
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
                      onChanged: (val) {
                        setState(() {
                          _isEndDateEnabled = val;
                          if (val && _recurrence == RecurrenceRule.none) {
                            _recurrence = RecurrenceRule.monthly;
                          }
                        });
                      },
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
                label: 'Taksit / Tekrar Sayısı',
                value: '${_calculateIterations(_selectedDate, _endDate, _recurrence)}',
                icon: Icons.list_alt,
                onTap: _showRecurrenceInstallmentPicker,
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

            // Taksit (Sadece Giderse/Yatırımsa ve Yeni Eklemedeyse)
            if ((_type == TransactionType.expense || _type == TransactionType.investment) && _recurrence == RecurrenceRule.none && !isEditing) ...[
              const SizedBox(height: 12),
              _buildSelectionRow(
                label: 'Taksit Sayısı',
                value: _installments?.toString() ?? 'Yok',
                icon: Icons.credit_card,
                onTap: _showInstallmentPicker,
              ),
            ],
            
            // Hatırlatıcı (Sadece Giderse ve Yeni Eklemedeyse)
            if (_type == TransactionType.expense && !isEditing) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Text('Hatırlatıcı Eğilim', style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    DropdownButton<ReminderInterval>(
                      dropdownColor: AppTheme.surfaceColor,
                      value: _reminderInterval,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.futureColor),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: ReminderInterval.values.map((interval) {
                        return DropdownMenuItem(
                          value: interval,
                          child: Text(_getReminderIntervalLabel(interval)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _reminderInterval = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
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
    ));
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
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                // Delete category
                ref.read(categoriesProvider.notifier).deleteCategory(category.name);
                if (_selectedCategory == category.name) {
                  setState(() {
                    _selectedCategory = 'Genel'; // Boşa çıkmasın diye rastgele birini atıyoruz
                    _selectedColor = const Color(0xFF1E88E5);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Sil', style: TextStyle(color: AppTheme.expenseColor)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  void _showRecurrenceInstallmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionPickerModal<int>(
        title: 'Taksit / Tekrar Sayısı',
        options: List.generate(36, (i) => i + 1).map((i) => MapEntry(i, '$i Taksit/Kez')).toList(),
        selectedValue: _calculateIterations(_selectedDate, _endDate, _recurrence),
        onSelected: (val) {
          setState(() {
            _endDate = _calculateEndDateFromIterations(_selectedDate, val, _recurrence);
          });
        },
      ),
    );
  }

  DateTime _calculateEndDateFromIterations(DateTime start, int iterations, RecurrenceRule rule) {
    if (iterations <= 1) return start;
    DateTime current = start;
    RecurrenceRule effectiveRule = rule == RecurrenceRule.none ? RecurrenceRule.monthly : rule;

    for (int i = 1; i < iterations; i++) {
      switch (effectiveRule) {
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
        default: break;
      }
    }
    return current;
  }

  void _save(WidgetRef ref, String? groupId) {
    final isEditing = widget.transactionToEdit != null;
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (groupId == null) {
      _showError('Lütfen bir grup seçin');
      return;
    }

    final cleanAmount = _amountController.text.replaceAll(',', '.');
    final enteredAmount = double.tryParse(cleanAmount) ?? 0;
    
    // Kur hesabı yap (eğer TRY değilse)
    final double exchangeRate = _currentExchangeRate ?? 1.0;
    final double amount = _selectedCurrency == 'TRY' ? enteredAmount : enteredAmount * exchangeRate;
    final double originalAmount = enteredAmount;

    // Tarih ve saati birleştir
    final finalSelectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final isTitleEmpty = _titleController.text.trim().isEmpty;
    final isAmountInvalid = amount <= 0;

    if (isTitleEmpty || isAmountInvalid) {
      String typeText;
      switch (_type) {
        case TransactionType.income: typeText = 'gelir'; break;
        case TransactionType.expense: typeText = 'gider'; break;
        case TransactionType.investment: typeText = 'yatırım'; break;
      }
      _showError('Lütfen $typeText değerini ve başlığını giriniz');
      return;
    }

    // --- DÜZENLEME MODU ---
    if (widget.transactionToEdit != null) {
      final existing = widget.transactionToEdit!;
      final updatedTransaction = existing.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        date: finalSelectedDate,
        type: _type,
        category: _selectedCategory,
        colorCode: _selectedColor.value,
        recurrenceRule: _recurrence,
        reminderInterval: _reminderInterval,
        hasReminder: _reminderInterval != ReminderInterval.none,
      );

      bool isRecurring = existing.recurrenceRule != RecurrenceRule.none || updatedTransaction.recurrenceRule != RecurrenceRule.none;

      if (isRecurring && !isEditing) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Tekrarlı İşlemi Güncelle', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Yaptığınız değişiklikler sadece bu işlemi mi yoksa, bu yıla ait tüm tekrarları mı etkilesin?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), 
                child: const Text('İptal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(transactionsProvider.notifier).addTransaction(updatedTransaction);
                  Navigator.pop(dialogContext);
                  Navigator.pop(context); // modal'ı kapat
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceColor),
                child: const Text('Sadece Bu İşlem', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(transactionsProvider.notifier).updateBulkTransactions(existing, updatedTransaction);
                  Navigator.pop(dialogContext);
                  Navigator.pop(context); // modal'ı kapat
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.futureColor),
                child: const Text('Tüm Tekrarlar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else {
        ref.read(transactionsProvider.notifier).addTransaction(updatedTransaction);
        Navigator.pop(context);
      }
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

    DateTime currentDate = finalSelectedDate;

    for (int i = 0; i < iterations; i++) {
      DateTime transactionDate = currentDate;

      if (i > 0) {
        switch (_recurrence) {
          case RecurrenceRule.daily:
            transactionDate = finalSelectedDate.add(Duration(days: i));
            break;
          case RecurrenceRule.weekly:
            transactionDate = finalSelectedDate.add(Duration(days: i * 7));
            break;
          case RecurrenceRule.biweekly:
            transactionDate = finalSelectedDate.add(Duration(days: i * 14));
            break;
          case RecurrenceRule.monthly:
            transactionDate = DateTime(finalSelectedDate.year, finalSelectedDate.month + i, finalSelectedDate.day, finalSelectedDate.hour, finalSelectedDate.minute);
            break;
          case RecurrenceRule.quarterly:
            transactionDate = DateTime(finalSelectedDate.year, finalSelectedDate.month + (i * 3), finalSelectedDate.day, finalSelectedDate.hour, finalSelectedDate.minute);
            break;
          case RecurrenceRule.semiannually:
            transactionDate = DateTime(finalSelectedDate.year, finalSelectedDate.month + (i * 6), finalSelectedDate.day, finalSelectedDate.hour, finalSelectedDate.minute);
            break;
          case RecurrenceRule.yearly:
            transactionDate = DateTime(finalSelectedDate.year + i, finalSelectedDate.month, finalSelectedDate.day, finalSelectedDate.hour, finalSelectedDate.minute);
            break;
          case RecurrenceRule.firstWorkday:
            DateTime targetMonth = DateTime(finalSelectedDate.year, finalSelectedDate.month + i, 1, finalSelectedDate.hour, finalSelectedDate.minute);
            while (targetMonth.weekday > 5) targetMonth = targetMonth.add(const Duration(days: 1));
            transactionDate = targetMonth;
            break;
          case RecurrenceRule.lastWorkday:
            DateTime targetMonth = DateTime(finalSelectedDate.year, finalSelectedDate.month + i + 1, 0, finalSelectedDate.hour, finalSelectedDate.minute);
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
        currency: _selectedCurrency,
        originalAmount: originalAmount,
        exchangeRate: exchangeRate,
        reminderInterval: _reminderInterval,
        hasReminder: _reminderInterval != ReminderInterval.none,
      ));
    }

    if (_recurrence == RecurrenceRule.none && _installments != null && _installments! > 1) {
       for (int i = 0; i < _installments!; i++) {
          transactionsToSave.add(Transaction(
            id: uuid.v4(),
            groupId: groupId,
            title: '${_titleController.text.trim()} (${i + 1}/${_installments})',
            amount: amount / _installments!,
            date: DateTime(finalSelectedDate.year, finalSelectedDate.month + i, finalSelectedDate.day, finalSelectedDate.hour, finalSelectedDate.minute),
            type: _type,
            category: _selectedCategory,
            colorCode: _selectedColor.value,
            isPaid: false,
            recurrenceRule: RecurrenceRule.none,
            installmentTotal: _installments,
            installmentCurrent: i + 1,
            currency: _selectedCurrency,
            originalAmount: originalAmount / _installments!,
            exchangeRate: exchangeRate,
            reminderInterval: _reminderInterval,
            hasReminder: _reminderInterval != ReminderInterval.none,
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
          date: finalSelectedDate,
          type: _type,
          category: _selectedCategory,
          colorCode: _selectedColor.value,
          isPaid: false,
          recurrenceRule: _recurrence,
          currency: _selectedCurrency,
          originalAmount: originalAmount,
          exchangeRate: exchangeRate,
       ));
    }

    ref.read(transactionsProvider.notifier).addTransactions(transactionsToSave);

    // Schedule notifications for transactions with a reminder
    for (final t in transactionsToSave) {
      if (t.reminderInterval != ReminderInterval.none) {
        NotificationService().scheduleTransactionReminder(t);
      }
    }
    
    // Gider (veya Yatırım) ise 0. sekme (Dashboard), Gelir ise 2. sekme (Income)
    if (_type == TransactionType.income) {
      ref.read(mainScreenIndexProvider.notifier).setIndex(2);
    } else {
      ref.read(mainScreenIndexProvider.notifier).setIndex(0);
    }
    
    // Animate the newly added transaction
    if (transactionsToSave.isNotEmpty) {
      ref.read(lastAddedTransactionIdProvider.notifier).setId(transactionsToSave.first.id);
    }

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
    // Klavye açıksa kapatalım ki dialog düzgün görünsün
    FocusScope.of(context).unfocus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.expenseColor),
            SizedBox(width: 12),
            Text('Hata', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: AppTheme.futureColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _scanReceipt() async {
    final amount = await Navigator.push<double?>(
      context,
      MaterialPageRoute(builder: (context) => const LiveReceiptScannerScreen()),
    );
    
    if (!mounted) return;

    if (amount != null) {
      _amountController.text = amount.toStringAsFixed(2).replaceAll('.', ',');
      
      // İşlem Türünü Otomatik "Gider" Yap
      setState(() {
        _type = TransactionType.expense;
      });

      // Auto-increment title logic
      final settings = ref.read(appSettingsProvider);
      final allTransactions = ref.read(transactionsProvider)
          .where((t) => t.groupId == settings.activeGroupId);
          
      int maxReceiptIndex = 0;
      for (final t in allTransactions) {
        if (t.title.startsWith('Market Fişi')) {
          if (t.title == 'Market Fişi') {
            if (maxReceiptIndex < 1) maxReceiptIndex = 1;
          } else {
            final suffix = t.title.replaceAll('Market Fişi ', '');
            final num = int.tryParse(suffix);
            if (num != null && num > maxReceiptIndex) {
              maxReceiptIndex = num;
            }
          }
        }
      }
      
      _titleController.text = maxReceiptIndex == 0 
          ? "Market Fişi" 
          : "Market Fişi ${maxReceiptIndex + 1}";

      // Fişlerde varsayılan kategoriyi "Market" yapıyoruz
      final categories = ref.read(categoriesProvider);
      final marketCat = categories.firstWhere(
        (c) => c.name.toLowerCase() == 'market', 
        orElse: () => categories.first
      );
      
      setState(() {
        _selectedCategory = marketCat.name;
        _selectedColor = Color(marketCat.colorCode);
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Fiş Onayı', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tutar: ${_amountController.text} ₺\n'
            'Başlık: ${_titleController.text}\n'
            'Kategori: $_selectedCategory\n\n'
            'Bu gider işlemini kaydetmek istiyor musunuz?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Sadece dialogu kapat, formda kalsın
              },
              child: const Text('Düzenle / Yanlış', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _quickSaveAndNavigate(ref, dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.futureColor),
              child: const Text('Doğru, Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      _hasShownDialog = false; // Her dinlemede guard'ı sıfırla
      _recognizedText = '';
      
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) {
              setState(() => _isListening = false);
              // Artık onStatus içinden işlemi TETİKLEMİYORUZ (sadece dinlemenin bittiğini UI'a söylüyoruz)
              // Çünkü iOS/Android otomatik durduğunda da dialog çıksın istiyorsak buraya koymalıyız.
              // Eğer buraya koyarsak hem stop() hem bu çiftler. Bu yüzden _hasShownDialog ile guardlıyoruz.
              if (!_hasShownDialog && _recognizedText.isNotEmpty) {
                 _processRecognizedText();
              }
            }
          }
        },
        onError: (val) {
          if (mounted) {
            setState(() => _isListening = false);
            _showError('Ses tanıma hatası: ${val.errorMsg}');
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _recognizedText = val.recognizedWords;
              });
            }
          },
          localeId: 'tr_TR',
        );
      } else {
        _showError('Konuşma tanıma bu cihazda kullanılamıyor veya izin verilmedi.');
      }
    } else {
      // KULLANICI MANUEL DURDURDU:
      setState(() => _isListening = false);
      _speech.stop();
      if (!_hasShownDialog && _recognizedText.isNotEmpty) {
        _processRecognizedText();
      }
    }
  }

  void _processRecognizedText() {
    if (_recognizedText.trim().isEmpty) return;

    // "35 bin tl kira", "2220 tl market fişi", "150,5 kahve" gibi ifadeleri parse et
    // Önce Türkçe sayı kelimelerini (bin, milyon, yüz) çözelim
    final parsedAmount = _parseTurkishAmount(_recognizedText);
    String remainingText = _recognizedText.trim().toLowerCase();
    
    if (parsedAmount != null) {
      // Tutar bulunduysa, kalan kısmı başlık olarak al
      _amountController.text = parsedAmount.toStringAsFixed(
        parsedAmount == parsedAmount.truncateToDouble() ? 0 : 2
      );
      // Tutar + opsiyonel "TL" + boşluk + başlık kalıbını temizle
      final cleanedTitle = remainingText
          .replaceFirst(RegExp(r'^\d[\d.,]*\s*(bin|milyon|milyar|yüz|yuz)?\s*(tl)?\s*', caseSensitive: false), '')
          .replaceFirst(RegExp(r'^(bir|iki|üç|uc|dört|dort|beş|bes|altı|alti|yedi|sekiz|dokuz)?\s*(yüz|yuz|bin|milyon|milyar)?\s*(tl)?\s*', caseSensitive: false), '')
          .trim();
      if (cleanedTitle.isNotEmpty) {
        _titleController.text = cleanedTitle[0].toUpperCase() + cleanedTitle.substring(1).toLowerCase();
      }
    } else {
      // Sayı yoksa sadece başlığa atalım
      _titleController.text = remainingText[0].toUpperCase() + remainingText.substring(1).toLowerCase();
    }
    
    // İşlem Türünü Otomatik "Gider" Yap
    setState(() {
      _type = TransactionType.expense;
    });

    // Otomatik Kategori Seçimi - konuşma içinde geçen kategori isimlerini bul
    final rawText = _recognizedText.toLowerCase();
    final categories = ref.read(categoriesProvider);
    bool categoryMatched = false;
    for (final cat in categories) {
      if (rawText.contains(cat.name.toLowerCase())) {
        setState(() {
          _selectedCategory = cat.name;
          _selectedColor = Color(cat.colorCode);
        });
        categoryMatched = true;
        break;
      }
    }

    // Başlık boş kaldıysa akıllı default ata
    if (_titleController.text.trim().isEmpty) {
      _titleController.text = _selectedCategory ?? 'Gider';
    }

    // Guard: sadece bir kez dialog göster
    if (_hasShownDialog) return;
    _hasShownDialog = true;

    // Onay Penceresi Göster
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sesli İşlem Onayı', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tutar: ${_amountController.text} ₺\n'
          'Başlık: ${_titleController.text}\n'
          'Kategori: $_selectedCategory\n\n'
          'Bu gider işlemini kaydetmek istiyor musunuz?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Sadece dialogu kapat, formda kalsın
            },
            child: const Text('Düzenle / Yanlış', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _quickSaveAndNavigate(ref, dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.futureColor),
            child: const Text('Doğru, Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Ses/Fiş onay dialogundan direkt kayıt ve yönlendirme
  void _quickSaveAndNavigate(WidgetRef ref, BuildContext dialogContext) {
    final settings = ref.read(appSettingsProvider);
    final groupId = settings.activeGroupId;
    if (groupId == null) return;

    final cleanAmount = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(cleanAmount) ?? 0;
    final title = _titleController.text.trim();
    if (amount <= 0 || title.isEmpty) return;

    final t = Transaction(
      id: const Uuid().v4(),
      groupId: groupId,
      title: title,
      amount: amount,
      date: _selectedDate,
      type: TransactionType.expense,
      category: _selectedCategory,
      colorCode: _selectedColor.value,
      isPaid: false,
      recurrenceRule: RecurrenceRule.none,
      currency: 'TRY',
      originalAmount: amount,
      exchangeRate: 1.0,
    );

    ref.read(transactionsProvider.notifier).addTransactions([t]);
    ref.read(mainScreenIndexProvider.notifier).setIndex(0);
    ref.read(lastAddedTransactionIdProvider.notifier).setId(t.id);

    // Dialog + Modal'ı kapat
    Navigator.of(dialogContext).pop();
    Navigator.of(context).pop();
  }

  /// Türkçe sayı ifadelerini double'a çevirir:
  /// "35 bin tl kira" → 35000.0
  /// "2.500 TL market" → 2500.0
  /// "150,5 kahve" → 150.5
  /// "1 milyon" → 1000000.0
  double? _parseTurkishAmount(String text) {
    final lower = text.trim().toLowerCase();

    // Rakam + çarpan (bin/milyon/milyar) + opsiyonel "tl"
    // Örn: "35 bin", "2,5 milyon", "1.5 milyar"
    final multiplierExp = RegExp(
      r'^(\d+[.,]?\d*)\s*(bin|milyon|milyar|yüz|yuz)?\s*(tl)?\s*',
      caseSensitive: false,
    );
    final m = multiplierExp.firstMatch(lower);
    if (m != null) {
      final numStr = m.group(1)!.replaceAll('.', '').replaceAll(',', '.');
      final base = double.tryParse(numStr);
      if (base == null) return null;
      final multiplierWord = m.group(2)?.toLowerCase();
      double multiplier = 1.0;
      if (multiplierWord == 'bin') multiplier = 1000;
      else if (multiplierWord == 'milyon') multiplier = 1000000;
      else if (multiplierWord == 'milyar') multiplier = 1000000000;
      else if (multiplierWord == 'yüz' || multiplierWord == 'yuz') multiplier = 100;
      return base * multiplier;
    }
    return null;
  }
  String _getReminderIntervalLabel(ReminderInterval interval) {
    switch (interval) {
      case ReminderInterval.none: return 'Yok';
      case ReminderInterval.thirtyMinutes: return '30 Dakika Önce';
      case ReminderInterval.oneHour: return '1 Saat Önce';
      case ReminderInterval.twelveHours: return '12 Saat Önce';
      case ReminderInterval.oneDay: return '1 Gün Önce';
      case ReminderInterval.twoDays: return '2 Gün Önce';
      case ReminderInterval.oneWeek: return '1 Hafta Önce';
    }
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