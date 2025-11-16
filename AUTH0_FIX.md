# Fixing Auth0 MissingPluginException

The `MissingPluginException` occurs because the native platform code needs to be properly linked. Follow these steps:

## Solution Steps:

### 1. **Stop the App Completely**
   - Stop the running app (not just hot reload)
   - Close the simulator/emulator if needed

### 2. **Clean and Rebuild**
   ```bash
   flutter clean
   flutter pub get
   ```

### 3. **For iOS - Reinstall Pods**
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   ```

### 4. **Rebuild the App (Full Build, Not Hot Reload)**
   ```bash
   flutter run
   ```
   - **Important**: Do NOT use hot reload (r) or hot restart (R)
   - Do a full rebuild by stopping and running again

### 5. **If Still Not Working - Check Platform Configuration**

#### iOS Configuration:
- Make sure you're running on a physical device or simulator (not web)
- The URL scheme in `Info.plist` should match your Auth0 callback URL

#### Android Configuration (if needed):
- Add to `android/app/build.gradle`:
  ```gradle
  android {
    defaultConfig {
      manifestPlaceholders = [
        auth0Domain: "dev-u8zgmufz2dsmixi8.us.auth0.com",
        auth0Scheme: "com.shortletapartments"
      ]
    }
  }
  ```

### 6. **Verify Auth0 Dashboard Settings**
   - Go to Auth0 Dashboard → Applications → abujashortlets → Settings
   - **Allowed Callback URLs**: 
     ```
     com.shortletapartments://dev-u8zgmufz2dsmixi8.us.auth0.com/ios/com.shortletapartments/callback
     ```
   - **Allowed Logout URLs**: 
     ```
     com.shortletapartments://dev-u8zgmufz2dsmixi8.us.auth0.com/ios/com.shortletapartments/callback
     ```

## Alternative: Use Web-Based Auth (Temporary Workaround)

If the native plugin continues to have issues, we can implement a web-based authentication flow using `url_launcher` and handle the callback manually. This is a fallback option.

## Common Issues:

1. **Hot Reload**: Auth0 native plugins don't work with hot reload - you MUST do a full rebuild
2. **Platform**: Make sure you're testing on iOS Simulator or Android Emulator, not web
3. **Pods**: iOS requires CocoaPods to be properly installed and updated

