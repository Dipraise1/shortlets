# shortlets

A Flutter app for finding shortlet apartments in Abuja, Nigeria and other Nigerian cities.

## Features

- 🔐 Auth0 authentication
- 🏠 Browse shortlet apartments in Abuja, Lagos, Port Harcourt
- ⭐ Save favorite properties
- 💬 Messaging system
- 👤 User profile management

## Setup

1. Clone the repository
2. Copy `.env.example` to `.env` and fill in your API keys:
   ```bash
   cp .env.example .env
   ```
3. Add your credentials to `.env`:
   - `AUTH0_DOMAIN` - Your Auth0 domain
   - `AUTH0_CLIENT_ID` - Your Auth0 client ID
   - `AUTH0_CLIENT_SECRET` - Your Auth0 client secret
   - `GOOGLE_PLACES_API_KEY` - Your Google Places API key

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Environment Variables

All sensitive keys are stored in `.env` file which is gitignored. See `.env.example` for the required variables.

## Getting Started

This project uses Flutter. For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/).
