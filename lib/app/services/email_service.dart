import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Email service for sending OTP emails using Resend API
///
/// Setup Instructions:
/// 1. Go to https://resend.com and create a free account
/// 2. Verify your domain or use their test domain (onboarding@resend.dev)
/// 3. Get your API key from the dashboard
/// 4. Add the API key to this file (replace 'YOUR_RESEND_API_KEY')
///
/// Free tier: 100 emails/day, 3000/month
class EmailService {
  // TODO: Replace with your Resend API key from https://resend.com
  // Get it from: Dashboard > API Keys > Create API Key
  static const String _apiKey = 're_Y4tchBmF_3BDX1yeB3NB11Qv7QDWK2wHM';

  // Resend API endpoint
  static const String _baseUrl = 'https://api.resend.com/emails';

  // Sender email (must be verified in Resend)
  // For testing, use: onboarding@resend.dev
  // For production, verify your own domain
  static const String _senderEmail = 'FitTrack+ <onboarding@resend.dev>';

  /// Send OTP email to user
  Future<bool> sendOTPEmail({
    required String recipientEmail,
    required String otp,
    required String recipientName,
  }) async {
    try {
      // Check if API key is configured
      if (_apiKey.isEmpty || _apiKey == 'YOUR_RESEND_API_KEY') {
        debugPrint('⚠️ Resend API key not configured!');
        debugPrint('📧 Development Mode - OTP: $otp for $recipientEmail');
        debugPrint('ℹ️ To enable email sending:');
        debugPrint('   1. Get API key from https://resend.com');
        debugPrint('   2. Replace _apiKey in email_service.dart');
        return true; // Return true in development mode
      }

      // Prepare email content
      final emailBody = _buildEmailHTML(recipientName: recipientName, otp: otp);

      // Prepare request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _senderEmail,
          'to': [recipientEmail],
          'subject': 'Your FitTrack+ Verification Code',
          'html': emailBody,
        }),
      );

      // Check response
      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully to $recipientEmail');
        return true;
      } else {
        debugPrint('❌ Failed to send email: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending email: $e');
      return false;
    }
  }

  /// Build HTML email template
  String _buildEmailHTML({required String recipientName, required String otp}) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitTrack+ Verification Code</title>
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f4;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center;">
                            <h1 style="color: #ffffff; margin: 0; font-size: 28px;">FitTrack+</h1>
                            <p style="color: #ffffff; margin: 10px 0 0 0; font-size: 16px;">Your Fitness Journey Starts Here</p>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 30px;">
                            <h2 style="color: #333333; margin: 0 0 20px 0; font-size: 24px;">Hello, $recipientName!</h2>
                            <p style="color: #666666; font-size: 16px; line-height: 1.6; margin: 0 0 20px 0;">
                                Thank you for signing up with FitTrack+. To complete your registration, please use the verification code below:
                            </p>
                            
                            <!-- OTP Box -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                                <tr>
                                    <td align="center" style="background-color: #f8f9fa; border-radius: 8px; padding: 30px;">
                                        <div style="font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 8px; font-family: 'Courier New', monospace;">
                                            $otp
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="color: #666666; font-size: 14px; line-height: 1.6; margin: 20px 0;">
                                This code will expire in <strong>10 minutes</strong>. If you didn't request this code, please ignore this email.
                            </p>
                            
                            <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px;">
                                <p style="color: #856404; font-size: 14px; margin: 0;">
                                    <strong>Security Tip:</strong> Never share this code with anyone. FitTrack+ will never ask for your verification code.
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
                            <p style="color: #999999; font-size: 14px; margin: 0 0 10px 0;">
                                Need help? Contact us at support@fittrackplus.com
                            </p>
                            <p style="color: #999999; font-size: 12px; margin: 0;">
                                © 2026 FitTrack+. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
''';
  }
}
