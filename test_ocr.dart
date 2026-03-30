void main() {
  final text = """
MIGROS TICARET A.S.
TARIH: 27/02/2026 SAAT:12:33
FIS NO :0076
BILGI FISI
2 AD x 30,95 TL/AD
** FILIZ SPAGETTI CU %1  *61,90
HEMEN POSET (ATLET)  %20 *1,00
2 AD x 169,95 TL/AD
NATURAKOY 15LI YUMR. %1 *339,90
iNDiRiMLER:
*YUMURTA1+1
NATURAKOY 15LI YUMR. %1 *-169,95
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

  print(extractTotalAmount(text));
}

  double? extractTotalAmount(String text) {
    final lines = text.split('\n');
    double? maxAmountFound;

    // Pattern to match numbers like 120.50, 120,50, 1.250,00 etc.
    // Allow leading asterisk * or optional trailing TL
    final numberRegex = RegExp(r'[\*]?\s*(\d+[\.,]\d+)');
    
    // Keywords often found near the total amount
    final keywordRegex = RegExp(r'(TOPLAM|TOP\.|TUTAR|KDV|NAK[iİI]T|KRED[iİI]|SATI[SŞ])', caseSensitive: false);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (keywordRegex.hasMatch(line)) {
        // Look for amount on the same line
        final matches = numberRegex.allMatches(line);
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
    return maxAmountFound;
  }
