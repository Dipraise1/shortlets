# Complete Auth0 Setup Guide for Flutter Mobile App

## Your App Configuration:
- **Auth0 Domain**: `dev-u8zgmufz2dsmixi8.us.auth0.com`
- **Bundle Identifier**: `com.example.shortletApartments`
- **Client ID**: `WA8Li160ytkh67bxesZ5LmYdhjK7Verh`
- **Application Type**: Native (Mobile)

## 📋 Auth0 Dashboard Settings:

Go to: [Auth0 Dashboard](https://manage.auth0.com/) → Applications → **abujashortlets** → Settings

### 1. Initiate Login URI ⚠️
**For Flutter mobile apps, LEAVE THIS EMPTY or set to placeholder:**

- **Recommended**: Leave it **empty/blank** ✅
- **If required by Auth0**: Use placeholder:
  ```
  https://dev-u8zgmufz2dsmixi8.us.auth0.com/login
  ```

**Why?** The Initiate Login URI is for web apps that redirect to Auth0. Your Flutter app uses the SDK directly, so this field is not used.

### 2. Allowed Callback URLs ✅ (REQUIRED)
Add both URLs (comma-separated, no spaces):
```
https://dev-u8zgmufz2dsmixi8.us.auth0.com/ios/com.example.shortletApartments/callback,com.example.shortletApartments://dev-u8zgmufz2dsmixi8.us.auth0.com/ios/com.example.shortletApartments/callback
```

### 3. Allowed Logout URLs ✅ (REQUIRED)
Add both URLs (comma-separated, no spaces):
```
https://dev-u8zgmufz2dsmixi8.us.auth0.com/ios/com.example.shortletApartments/callback,com.example.shortletApartments://dev-u8zgmufz2dsmixi8.us.auth0.com/ios/com.example.shortletApartments/callback
```

### 4. Application Type
Make sure it's set to **Native** (not Single Page Application or Regular Web Application)

## 🔍 Explanation of URLs:

- **HTTPS URL** (`https://...`): Used for Universal Links on iOS 17.4+ (more secure)
- **Custom Scheme URL** (`com.example.shortletApartments://...`): Fallback for older iOS versions

The Auth0 Flutter SDK automatically chooses the appropriate URL based on the iOS version.

## ✅ After Configuration:

1. **Click "Save Changes"** in Auth0 Dashboard
2. **Wait 1-2 minutes** for changes to propagate
3. **Rebuild your app**:
   ```bash
   flutter clean
   flutter run
   ```
4. **Test login** - The callback URL mismatch error should be resolved!

## 🐛 Troubleshooting:

If you still get callback URL errors:
- Double-check the bundle identifier matches: `com.example.shortletApartments`
- Ensure URLs are comma-separated with NO spaces
- Wait a few minutes after saving - Auth0 changes can take time to propagate
- Check that Application Type is set to **Native**

