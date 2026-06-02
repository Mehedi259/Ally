# Google Sign-In Fix for Android

## Problem
Google Sign-In is not working on Android because SHA-1 fingerprint is not configured in Firebase Console.

---

## Your Debug SHA-1 Fingerprint:
```
7C:D7:E8:7B:08:70:F8:CD:CA:28:22:79:A1:52:68:DB:4E:BD:72:E4
```

---

## Solution: Add SHA-1 to Firebase Console

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/
2. Select your project: **"ally-by-avea"**

### Step 2: Navigate to Project Settings
1. Click the **gear icon** (⚙️) next to "Project Overview"
2. Select **"Project settings"**

### Step 3: Add SHA Certificate Fingerprint
1. Scroll down to **"Your apps"** section
2. Find your Android app: `com.example.exploration_project`
3. Click on it to expand
4. Scroll down to **"SHA certificate fingerprints"** section
5. Click **"Add fingerprint"** button
6. Paste this SHA-1:
   ```
   7C:D7:E8:7B:08:70:F8:CD:CA:28:22:79:A1:52:68:DB:4E:BD:72:E4
   ```
7. Click **"Save"**

### Step 4: Download Updated google-services.json
1. After saving, click **"Download google-services.json"** button
2. Replace the old file at: `android/app/google-services.json`
3. **Important:** The file should now contain an OAuth client with `client_type: 1` (Android client)

### Step 5: Rebuild and Test
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter build apk --debug

# Run on device
flutter run
```

---

## Verification

After following these steps, the `google-services.json` should contain an OAuth client like this:

```json
{
  "client_id": "150585545366-XXXXXXXXXX.apps.googleusercontent.com",
  "client_type": 1,  // ← This should be 1 for Android
  "android_info": {
    "package_name": "com.example.exploration_project",
    "certificate_hash": "7cd7e87b0870f8cdca28227979a15268db4ebd72e4"
  }
}
```

---

## Alternative: Manual OAuth Client Creation

If automatic download doesn't include the OAuth client:

### Step 1: Go to Google Cloud Console
1. Visit: https://console.cloud.google.com/
2. Select project: **"ally-by-avea"**

### Step 2: Enable Google Sign-In API
1. Go to **"APIs & Services"** → **"Enabled APIs & services"**
2. Ensure **"Google Sign-In API"** is enabled

### Step 3: Create OAuth 2.0 Client ID
1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"**
3. Select **"OAuth 2.0 Client ID"**
4. Choose **"Android"** as application type
5. Fill in:
   - **Name:** "Android client (auto created by Google Service)"
   - **Package name:** `com.example.exploration_project`
   - **SHA-1 certificate fingerprint:** `7C:D7:E8:7B:08:70:F8:CD:CA:28:22:79:A1:52:68:DB:4E:BD:72:E4`
6. Click **"Create"**

### Step 4: Download Updated Config
1. Return to Firebase Console
2. Download new `google-services.json`
3. Replace in project

---

## For Release Build (Production)

When you create a release APK, you'll need to:

1. Generate a release keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

2. Get SHA-1 from release keystore:
```bash
keytool -list -v -keystore ~/upload-keystore.jks \
  -alias upload -storepass YOUR_PASSWORD
```

3. Add release SHA-1 to Firebase (same steps as above)

---

## Common Errors and Solutions

### Error: "PlatformException(sign_in_failed, ...)"
**Solution:** SHA-1 not added to Firebase. Follow steps above.

### Error: "Error 10: Developer Error"
**Solution:** Package name mismatch or SHA-1 mismatch.
- Verify package name in `android/app/build.gradle.kts` matches Firebase
- Verify SHA-1 matches the one in Firebase Console

### Error: "A non-null String must be provided"
**Solution:** OAuth client not configured properly.
- Ensure `google-services.json` has `client_type: 1` entry
- Re-download from Firebase Console

---

## Testing After Fix

1. Uninstall app from device completely
2. Rebuild and reinstall
3. Try Google Sign-In again
4. Check logs for success message

---

## Quick Reference

**Your Configuration:**
- **Package Name:** com.example.exploration_project
- **Debug SHA-1:** 7C:D7:E8:7B:08:70:F8:CD:CA:28:22:79:A1:52:68:DB:4E:BD:72:E4
- **Firebase Project:** ally-by-avea
- **Project ID:** 150585545366

**Firebase Console:** https://console.firebase.google.com/project/ally-by-avea/settings/general/android:com.example.exploration_project

---

## Need Help?

If you still face issues:
1. Share the exact error message from logs
2. Verify the updated `google-services.json` has OAuth client with `client_type: 1`
3. Make sure you've uninstalled and reinstalled the app after updating config

---

**Last Updated:** June 3, 2026
