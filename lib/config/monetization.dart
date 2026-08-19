/// Production AdMob ad-unit IDs and Tapjoy credentials.
///
/// Ad *units* use a slash (`/`). The native AdMob APPLICATION_ID uses a tilde
/// (`~`) and is a separate dashboard value. Until that App ID is provided,
/// manifests keep the publisher-prefixed App ID so the SDK can initialize.
class Monetization {
  Monetization._();

  static const admobPublisherId = 'ca-app-pub-5530520282558144';
  static const admobAppId = 'ca-app-pub-5530520282558144~5530520282';
  static const bannerAdUnitId = 'ca-app-pub-5530520282558144/4286471153';
  static const interstitialAdUnitId = 'ca-app-pub-5530520282558144/1277164435';
  static const rewardedAdUnitId = 'ca-app-pub-5530520282558144/4673483963';

  static const tapjoyAppId = '370721d2-14c4-4620-b153-c7a61ec2e528';
  static const tapjoySdkKey =
      'Nwch0hTERiCxU8emHsLlKAECfOiuIIWBhdlCNC9i8ZAfib97xpcaBcNI0uCt';
  static const tapjoyOfferwallPlacement = 'Offerwall';

  static const startingCoins = 10;
  static const rewardedCoinGrant = 10;
  static const interstitialEveryNthExpense = 3;
  static const basicFeatureCost = 1;
  static const superFeatureCost = 5;

  static bool get hasProductionAdUnits =>
      bannerAdUnitId == '$admobPublisherId/4286471153' &&
      interstitialAdUnitId == '$admobPublisherId/1277164435' &&
      rewardedAdUnitId == '$admobPublisherId/4673483963';

  static bool get hasProductionTapjoy =>
      tapjoyAppId == '370721d2-14c4-4620-b153-c7a61ec2e528' &&
      tapjoySdkKey ==
          'Nwch0hTERiCxU8emHsLlKAECfOiuIIWBhdlCNC9i8ZAfib97xpcaBcNI0uCt';
}
