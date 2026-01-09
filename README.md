# 💧 Perfect Pour

A precision liquid pouring game built with Flutter. Fill containers to the **exact target level** - no more, no less!

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎮 Game Concept

**Perfect Pour** is a simple yet addictive game where players must:
1. Hold to pour liquid into a container
2. Release at the **exact target percentage**
3. Earn stars based on accuracy
4. Progress through **100 levels** of increasing difficulty

### Features
- 💧 **4 Liquid Types**: Water, Honey, Oil, Lava (each with unique physics)
- 🎯 **100 Levels**: Progressive difficulty with shrinking margins
- ⏱️ **Time Challenges**: Later levels add time pressure
- ⭐ **Star Rating**: 1-3 stars based on precision
- 🏆 **Progress Tracking**: Save your best scores
- 📱 **Beautiful UI**: Smooth animations and satisfying visuals
- 💰 **Ad-Ready**: AdMob integration ready

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart 3.0+
- Chrome (for web) / iOS Simulator / Android Emulator

### Quick Start (Copy & Paste)

```bash
# Navigate to project
cd /Users/avinashkharche/Learn/PycharmProjects/game-2

# Initialize Flutter project (creates platform folders)
flutter create . --org com.perfectpour --project-name perfect_pour

# Install dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome
```

### Run on Different Platforms

**🌐 Web (Chrome):**
```bash
flutter run -d chrome
```

**📱 iOS Simulator:**
```bash
open -a Simulator
flutter run -d ios
```

**🤖 Android Emulator:**
```bash
flutter emulators --launch <emulator_name>
flutter run -d android
```

**📲 Physical Device:**
```bash
flutter devices                    # List connected devices
flutter run -d <device_id>         # Run on specific device
```

### Build for Release

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (requires Mac + Xcode):**
```bash
flutter build ios --release
# Then archive in Xcode for App Store
```

**Web:**
```bash
flutter build web --release
# Output: build/web/ (deploy to any web server)
```

### Troubleshooting

**Flutter not found:**
```bash
# Check installation
flutter doctor

# If not installed, on macOS:
brew install --cask flutter
```

**Dependencies issues:**
```bash
flutter clean
flutter pub get
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── level.dart           # Level configuration & generation
│   └── liquid_type.dart     # Liquid types with properties
├── screens/
│   ├── home_screen.dart     # Main menu
│   ├── game_screen.dart     # Core gameplay
│   └── level_select_screen.dart
├── services/
│   ├── game_state.dart      # Progress management
│   └── ad_service.dart      # AdMob integration
├── utils/
│   └── app_theme.dart       # Colors, styles, gradients
└── widgets/
    ├── animated_background.dart
    ├── glass_button.dart
    ├── liquid_container.dart  # Main game container
    ├── liquid_drop_animation.dart
    ├── pouring_stream.dart
    └── result_overlay.dart
```

## 🎯 Gameplay Mechanics

### Difficulty Progression
| Levels | Margin | Liquid Type | Time Limit |
|--------|--------|-------------|------------|
| 1-10   | ±8%    | Water       | None       |
| 11-25  | ±6%    | Water       | None       |
| 26-50  | ±4%    | Honey       | None       |
| 51-60  | ±2.5%  | Oil         | None       |
| 61-75  | ±2.5%  | Oil         | 15s        |
| 76-90  | ±1.5%  | Lava        | 10s        |
| 91-100 | ±1%    | Lava        | 7s         |

### Liquid Properties
| Liquid | Pour Speed | Description |
|--------|------------|-------------|
| 💧 Water | Fast (1.0x) | Easy to control, flows quickly |
| 🍯 Honey | Slow (0.4x) | Viscous, very slow pour |
| 🛢️ Oil | Medium (0.7x) | Moderate speed |
| 🌋 Lava | Slow (0.5x) | Thick and unpredictable |

## 💰 Monetization (AdMob)

The game is set up for AdMob with three ad types:

1. **Rewarded Ads**: Watch to get hints or continue
2. **Interstitial Ads**: Between games (every 3 games)
3. **Banner Ads**: On menu screens (optional)

### Enable Ads

See `lib/services/ad_service.dart` for detailed setup instructions.

Quick steps:
1. Create AdMob account at [admob.google.com](https://admob.google.com)
2. Add your App IDs to `AndroidManifest.xml` and `Info.plist`
3. Replace test ad unit IDs with production IDs
4. Uncomment the initialization code

## 🎨 Customization

### Colors
Edit `lib/utils/app_theme.dart` to customize:
- Background gradients
- Liquid colors
- Accent colors
- Button styles

### Levels
Edit `lib/models/level.dart` to:
- Add more levels
- Change difficulty curve
- Modify target percentages
- Adjust margins of error

## 🔧 Dependencies

```yaml
dependencies:
  provider: ^6.1.1          # State management
  shared_preferences: ^2.2.2 # Local storage
  flutter_animate: ^4.3.0    # Animations
  google_mobile_ads: ^4.0.0  # AdMob (optional)
  audioplayers: ^5.2.1       # Sound effects
```

## 📱 Screenshots

*Add your screenshots here*

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community for inspiration

---

Made with ❤️ and Flutter
