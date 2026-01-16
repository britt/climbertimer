# TestFlight Upload Instructions

This document describes the process for building and uploading ClimberTimer to TestFlight.

## Prerequisites

- Xcode with Apple ID signed in (Xcode → Settings → Accounts)
- xcodegen installed (`brew install xcodegen`)
- fastlane installed via bundler (`bundle install`)

## Quick Reference

```bash
# 1. Regenerate project
xcodegen generate

# 2. Build for App Store
SKIP_GIT_CHECK=true bundle exec fastlane run build_app scheme:"ClimberTimer" configuration:"Release" export_method:"app-store"

# 3. Find the archive
ARCHIVE=$(ls -td ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/*.xcarchive | head -1)

# 4. Create export options and upload
cat > /tmp/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>destination</key>
    <string>upload</string>
    <key>teamID</key>
    <string>T3WWQ3395H</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "build/export" \
  -exportOptionsPlist /tmp/ExportOptions.plist \
  -allowProvisioningUpdates

# 5. Clean up build artifacts
rm -f ClimberTimer.ipa ClimberTimer.app.dSYM.zip
```

## Detailed Steps

### Step 1: Ensure project.yml is Configured

The `project.yml` must have:

```yaml
settings:
  SWIFT_VERSION: "5.9"
  ENABLE_USER_SCRIPT_SANDBOXING: false
  DEVELOPMENT_TEAM: T3WWQ3395H  # Required for signing
```

Bundle identifiers must match Apple Developer Portal:
- Main app: `com.snugglebearteam.climbertimer`
- Widgets: `com.snugglebearteam.climbertimer.widgets`
- Watch: `com.snugglebearteam.climbertimer.watchkitapp`

App group must be: `group.com.snugglebearteam.climbertimer`

### Step 2: Regenerate Xcode Project

```bash
xcodegen generate
```

This regenerates `ClimberTimer.xcodeproj` from `project.yml` with the correct signing configuration.

### Step 3: Build and Archive

```bash
SKIP_GIT_CHECK=true bundle exec fastlane run build_app \
  scheme:"ClimberTimer" \
  configuration:"Release" \
  export_method:"app-store"
```

This:
- Creates an archive at `~/Library/Developer/Xcode/Archives/YYYY-MM-DD/`
- Exports `ClimberTimer.ipa` to the current directory
- Creates `ClimberTimer.app.dSYM.zip` for crash symbolication

### Step 4: Create ExportOptions.plist

```bash
cat > /tmp/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>destination</key>
    <string>upload</string>
    <key>teamID</key>
    <string>T3WWQ3395H</string>
</dict>
</plist>
EOF
```

**Critical setting**: `destination: upload` tells xcodebuild to upload directly to App Store Connect.

### Step 5: Export and Upload

```bash
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "build/export" \
  -exportOptionsPlist /tmp/ExportOptions.plist \
  -allowProvisioningUpdates
```

**Critical flag**: `-allowProvisioningUpdates` allows xcodebuild to use Xcode's stored Apple ID credentials. No separate API keys needed.

Expected output:
```
Starting upload
Progress 100%: Upload succeeded.
Uploaded ClimberTimer
** EXPORT SUCCEEDED **
```

### Step 6: Clean Up

```bash
rm -f ClimberTimer.ipa ClimberTimer.app.dSYM.zip
```

## Important Notes

### Authentication
- Uses Xcode's stored credentials (Xcode → Settings → Accounts)
- No API keys, environment variables, or keychain configuration needed
- The `-allowProvisioningUpdates` flag is what enables this

### What NOT to Do
- Don't use `fastlane upload_to_testflight` - requires separate API key configuration
- Don't use `xcrun altool` - requires API key files in specific locations
- Don't try passing API keys via environment variables
- Don't use `fastlane beta` lane - it tries to increment build number which doesn't work with this project

### Troubleshooting

**"Signing requires a development team"**
- Ensure `DEVELOPMENT_TEAM: T3WWQ3395H` is in project.yml settings
- Run `xcodegen generate` to regenerate the project

**"No profiles found for bundle ID"**
- Bundle IDs in project.yml must match Apple Developer Portal exactly
- Use `com.snugglebearteam.climbertimer`, not `com.climbertimer.ios`

**"App Group not supported"**
- App group must be `group.com.snugglebearteam.climbertimer`
- Update both project.yml and the .entitlements files

**Upload authentication fails**
- Ensure Apple ID is signed in via Xcode → Settings → Accounts
- The account must have access to the app in App Store Connect
