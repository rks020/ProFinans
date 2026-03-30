void main() {
  final text1 = """
TOPKDV            *3,08
TOPLAM            *294,75

#494314******1675 ORTAK POS *294,75
KDV  KDV TUTARI KDV'LI TOPLAM
%1       *2,91        *293,75
%20      *0,17        *1,00
SATIS
494314******1675
*294,75 TL
""";

  final text2 = """
TOPLAM KDV           *27.58
Odenecek KDV Dahil Tutar   *856.96
Ippos Kredi Karti (1)      *856.96
""";

  double? extractTotalAmount(String text) {
    final lines = text.split('\n');
    double? maxAmountFound;

    final numberRegex = RegExp(r'[\*]?\s*(\d+[\.,]\d+)');
    
    // Whitelist keywords indicating the total
    final keywordRegex = RegExp(r'(TOPLAM|TUTAR|SATI[SŞ]|ODENECEK|ÖDENECEK|KRED[Iİ] KARTI)', caseSensitive: false);
    
    // Blacklist specific phrases that are subtotals or tax
    final excludeRegex = RegExp(r'(KDV\s*TUTARI|TOPKDV|TOPLAM\s*KDV|ARA\s*TOPLAM|KDV.L[Iİ]\s*TOPLAM)', caseSensitive: false);

    for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        
        if (excludeRegex.hasMatch(line)) continue;

        if (keywordRegex.hasMatch(line)) {
            for (int j = i; j <= i + 2 && j < lines.length; j++) {
                final matches = numberRegex.allMatches(lines[j]);
                if (matches.isNotEmpty) {
                    for (var match in matches) {
                        String numStr = match.group(1)!;
                        if (numStr.contains(',') && numStr.contains('.')) {
                            numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
                        } else if (numStr.contains(',')) {
                            numStr = numStr.replaceAll(',', '.');
                        }
                        
                        final amount = double.tryParse(numStr);
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
    return maxAmountFound;
  }
  
  print("Receipt 1 Total (Should be 294.75): " + extractTotalAmount(text1).toString());
  print("Receipt 2 Total (Should be 856.96): " + extractTotalAmount(text2).toString());
}
