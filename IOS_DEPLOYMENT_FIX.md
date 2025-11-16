# iOS Deployment Target Fix - Updated for 2025

## ✅ What I've Fixed:

1. **Updated Podfile** - Set iOS platform to 14.0
2. **Updated Xcode Project** - Changed all deployment targets from 12.0 to 14.0
3. **Post-install Script** - Ensures all pods use iOS 14.0 minimum

## 🔧 To Fix CocoaPods Encoding Issue:

The CocoaPods error is due to terminal encoding. Run this in your terminal:

```bash
export LANG=en_US.UTF-8
cd ios
pod install
```

Or add this to your `~/.zshrc` file permanently:
```bash
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
source ~/.zshrc
```

## 📱 Then Run:

```bash
cd /Users/divine/Documents/shortletppartments
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

## ✅ What Changed:

- **iOS Deployment Target**: 12.0 → 14.0 (required for auth0_flutter in 2025)
- **Podfile platform**: Now explicitly set to iOS 14.0
- **Xcode project settings**: All build configurations updated to 14.0

This should resolve the "higher minimum deployment target" error for auth0_flutter.

