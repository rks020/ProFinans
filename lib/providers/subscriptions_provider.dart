import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/transaction.dart';
import '../data/models/enums.dart';
import 'app_providers.dart';

part 'subscriptions_provider.g.dart';

class SubscriptionCandidate {
  final String title;
  final double amount;
  final String category;
  final int colorCode;
  final List<Transaction> occurrences;
  final double monthlyCost;

  SubscriptionCandidate({
    required this.title,
    required this.amount,
    required this.category,
    required this.colorCode,
    required this.occurrences,
    required this.monthlyCost,
  });
}

@riverpod
List<SubscriptionCandidate> detectedSubscriptions(Ref ref) {
  final transactions = ref.watch(transactionsProvider);
  final settings = ref.watch(appSettingsProvider);
  final ratesAsync = ref.watch(currencyRatesProvider);
  final rates = ratesAsync.value;
  final String selectedCurrency = settings.selectedCurrency;
  
  // Tüm işlemleri (ödenmiş/ödenmemiş) abonelik tespiti için kullan
  final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
  
  // Başlıklara göre grupla (Fuzzy matching: sayıları, tarihleri ve TÜM boşlukları temizle)
  final Map<String, List<Transaction>> groupedByTitle = {};
  final Set<String> manuallyMarkedKeys = {};

  for (final t in expenses) {
    // Tüm boşlukları, özel karakterleri ve sayıları temizleyerek "kemik" bir anahtar oluştur
    final normalizedKey = t.title
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '') 
        .replaceAll(RegExp(r'\d+'), '') 
        .replaceAll(RegExp(r'[^a-zığüşöç]'), '') 
        .replaceAll(RegExp(r'(ocak|şubat|mart|nisan|mayıs|haziran|temmuz|ağustos|eylül|ekim|kasım|aralık)'), '')
        .trim();
        
    final key = normalizedKey.length < 3 ? t.title.trim().toLowerCase() : normalizedKey;
    groupedByTitle.putIfAbsent(key, () => []).add(t);
    
    if (t.isSubscription) {
      manuallyMarkedKeys.add(key);
    }
  }
  
  final List<SubscriptionCandidate> candidates = [];
  
  groupedByTitle.forEach((key, occurrences) {
    // Eğer manuel işaretlenmişse OR otomatik olarak en az 2 kez ve doğru aralıkta gerçekleşmişse
    final isManual = manuallyMarkedKeys.contains(key);
    
    if (occurrences.length < 2 && !isManual) return;
    
    // Tarihe göre sırala
    occurrences.sort((a, b) => a.date.compareTo(b.date));
    
    double avgDays = 0;
    bool amountConsistent = true;
    final firstAmount = occurrences.first.amount;

    if (occurrences.length >= 2) {
      double totalDays = 0;
      int intervals = 0;
      for (int i = 0; i < occurrences.length - 1; i++) {
        final diff = occurrences[i+1].date.difference(occurrences[i].date).inDays;
        totalDays += diff;
        intervals++;
        if ((occurrences[i+1].amount - firstAmount).abs() > firstAmount * 0.15) {
          amountConsistent = false;
        }
      }
      avgDays = totalDays / intervals;
    }
    
    // Koşul: 
    // 1. Manuel işaretlenmiş (tek sefer olsa bile)
    // 2. VEYA Otomatik tespit: 20-45 gün aralığı ve tutarlı tutar
    if (isManual || (avgDays >= 20 && avgDays <= 45 && amountConsistent)) {
      final last = occurrences.last;
      double displayAmount = last.amount;

      // Uygulamanın seçili para birimine göre tutarı düzenle
      if (selectedCurrency == 'TRY') {
        displayAmount = last.amount;
      } else if (last.currency == selectedCurrency && last.originalAmount != null) {
        displayAmount = last.originalAmount!;
      } else if (rates != null) {
        final rate = rates[selectedCurrency]?.buying ?? 1.0;
        displayAmount = last.amount / rate;
      }

      candidates.add(SubscriptionCandidate(
        title: last.title.replaceAll(RegExp(r'\d+'), '').trim(),
        amount: displayAmount,
        category: last.category,
        colorCode: last.colorCode,
        occurrences: occurrences,
        monthlyCost: displayAmount,
      ));
    }
  });
  
  return candidates;
}

@riverpod
double totalMonthlySubscriptions(Ref ref) {
  final subs = ref.watch(detectedSubscriptionsProvider);
  return subs.fold(0, (sum, sub) => sum + sub.monthlyCost);
}
