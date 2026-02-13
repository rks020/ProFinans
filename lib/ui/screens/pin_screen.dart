import 'package:flutter/material.dart';
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
            _errorMessage = "PIN'ler eşleşmiyor. Tekrar deneyin.";
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
          _errorMessage = "Hatalı PIN. Tekrar deneyin.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "PIN Kodunuzu Girin";
    if (widget.isSetupMode) {
      title = _firstPin == null ? "Yeni PIN Belirleyin" : "PIN'i Doğrulayın";
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Icon(Icons.lock_outline, size: 64, color: AppTheme.futureColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: AppTheme.expenseColor, fontSize: 14)),
            const SizedBox(height: 32),
            // Pin dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
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
            const Spacer(flex: 2),
            // Keypad
            _buildKeypad(),
            const SizedBox(height: 48),
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
              if (key == "") return const SizedBox(width: 80, height: 80);
              return Padding(
                padding: const EdgeInsets.all(12.0),
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
          color: isDelete ? Colors.transparent : Colors.white.withOpacity(0.05),
        ),
        alignment: Alignment.center,
        child: isDelete
            ? const Icon(Icons.backspace_outlined, color: Colors.white70)
            : Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w400),
              ),
      ),
    );
  }
}
