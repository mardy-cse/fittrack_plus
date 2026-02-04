# Email Service Setup Guide (Resend API)

## 🎯 Overview
This guide will help you set up email OTP delivery using Resend API. Real emails will be sent to users when they sign up.

## 📋 Prerequisites
- A Resend account (free tier: 100 emails/day, 3000/month)
- Valid email address for testing

## 🚀 Setup Steps

### Step 1: Create Resend Account

1. Go to [https://resend.com](https://resend.com)
2. Click "Sign Up" (free account)
3. Verify your email address
4. Complete onboarding

### Step 2: Get API Key

1. Login to your Resend dashboard
2. Go to **API Keys** section
3. Click **"Create API Key"**
4. Give it a name (e.g., "FitTrack Plus Development")
5. Select permissions: **"Sending access"**
6. Copy the API key (starts with `re_...`)
   - ⚠️ Save it securely - you won't see it again!

### Step 3: Configure API Key in App

1. Open `lib/app/services/email_service.dart`
2. Find this line:
   ```dart
   static const String _apiKey = 'YOUR_RESEND_API_KEY';
   ```
3. Replace `YOUR_RESEND_API_KEY` with your actual API key:
   ```dart
   static const String _apiKey = 're_AbCdEf123456...';
   ```

### Step 4: Configure Sender Email

#### Option A: Use Resend Test Email (Quick Start)
The default sender is already set to:
```dart
static const String _senderEmail = 'FitTrack+ <onboarding@resend.dev>';
```
This works immediately - no domain verification needed!

#### Option B: Use Your Own Domain (Production)
1. In Resend dashboard, go to **Domains**
2. Click **"Add Domain"**
3. Enter your domain (e.g., `fittrackplus.com`)
4. Add DNS records:
   - SPF: `v=spf1 include:_spf.resend.com ~all`
   - DKIM: (provided by Resend)
   - DMARC: (optional but recommended)
5. Wait for verification (usually 5-10 minutes)
6. Update sender email in `email_service.dart`:
   ```dart
   static const String _senderEmail = 'FitTrack+ <noreply@yourdomain.com>';
   ```

### Step 5: Install Dependencies

Run in terminal:
```bash
flutter pub get
```

### Step 6: Test Email Sending

1. Run your app:
   ```bash
   flutter run
   ```
2. Go to Sign Up screen
3. Enter a **real email address** (your own for testing)
4. Fill in name and password
5. Click "Sign Up"
6. Check your email inbox for the OTP

## 📧 Email Template

The OTP email includes:
- Professional HTML design
- 6-digit verification code
- 10-minute expiration notice
- Security tips
- FitTrack+ branding

## 🔍 Troubleshooting

### Email Not Received?

1. **Check Spam/Junk folder**
2. **Verify API key** in `email_service.dart`
3. **Check Resend dashboard** > Logs for error messages
4. **Check console output** in VS Code terminal:
   ```
   ✅ Email sent successfully to user@example.com
   ```
   or
   ```
   ❌ Failed to send email: 401
   ```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `401 Unauthorized` | Invalid API key | Double-check API key in `email_service.dart` |
| `403 Forbidden` | Domain not verified | Use `onboarding@resend.dev` or verify your domain |
| `429 Too Many Requests` | Rate limit exceeded | Wait or upgrade plan |
| `422 Validation Error` | Invalid recipient email | Check email format |

### Check Email Status

1. Go to Resend Dashboard > **Emails**
2. See all sent emails with status:
   - ✅ **Delivered** - Success!
   - ⏳ **Queued** - Processing
   - ❌ **Failed** - Check error details

## 🧪 Development vs Production

### Development Mode
- If API key is not configured (`YOUR_RESEND_API_KEY`)
- OTP shown in snackbar (15 seconds)
- OTP printed to console
- No actual email sent

### Production Mode
- API key configured
- Real emails sent via Resend
- OTP still shown in snackbar temporarily (can remove later)
- Firestore stores OTP for verification

## 📊 Resend Free Tier Limits

- **100 emails per day**
- **3,000 emails per month**
- **Unlimited** API calls
- **1 custom domain**
- Test domain included

Perfect for development and small apps!

## 🔒 Security Best Practices

1. **Never commit API key to Git**
   - Add to `.gitignore` if storing in separate file
   - Use environment variables for production

2. **Rate limiting**
   - Already implemented: 10-minute OTP expiration
   - Consider adding resend cooldown (60 seconds)

3. **Email validation**
   - Already implemented: Email format check
   - Already implemented: Duplicate email check

4. **Monitor usage**
   - Check Resend dashboard regularly
   - Set up usage alerts

## 🎨 Customizing Email Template

Edit `_buildEmailHTML()` in `email_service.dart`:

```dart
String _buildEmailHTML({required String recipientName, required String otp}) {
  return '''
  <!DOCTYPE html>
  <html>
  <!-- Your custom HTML here -->
  </html>
  ''';
}
```

## 📱 Next Steps

After setup:
1. ✅ Test with your email
2. ✅ Test with other email addresses
3. ✅ Test spam folder delivery
4. ✅ Customize email template (optional)
5. ✅ Set up custom domain (optional)
6. ✅ Remove development mode snackbar (optional)

## 🆘 Need Help?

- Resend Docs: https://resend.com/docs
- Resend Support: support@resend.com
- Resend Discord: https://discord.gg/resend

## ✅ Verification Checklist

- [ ] Resend account created
- [ ] API key obtained
- [ ] API key added to `email_service.dart`
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Test email received successfully
- [ ] Email appears in inbox (not spam)
- [ ] OTP code works for verification
- [ ] Firestore OTP record created

---

**Status**: Email service is fully integrated and ready to use!
