void main() {
  final text = """
KDV  KDV TUTARI KDV'LI TOPLAM
%1       *2,91        *293,75
%20      *0,17        *1,00
""";
  final text2 = """
TOPLAM            *294,75
""";

  double? extractTotalAmount(String text) {
    final lines = text.split('\n');
    double? maxAmountFound;

    final numberRegex = RegExp(r'[\*]?\s*(\d+[\.,]\d+)');
    final keywordRegex = RegExp(r'(TOPLAM|TOP\.|TUTAR|SATI[SŞ])', caseSensitive: false);
    final excludeRegex = RegExp(r'(KDV|NAK[iİI]T|PARA U|ARA TOPLAM)', caseSensitive: false);

    for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        // Skip lines that have excluded words like KDV
        if (excludeRegex.hasMatch(line)) continue;

        if (keywordRegex.hasMatch(line)) {
            // Look ahead up to 2 lines
            for (int j = i; j <= i + 2 && j < lines.length; j++) {
                final matches = numberRegex.allMatches(lines[j]);
                if (matches.isNotEmpty) {
                    for (var match in matches) {
                        final amountStr = match.group(1)?.replaceAll('.', '').replaceAll(',', '.');
                        if (amountStr != null) {
                            final amount = double.tryParse(amountStr);
                            if (amount != null) {
                                if (maxAmountFound == null || amount > maxAmountFound) {
                                    maxAmountFound = amount;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return maxAmountFound;
  }
  print("Final Result 1 (Should be null): " + extractTotalAmount(text).toString());
  print("Final Result 2 (Should be 294.75): " + extractTotalAmount(text2).toString());
}
