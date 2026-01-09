import 'dart:io';
import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Service for handling ads in the game
/// 
/// To enable ads:
/// 1. Uncomment the google_mobile_ads import above
/// 2. Add your AdMob app ID to AndroidManifest.xml and Info.plist
/// 3. Replace test ad unit IDs with your production IDs
/// 4. Call AdService.initialize() in main.dart before runApp()
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  
  AdService._();
  
  // Test Ad Unit IDs (replace with your production IDs)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS test ID
    }
    throw UnsupportedError('Unsupported platform');
  }
  
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID
    }
    throw UnsupportedError('Unsupported platform');
  }
  
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS test ID
    }
    throw UnsupportedError('Unsupported platform');
  }
  
  bool _isInitialized = false;
  int _gamesPlayed = 0;
  
  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Uncomment to enable ads:
    // await MobileAds.instance.initialize();
    
    _isInitialized = true;
    debugPrint('AdService: Initialized (ads disabled in development)');
  }
  
  /// Track games played for interstitial frequency
  void onGameCompleted() {
    _gamesPlayed++;
  }
  
  /// Check if interstitial should be shown (every 3 games)
  bool shouldShowInterstitial() {
    return _gamesPlayed > 0 && _gamesPlayed % 3 == 0;
  }
  
  /// Show interstitial ad
  Future<void> showInterstitial() async {
    if (!_isInitialized) return;
    if (!shouldShowInterstitial()) return;
    
    // TODO: Implement actual interstitial ad loading and showing
    // InterstitialAd.load(
    //   adUnitId: interstitialAdUnitId,
    //   request: const AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (ad) => ad.show(),
    //     onAdFailedToLoad: (error) => debugPrint('Interstitial failed: $error'),
    //   ),
    // );
    
    debugPrint('AdService: Would show interstitial (game #$_gamesPlayed)');
  }
  
  /// Show rewarded ad and return true if reward was earned
  Future<bool> showRewardedAd() async {
    if (!_isInitialized) {
      debugPrint('AdService: Not initialized');
      return false;
    }
    
    // TODO: Implement actual rewarded ad loading and showing
    // final completer = Completer<bool>();
    // RewardedAd.load(
    //   adUnitId: rewardedAdUnitId,
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       ad.show(onUserEarnedReward: (_, reward) {
    //         completer.complete(true);
    //       });
    //     },
    //     onAdFailedToLoad: (error) {
    //       completer.complete(false);
    //     },
    //   ),
    // );
    // return completer.future;
    
    debugPrint('AdService: Would show rewarded ad');
    
    // Simulate watching an ad in development
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Simulate reward earned
  }
}

/* 
================================================================================
SETUP INSTRUCTIONS FOR ADMOB
================================================================================

1. CREATE ADMOB ACCOUNT
   - Go to https://admob.google.com
   - Create an account and add your app

2. GET YOUR AD UNIT IDS
   - Create ad units for: Banner, Interstitial, Rewarded
   - Replace the test IDs above with your production IDs

3. ANDROID SETUP (android/app/src/main/AndroidManifest.xml)
   Add inside <application> tag:
   
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>

4. IOS SETUP (ios/Runner/Info.plist)
   Add inside <dict>:
   
   <key>GADApplicationIdentifier</key>
   <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
   <key>SKAdNetworkItems</key>
   <array>
     <dict>
       <key>SKAdNetworkIdentifier</key>
       <string>cstr6suwn9.skadnetwork</string>
     </dict>
   </array>

5. ENABLE ADS IN CODE
   - Uncomment the import at the top of this file
   - Uncomment the initialization code
   - Call AdService.instance.initialize() in main.dart

================================================================================
*/
