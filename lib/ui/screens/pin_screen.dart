import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../theme/app_theme.dart';

class PinScreen extends ConsumerStatefulWidget {
  final bool isSetupMode;

  const PinScreen({super.key, this.isSetupMode = false});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = "";
  String? _firstPin; // For setup mode confirmation
  String _errorMessage = "";

  void _handleKeyPress(String key) {
    setState(() {
      _errorMessage = "";
      if (key == "DEL") {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (_pin.length < 4) {
        _pin += key;
      }
    });

    if (_pin.length == 4) {
      _processPin();
    }
  }

  void _processPin() async {
    final settings = ref.read(appSettingsProvider);
    
    if (widget.isSetupMode) {
      if (_firstPin == null) {
        // First step of setup
        setState(() {
          _firstPin = _pin;
          _pin = "";
        });
      } else {
        // Confirmation step
        if (_pin == _firstPin) {
          await ref.read(appSettingsProvider.notifier).updatePinCode(_pin);
          // Set as verified for current session
          ref.read(pinStateProvider.notifier).verify();
        } else {
          setState(() {
            _pin = "";
            _firstPin = null;
            _errorMessage = "pin.mismatch".tr();
          });
        }
      }
    } else {
      // Verification mode
      if (_pin == settings.pinCode) {
        ref.read(pinStateProvider.notifier).verify();
      } else {
        setState(() {
          _pin = "";
          _errorMessage = "pin.incorrect".tr();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "pin.enter_pin".tr();
    if (widget.isSetupMode) {
      title = _firstPin == null ? "pin.set_new_pin".tr() : "pin.verify_pin".tr();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 2),
            Icon(Icons.lock_outline, size: 64, color: AppTheme.futureColor),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: AppTheme.expenseColor, fontSize: 14)),
            SizedBox(height: 32),
            // Pin dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _pin.length;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppTheme.futureColor : Colors.white10,
                    border: Border.all(color: isFilled ? AppTheme.futureColor : Colors.white30),
                  ),
                );
              }),
            ),
            Spacer(flex: 2),
            // Keypad
            _buildKeypad(),
            SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ["1", "2", "3"],
          ["4", "5", "6"],
          ["7", "8", "9"],
          ["", "0", "DEL"]
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key == "") return SizedBox(width: 80, height: 80);
              return Padding(
                padding: EdgeInsets.all(12.0),
                child: _KeyButton(
                  label: key,
                  onTap: () => _handleKeyPress(key),
                  isDelete: key == "DEL",
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  const _KeyButton({required this.label, required this.onTap, this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
        ),
        alignment: Alignment.center,
        child: isDelete
            ? Icon(Icons.backspace_outlined, color: Colors.white70)
            : Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w400),
              ),
      ),
    );
  }
}
