# Email Link Authentication Setup Guide

## ✅ Features Added

1. **Email Link (Passwordless) Login**: Users can sign in by clicking a magic link sent to their email
2. **Email OTP Login**: Already existed, now enhanced
3. **Beautiful UI**: Clean and user-friendly interface

## 🔧 Firebase Console Setup

### Step 1: Enable Email Link Authentication

1. Go to **Firebase Console**: https://console.firebase.google.com
2. Select your project: **fittrack_plus**
3. Go to **Authentication** → **Sign-in method**
4. Click on **Email/Password** provider
5. Enable both:
   - ✅ **Email/Password**
   - ✅ **Email link (passwordless sign-in)**
6. Click **Save**

### Step 2: Configure Authorized Domains

1. In **Authentication** → **Settings** → **Authorized domains**
2. Make sure these are added:
   - `localhost` (for development)
   - `fittrack-plus.firebaseapp.com` (auto-added)
   - Your custom domain (if any)

### Step 3: Update Dynamic Links (Optional but Recommended)

For better email link handling:

1. Go to **Engage** → **Dynamic Links**
2. Click **Get Started** if not set up
3. Create a domain: `fittrackplus.page.link` (or your preferred name)
4. Update the domain in code (see below)

## 📝 Code Configuration

### Update Email Link Settings

In [auth_service.dart](lib/app/services/auth_service.dart), update line ~388:

```dart
final actionCodeSettings = ActionCodeSettings(
  url: 'https://fittrackplus.page.link/emailSignIn', // Update this
  handleCodeInApp: true,
  androidPackageName: 'com.example.fittrack_plus',
  androidInstallApp: true,
  androidMinimumVersion: '21',
  dynamicLinkDomain: 'fittrackplus.page.link', // Update this
);
```

**Replace:**
- `fittrackplus.page.link` → Your Firebase Dynamic Link domain
- `com.example.fittrack_plus` → Your actual package name

## 🎯 How It Works

### User Flow:

1. **User enters email** on the Email Link Auth screen
2. **Firebase sends email** with a magic link
3. **User clicks link** in their email
4. **App opens automatically** (if on mobile)
5. **User is signed in** without password!

### For Development/Testing:

Since email sending requires:
- Cloud Functions OR
- Third-party email service (SendGrid, Mailgun, etc.)

**Current Setup:**
- Email OTP is logged to console for development
- Email Link requires Firebase to send the email automatically (works out of the box!)

## 📧 Email Sending Options

### Option 1: Firebase Email (Built-in) - **RECOMMENDED**
Email Link authentication sends emails automatically through Firebase. No extra setup needed!

### Option 2: Cloud Functions (For Email OTP)

To send actual emails for OTP:

1. Create a Cloud Function:

```javascript
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

exports.sendEmailOTP = functions.https.onCall(async (data, context) => {
  const { email, otp } = data;
  
  // Configure email service (e.g., Gmail, SendGrid)
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'your-email@gmail.com',
      pass: 'your-app-password'
    }
  });
  
  await transporter.sendMail({
    from: 'FitTrack Plus <noreply@fittrackplus.com>',
    to: email,
    subject: 'Your OTP Code',
    html: `
      <h1>Your OTP Code</h1>
      <p>Your verification code is: <strong>${otp}</strong></p>
      <p>This code will expire in 10 minutes.</p>
    `
  });
  
  return { success: true };
});
```

2. Deploy: `firebase deploy --only functions`

3. Uncomment email sending code in auth_service.dart

### Option 3: Third-Party Email API

Use services like:
- **SendGrid**: https://sendgrid.com
- **Mailgun**: https://mailgun.com
- **AWS SES**: https://aws.amazon.com/ses

## 🚀 Testing

### Test Email Link Login:

1. Run the app: `flutter run`
2. Tap **Login** → **Sign in with Email Link**
3. Enter your email
4. Check email inbox
5. Click the link
6. Should auto-login!

### Test on Real Device:

Email links work best on real devices where the app can handle deep links.

**Android Setup (AndroidManifest.xml):**

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:host="fittrackplus.page.link"
        android:scheme="https"/>
</intent-filter>
```

## 📱 UI Screens

### New Screens Added:

1. **Email Link Auth View** (`email_link_auth_view.dart`)
   - Enter email
   - Send link
   - Status screen

2. **Email Link Controller** (`email_link_auth_controller.dart`)
   - Send link logic
   - Verify link logic
   - Error handling

## 🔐 Security Features

- ✅ **No password storage**
- ✅ **Time-limited links** (expire after use)
- ✅ **Email verification** built-in
- ✅ **Secure Firebase Auth**

## 🐛 Troubleshooting

### "Invalid email link" error:
- Make sure the link is opened in the same device/browser
- Check if Dynamic Links are configured correctly

### Email not received:
- Check spam folder
- Verify email in Firebase Console authorized domains
- Make sure Email Link is enabled in Firebase

### App doesn't open from link:
- Check AndroidManifest.xml deep link configuration
- Test on real device (deep links don't work in emulator)

## 📚 Additional Resources

- [Firebase Email Link Docs](https://firebase.google.com/docs/auth/android/email-link-auth)
- [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links)
- [GetX Navigation](https://github.com/jonataslaw/getx)

## ✨ What's Next?

Optional improvements:
1. Add email templates customization
2. Add remember me functionality
3. Add biometric authentication
4. Add social logins (Facebook, Apple)

---

**Status:** ✅ Email Link Authentication Ready
**Next Step:** Enable in Firebase Console and test!
