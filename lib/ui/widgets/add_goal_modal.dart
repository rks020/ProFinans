import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class AddGoalModal extends ConsumerStatefulWidget {
  final Goal? goalToEdit;

  const AddGoalModal({super.key, this.goalToEdit});

  @override
  ConsumerState<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends ConsumerState<AddGoalModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  DateTime? _deadline;
  Color _selectedColor = Colors.blue;

  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, 
    Colors.pink, Colors.teal, Colors.amber, Colors.indigo, Colors.brown,
    Colors.cyan, Colors.lime, Colors.lightGreen, Colors.deepOrange, Colors.deepPurple,
    Colors.blueGrey, Colors.grey, Colors.black, Colors.lightBlue, Colors.redAccent
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      final g = widget.goalToEdit!;
      _titleController.text = g.title;
      _amountController.text = g.targetAmount.toString();
      _currentAmountController.text = g.currentAmount.toString();
      _deadline = g.deadline;
      _selectedColor = Color(g.colorCode);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                isEditing ? 'goals.edit_title'.tr() : 'goals.add_title'.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 24),
            
            _buildTextField(
              controller: _titleController,
              hint: 'goals.name_label'.tr(),
              icon: Icons.flag,
            ),
            SizedBox(height: 16),
            
            _buildTextField(
              controller: _amountController,
              hint: 'goals.target_amount_label'.tr(),
              icon: Icons.account_balance_wallet,
              isNumber: true,
            ),
            SizedBox(height: 16),

            _buildTextField(
              controller: _currentAmountController,
              hint: '${'add_transaction.amount_label'.tr()} (Opsiyonel)',
              icon: Icons.savings,
              isNumber: true,
            ),
            SizedBox(height: 16),

            _buildSelectionRow(
              label: 'goals.deadline_label'.tr(),
              value: _deadline == null ? 'add_transaction.not_selected'.tr() : DateFormat('d MMM yyyy', context.locale.languageCode).format(_deadline!),
              icon: Icons.calendar_today,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                  builder: (context, child) => Theme(data: AppTheme.darkTheme, child: child!),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            SizedBox(height: 16),

            Text('categories_screen.color_selection'.tr(), style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: _selectedColor == c ? Colors.white : Colors.transparent, width: 2),
                  ),
                ),
              )).toList(),
            ),
            SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.futureColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isEditing ? 'add_transaction.update'.tr() : 'add_transaction.add'.tr(), 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            if (isEditing) ...[
              SizedBox(height: 12),
              TextButton(
                onPressed: _delete,
                child: Text('goals.delete'.tr(), style: TextStyle(color: AppTheme.expenseColor)),
              ),
            ],
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isNumber = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        ),
      ),
    );
  }

  Widget _buildSelectionRow({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.white)),
            Spacer(),
            Text(value, style: TextStyle(color: AppTheme.futureColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty || _amountController.text.trim().isEmpty) return;

    final targetAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final currentAmount = double.tryParse(_currentAmountController.text.replaceAll(',', '.')) ?? 0;

    final goal = widget.goalToEdit?.copyWith(
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: _deadline,
      colorCode: _selectedColor.toARGB32(),
    ) ?? Goal(
      id: Uuid().v4(),
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: _deadline,
      colorCode: _selectedColor.toARGB32(),
    );

    if (widget.goalToEdit != null) {
      ref.read(goalsProvider.notifier).updateGoal(goal);
    } else {
      ref.read(goalsProvider.notifier).addGoal(goal);
    }

    Navigator.pop(context);
  }

  void _delete() {
    if (widget.goalToEdit != null) {
      ref.read(goalsProvider.notifier).deleteGoal(widget.goalToEdit!.id);
      Navigator.pop(context);
    }
  }
}
