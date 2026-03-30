void main() {
  final text = """
TOPLAM KDV           *27.58
Odenecek KDV Dahil Tutar   *856.96

Ippos Kredi Karti (1)      *856.96
""";

  final text2 = """
KDV  MATRAH    KDV TUTAR   KDV DAHIL
%1.  727.86       *7.28     *735.16
%20  101.50      *20.30     *121.80
""";

  List<double> extractAllCurrencyAmounts(String text) {
    // Sadece para formati 12.34 veya 12,34 olanlari al
    final numberRegex = RegExp(r'(?:[\*]?\s*)(\d{1,6}[\.,]\d{2})(?!\d)');
    final matches = numberRegex.allMatches(text);
    final Set<double> possibleAmounts = {};
    
    for (var match in matches) {
      String numStr = match.group(1)!;
      if (numStr.contains(',') && numStr.contains('.')) {
        numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
      } else if (numStr.contains(',')) {
        numStr = numStr.replaceAll(',', '.');
      }
      final amount = double.tryParse(numStr);
      if (amount != null) {
        possibleAmounts.add(amount);
      }
    }
    final resultList = possibleAmounts.toList();
    resultList.sort((a, b) => b.compareTo(a));
    return resultList;
  }
  
  print("Receipt 1:");
  print(extractAllCurrencyAmounts(text));
  
  print("Receipt 2:");
  print(extractAllCurrencyAmounts(text2));
}
