# TestFlight Deployment Guide

This guide covers how to deploy Climber Timer to TestFlight for beta testing.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Enroll at [developer.apple.com](https://developer.apple.com)
   - Enable two-factor authentication

2. **App Store Connect Access**
   - Create app records for iOS and watchOS
   - Bundle IDs:
     - iOS: `com.snugglebearteam.climbertimer.ios`
     - watchOS: `com.snugglebearteam.climbertimer.watchkitapp`

3. **Install Dependencies**
   ```bash
   bundle install
   ```

## App Store Connect Setup

### 1. Create App Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: Climber Timer
   - Primary Language: English
   - Bundle ID: Select from dropdown
   - SKU: climber-timer-ios

### 2. Configure App Privacy

In App Store Connect → App Information → App Privacy:

1. Click "Get Started" on privacy questionnaire
2. For Climber Timer, select:
   - **Data Not Collected** (we don't collect any user data)
3. Save and submit

### 3. Add Privacy Policy URL

Add the privacy policy URL to:
- App Store Connect → App Information → Privacy Policy URL

Host the privacy policy at your domain or use GitHub Pages.

## Local Deployment

### Manual Build and Upload

```bash
# Build archive
xcodebuild -scheme "ClimberTimer" \
  -configuration Release \
  -archivePath build/ClimberTimer.xcarchive \
  archive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/ClimberTimer.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/

# Upload via Xcode Organizer or Transporter app
```

### Using Fastlane

```bash
# Run tests first
bundle exec fastlane test

# Build and upload to TestFlight
bundle exec fastlane beta
```

## Fastlane Setup

### First-Time Setup

1. **Configure App Store Connect API Key**

   Create an API key at App Store Connect → Users and Access → Keys:
   - Download the .p8 key file
   - Note the Key ID and Issuer ID

2. **Set Environment Variables**
   ```bash
   export ASC_KEY_ID="your_key_id"
   export ASC_ISSUER_ID="your_issuer_id"
   export ASC_KEY_CONTENT=$(cat path/to/AuthKey.p8)
   ```

3. **Set Up Code Signing (Optional - for CI/CD)**
   ```bash
   # Initialize match for certificate management
   bundle exec fastlane match init

   # Create App Store certificates and profiles
   bundle exec fastlane setup_certs
   ```

### Available Lanes

| Lane | Description |
|------|-------------|
| `fastlane test` | Run unit tests |
| `fastlane build` | Build release archive |
| `fastlane beta` | Build and upload iOS app to TestFlight |
| `fastlane beta_watch` | Build and upload watchOS app |
| `fastlane beta_all` | Upload both iOS and watchOS |
| `fastlane sync_certs` | Sync certificates (readonly) |
| `fastlane setup_certs` | Create new certificates |

## CI/CD with GitHub Actions

Create `.github/workflows/testflight.yml`:

```yaml
name: TestFlight Deployment

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install dependencies
        run: bundle install

      - name: Build and upload to TestFlight
        env:
          ASC_KEY_ID: ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
          ASC_KEY_CONTENT: ${{ secrets.ASC_KEY_CONTENT }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: bundle exec fastlane beta
```

## TestFlight Testing

### Internal Testing

- Up to 100 internal testers (team members)
- No App Review required
- Immediate access to new builds

### External Testing

- Up to 10,000 external testers
- Requires App Review for first build
- 90-day build expiration

### Adding Testers

1. Go to App Store Connect → TestFlight
2. Create test groups (Internal/External)
3. Add testers by email
4. Testers receive invitation to install TestFlight app

## Troubleshooting

### Common Issues

1. **"No signing certificate found"**
   - Open Xcode → Preferences → Accounts
   - Download certificates manually
   - Or run `fastlane sync_certs`

2. **"Provisioning profile doesn't match"**
   - Delete old profiles in Xcode Preferences → Accounts
   - Let Xcode automatically manage signing

3. **"Build already exists"**
   - Increment build number: `fastlane run increment_build_number`

4. **"App Review rejection"**
   - Check for crashes on launch
   - Ensure privacy policy is accessible
   - Review [App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## Version Management

- **Version Number** (CFBundleShortVersionString): User-facing version (1.0.0)
- **Build Number** (CFBundleVersion): Internal build identifier (42)

Build number must increase with each TestFlight upload.

---

For more information, see [Apple's TestFlight documentation](https://developer.apple.com/testflight/).
