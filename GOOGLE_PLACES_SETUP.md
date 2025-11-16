# Google Places API Setup Guide

This guide explains how to set up Google Places API to fetch apartment listings from Google for Abuja, Lagos, Port Harcourt, and Nigeria-wide searches.

## Why Google Places API?

The previous implementation was scraping Google Travel pages, which is:
- ❌ Unreliable (HTML structure changes frequently)
- ❌ Against Google's Terms of Service
- ❌ Fragile and breaks easily
- ❌ Doesn't provide structured data

Google Places API is:
- ✅ Official and supported by Google
- ✅ Provides structured, reliable data
- ✅ Includes photos, ratings, contact info
- ✅ Has proper error handling
- ✅ Free tier available ($200/month credit)

## Setup Steps

### 1. Get a Google Cloud Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Create a new project or select an existing one

### 2. Enable Google Places API

1. Navigate to **APIs & Services** > **Library**
2. Search for "Places API"
3. Click on **Places API** and click **Enable**
4. Also enable **Places API (New)** if available (for better features)

### 3. Create API Key

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **API Key**
3. Copy your API key
4. **Important**: Restrict your API key for security:
   - Click on the API key to edit it
   - Under **API restrictions**, select **Restrict key**
   - Choose **Places API** only
   - Under **Application restrictions**, you can restrict by:
     - **Android apps** (for Android builds)
     - **iOS apps** (for iOS builds)
     - **HTTP referrers** (for web builds)
     - Or leave unrestricted for development

### 4. Add API Key to Your App

1. Open `lib/services/apartment_service.dart`
2. Find the line:
   ```dart
   static const String _googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
   ```
3. Replace `YOUR_GOOGLE_PLACES_API_KEY` with your actual API key:
   ```dart
   static const String _googlePlacesApiKey = 'AIzaSy...your-actual-key';
   ```

### 5. Test the Implementation

Run your app and try fetching apartments. The service will:
1. First try Google Places Text Search API
2. If no results, try Nearby Search API
3. Fall back to static data if API fails

## API Pricing

Google Places API has a free tier:
- **$200/month free credit** (enough for ~40,000 requests)
- After free tier:
  - Text Search: $32 per 1,000 requests
  - Nearby Search: $32 per 1,000 requests
  - Place Details: $17 per 1,000 requests
  - Photos: $7 per 1,000 requests

For a small app, the free tier should be sufficient.

## Alternative Data Sources

If Google Places API doesn't meet your needs, you can extend `_fetchFromAlternativeSources()` to integrate:

### Nigerian Real Estate APIs:
- **PropertyPro API** - Nigerian property listings
- **ToLet API** - Rental properties
- **Private Property API** - Real estate listings
- **Jumia House API** - Property listings

### Other Options:
- **Airbnb API** (if available)
- **Booking.com API** (for short-term rentals)
- **Custom backend** that aggregates multiple sources

## How It Works

### Current Implementation:

1. **Text Search** (`_fetchFromGooglePlacesTextSearch`):
   - Searches for "shortlet apartments [City] Nigeria"
   - Returns lodging-type places
   - Best for general searches

2. **Nearby Search** (`_fetchFromGooglePlacesNearby`):
   - Uses city coordinates to find nearby places
   - Searches within 10km radius
   - Uses keyword "shortlet apartment"
   - Fallback if Text Search fails

3. **Data Parsing** (`_parseGooglePlacesResults`):
   - Converts Google Places results to your `Property` model
   - Estimates price from price_level (0-4 scale)
   - Extracts photos, ratings, contact info
   - Estimates bedrooms/bathrooms from name

### City Support:

- **Abuja**: Coordinates (9.0765, 7.3986)
- **Lagos**: Coordinates (6.5244, 3.3792)
- **Port Harcourt**: Coordinates (4.8156, 7.0498)
- **Nigeria-wide**: Searches without city restriction

## Usage Example

```dart
// Fetch Abuja apartments
final abujaApartments = await ApartmentService.fetchApartments(city: 'Abuja');

// Fetch Lagos apartments
final lagosApartments = await ApartmentService.fetchApartments(city: 'Lagos');

// Fetch Nigeria-wide apartments
final allApartments = await ApartmentService.fetchApartments();
```

## Troubleshooting

### "API key not configured" message
- Make sure you've added your API key to `apartment_service.dart`
- Check that the key is correct (no extra spaces)

### "REQUEST_DENIED" error
- Check that Places API is enabled in Google Cloud Console
- Verify API key restrictions allow Places API
- Ensure billing is enabled (even for free tier)

### "ZERO_RESULTS" status
- Try different search queries
- Check if there are actually places in that area
- Consider using alternative sources

### No results but API works
- Google Places may not have many "shortlet apartment" listings
- Try broader searches like "apartments" or "lodging"
- Consider integrating Nigerian-specific real estate APIs

## Security Best Practices

1. **Never commit API keys to version control**
   - Use environment variables or secure storage
   - Consider using `flutter_dotenv` package
   - Add `.env` to `.gitignore`

2. **Restrict API keys**
   - Limit to specific APIs (Places API only)
   - Restrict by app/platform when possible
   - Set up usage quotas

3. **Monitor usage**
   - Set up billing alerts in Google Cloud Console
   - Monitor API usage regularly
   - Set daily/monthly quotas

## Next Steps

1. Set up your Google Places API key
2. Test the implementation
3. Consider adding more data sources
4. Implement caching to reduce API calls
5. Add error handling and retry logic
6. Consider using Place Details API for more information

## Resources

- [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Places API Pricing](https://mapsplatform.google.com/pricing/)
- [Flutter HTTP Package](https://pub.dev/packages/http)

