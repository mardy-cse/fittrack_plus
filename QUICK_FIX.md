# 🚀 Quick Fix Guide - Phone OTP Not Working

## TL;DR - Do These 3 Things NOW

### 1️⃣ Enable Required APIs (5 minutes) ⚠️ CRITICAL

Open: https://console.cloud.google.com/apis/library

Enable these APIs:
1. Search "**Play Integrity API**" → Click **ENABLE**
2. Search "**Android Device Verification**" → Click **ENABLE**
3. Search "**Identity Toolkit API**" → Should already be enabled

> **This is the #1 reason phone OTP doesn't work!**

---

### 2️⃣ Remove Test Number (1 minute)

1. Open: https://console.firebase.google.com
2. Go to: **Authentication** → **Sign-in method** → **Phone**
3. Scroll to: "**Phone numbers for testing**"
4. **DELETE** your phone number if listed
5. Click **Save**

---

### 3️⃣ Clean Rebuild & Test (2 minutes)

```bash
flutter clean
flutter pub get
flutter run
```

Then test:
1. Open Phone Authentication screen
2. Tap **🐛 bug icon** (top right) to run diagnostics
3. Enter phone: `01712345678`
4. Tap "Send OTP"
5. **Watch console** for:
   - ✅ `📱 SMS code sent successfully!` = Working!
   - ❌ Error message = See troubleshooting below

---

## 📱 Testing

### What to Look For:

**In Console (Debug Log):**
```
🔐 Starting phone verification for: +8801712345678
📱 SMS code sent successfully!
✅ Firebase initialized successfully
```

**On Phone:**
- SMS arrives within 10-60 seconds
- Contains 6-digit code
- From Google/Firebase

---

## ❌ If Still Not Working

### Error: "app-not-authorized"
**Cause:** SHA keys not configured  
**Fix:**
```bash
cd android
./gradlew signingReport
```
Copy **SHA-1** and **SHA-256** to:
Firebase Console → Project Settings → Your App → Add fingerprint

Then download **NEW** `google-services.json` and replace in `android/app/`

---

### Error: "quota-exceeded"
**Cause:** Too many SMS sent today (limit: 10/day on free tier)  
**Fix:**
- Wait 24 hours, OR
- Upgrade to Blaze plan, OR
- Use test number (see below)

---

### Error: "invalid-phone-number"
**Cause:** Wrong format  
**Fix:**
- Bangladesh format: `01712345678` (app auto-adds +88)
- International format: `+8801712345678`

---

### No Error, No SMS
**Possible causes:**
1. No internet connection
2. APIs not enabled (see Step 1)
3. Phone carrier blocking automated SMS
4. Firewall blocking Firebase

**Try:**
- Different network (WiFi ↔ Mobile data)
- Different phone number
- Different carrier

---

## 🧪 Test Mode (For Debugging)

To test without real SMS:

**Firebase Console:**
1. Authentication → Sign-in method → Phone
2. Add test number: `+8801700000000` → Code: `123456`
3. Save

**In App:**
- Phone: `01700000000`
- Code: `123456` (works instantly, no SMS)

> ⚠️ Remove test number after debugging!

---

## ✅ Final Checklist

Before asking for help, confirm:

- [ ] **Play Integrity API** enabled ⚠️ MOST IMPORTANT
- [ ] **Android Device Verification API** enabled
- [ ] Test number removed from Firebase
- [ ] SHA keys added to Firebase
- [ ] Testing on **real device** (not emulator)
- [ ] Internet connected
- [ ] `flutter clean` done
- [ ] Checked console logs during OTP send

---

## 📚 More Help

- **Detailed guide:** [PHONE_AUTH_TROUBLESHOOTING.md](PHONE_AUTH_TROUBLESHOOTING.md)
- **What was fixed:** [PHONE_AUTH_FIX_SUMMARY.md](PHONE_AUTH_FIX_SUMMARY.md)
- **Diagnostic tool:** Tap 🐛 icon in Phone Auth screen

---

## 🆘 Still Stuck?

1. Run diagnostic tool (🐛 button in app)
2. Copy exact error from console
3. Check error in [PHONE_AUTH_TROUBLESHOOTING.md](PHONE_AUTH_TROUBLESHOOTING.md)
4. Try test number mode to isolate issue

**Most common fix:** Enable Play Integrity API ⚠️

---

**Quick Links:**

- [Google Cloud APIs](https://console.cloud.google.com/apis/library)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase Phone Auth Docs](https://firebase.google.com/docs/auth/android/phone-auth)
