import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../providers/subscriptions_provider.dart';
import '../theme/app_theme.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectedSubs = ref.watch(detectedSubscriptionsProvider);
    final totalCost = ref.watch(totalMonthlySubscriptionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('subscriptions.title'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCard(totalCost, ref, context),
          SizedBox(height: 20),
          Expanded(
            child: detectedSubs.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: detectedSubs.length,
                    itemBuilder: (context, index) {
                      return _buildSubscriptionCard(context, ref, detectedSubs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalCost, WidgetRef ref, BuildContext context) {
    final currencyCode = ref.watch(appSettingsProvider).selectedCurrency;
    final displaySymbol = currencyCode == 'TRY' ? '₺' : (currencyCode == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 2);

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.futureColor, AppTheme.futureColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.futureColor.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('subscriptions.total_monthly_cost'.tr(), style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 8),
              Text(
                format.format(totalCost),
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(Icons.auto_awesome, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          SizedBox(height: 20),
          Text(
            'subscriptions.empty_title'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'subscriptions.empty_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref, SubscriptionCandidate sub) {
    final color = Color(sub.colorCode);
    final currencyCode = ref.watch(appSettingsProvider).selectedCurrency;
    final displaySymbol = currencyCode == 'TRY' ? '₺' : (currencyCode == 'USD' ? '\$' : '€');
    final format = NumberFormat.currency(locale: context.locale.languageCode, symbol: displaySymbol, decimalDigits: 2);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.sync, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'subscriptions.occurrences'.tr(namedArgs: {'count': sub.occurrences.length.toString()}),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format.format(sub.amount),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('subscriptions.every_month'.tr(), style: TextStyle(color: AppTheme.incomeColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
