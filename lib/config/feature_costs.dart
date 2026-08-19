import 'monetization.dart';

enum CoinFeature {
  basicAnalytics(
    'Basic analytics',
    Monetization.basicFeatureCost,
    false,
  ),
  recalculateBudget(
    'Recalculate budget limits',
    Monetization.basicFeatureCost,
    false,
  ),
  csvExport(
    'CSV export',
    Monetization.basicFeatureCost,
    false,
  ),
  debtNotifications(
    'Debt due-date push alerts',
    Monetization.superFeatureCost,
    true,
  ),
  aiEventPredictor(
    'AI event budget predictor',
    Monetization.superFeatureCost,
    true,
  ),
  hostelVolatilityAudit(
    'Hostel volatility audit',
    Monetization.superFeatureCost,
    true,
  );

  const CoinFeature(this.label, this.cost, this.isSuper);
  final String label;
  final int cost;
  final bool isSuper;
}
