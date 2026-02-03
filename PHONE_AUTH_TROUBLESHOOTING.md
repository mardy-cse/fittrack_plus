# Phone Authentication Troubleshooting Guide

## Current Status
You've completed the basic Firebase Phone Authentication setup, but OTP is not being sent.

## Changes Made
1. ✅ Added INTERNET permission to AndroidManifest.xml
2. ✅ Added ACCESS_NETWORK_STATE permission
3. ✅ Improved error handling with detailed logging
4. ✅ Increased timeout to 120 seconds
5. ✅ Added phone-specific error codes

## Diagnostic Steps

### Step 1: Check Debug Logs
After running the app, check the Flutter console for these debug messages:
```
🔐 Starting phone verification for: +88...
📱 SMS code sent successfully!
```

If you see errors instead, note the exact error code and message.

### Step 2: Common Issues & Solutions

#### Issue: "app-not-authorized"
**Solution:**
1. Go to Firebase Console → Authentication → Sign-in method
2. Click "Phone" provider
3. Scroll to "Phone numbers for testing" section
4. Make sure your number is NOT in test numbers (remove it if present)
5. Click "Save"

#### Issue: "invalid-phone-number"
**Solution:**
- Ensure format is: +880XXXXXXXXXX (for Bangladesh)
- Example: +8801712345678
- The code automatically adds +88 if you enter 01712345678

#### Issue: "quota-exceeded"
**Solution:**
- Firebase has SMS limits:
  - 10 SMS/day for free tier
  - Wait 24 hours or upgrade to Blaze plan
- Check: Firebase Console → Usage tab

#### Issue: "captcha-check-failed" or no OTP received
**Solutions:**

1. **Enable SafetyNet/Play Integrity API** (CRITICAL):
   ```
   - Go to: https://console.cloud.google.com/apis/library
   - Search: "Android Device Verification"
   - Enable: "Android Device Verification API"
   - Search: "Play Integrity API"
   - Enable: "Play Integrity API"
   ```

2. **Verify SHA Keys in Firebase:**
   - Run: `cd android && ./gradlew signingReport`
   - Copy SHA-1 and SHA-256
   - Firebase Console → Project Settings → Your Android app
   - Add both fingerprints if missing
   - Download NEW google-services.json
   - Replace android/app/google-services.json

3. **Check App Package Name Match:**
   - Firebase Console: com.example.fittrack_plus
   - android/app/build.gradle.kts: applicationId should match

4. **Enable Phone Authentication:**
   - Firebase Console → Authentication → Sign-in method
   - Phone should be "Enabled"

### Step 3: Test with Firebase Test Number (Debug Only)

For testing without real SMS:

1. Firebase Console → Authentication → Sign-in method → Phone
2. Scroll to "Phone numbers for testing"
3. Add test number: +8801700000000
4. Set test code: 123456
5. Save

Now test with:
- Phone: 01700000000
- Code: 123456 (will work without SMS)

⚠️ **Remove test number after debugging to receive real OTPs**

### Step 4: Verify Google Cloud Project

1. Open: https://console.cloud.google.com/
2. Select your Firebase project
3. APIs & Services → Enabled APIs
4. Verify these are enabled:
   - ✅ Identity Toolkit API
   - ✅ Cloud Firestore API
   - ✅ Firebase Authentication API
   - ✅ Android Device Verification API
   - ✅ Play Integrity API

### Step 5: Check Network & Firewall

1. Ensure device has internet connection
2. Try on real Android device (not emulator)
3. Check if firewall blocking Firebase domains:
   - firebaseapp.com
   - googleapis.com
   - firebaseio.com

### Step 6: Clean Rebuild

```bash
# Clean everything
flutter clean
cd android
./gradlew clean
cd ..

# Reinstall dependencies
flutter pub get

# Rebuild
flutter run
```

### Step 7: Check Build Configuration

Verify `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    applicationId = "com.example.fittrack_plus"
    minSdk = 21  // Firebase requires minimum 21
}
```

## Debugging Commands

### View Firebase Auth Logs:
```bash
# Run app with verbose logging
flutter run -v
```

### Check Package Name:
```bash
cd android
./gradlew properties | grep applicationId
```

### Verify google-services.json:
Open `android/app/google-services.json` and verify:
- `package_name` matches your app
- `client_id` is present
- Multiple `oauth_client` entries exist

## Expected Flow

1. User enters phone: 01712345678
2. App formats to: +8801712345678
3. Firebase sends OTP via SMS
4. Debug log shows: "📱 SMS code sent successfully!"
5. User receives SMS with 6-digit code
6. User enters code and verifies

## Still Not Working?

### Check these in order:

1. **Run with debug logging enabled:**
   - Watch console for emoji debug messages
   - Note exact error code

2. **Test with another phone number:**
   - Try different carrier (GP, Robi, Banglalink)
   - Some carriers may block automated SMS

3. **Check Firebase Console → Authentication → Users:**
   - Are there any failed attempts logged?
   - Any quota warnings?

4. **Firebase Console → Authentication → Settings:**
   - Check "Authorized domains"
   - Add localhost if testing

5. **Update Firebase dependencies:**
   ```yaml
   # In pubspec.yaml
   firebase_core: ^3.8.1
   firebase_auth: ^5.3.3
   ```

## Quick Verification Checklist

Before each test run, verify:

- [ ] Internet connection active
- [ ] SHA keys added to Firebase
- [ ] google-services.json updated
- [ ] Phone provider enabled in Firebase
- [ ] Test number removed from Firebase
- [ ] Play Integrity API enabled
- [ ] Android Device Verification API enabled
- [ ] Package name matches (com.example.fittrack_plus)
- [ ] Clean build done (flutter clean)
- [ ] Testing on real device (not emulator)

## Emergency Fallback

If still failing, temporarily use test number to verify code logic:
1. Add test number in Firebase: +8801700000000 → 123456
2. Test complete flow
3. Debug any other issues
4. Remove test number
5. Try real number again

## Need More Help?

Check exact error from logs and match with Firebase docs:
https://firebase.google.com/docs/auth/android/phone-auth

## Contact Support

If all else fails:
1. Screenshot error logs
2. Screenshot Firebase console settings
3. Post in Firebase Stack Overflow with tag `firebase-authentication`
