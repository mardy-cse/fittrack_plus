import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Phone Auth Diagnostic Tool
/// Use this to check if everything is configured correctly
class FirebaseDiagnostic {
  
  /// Run all diagnostic checks
  static Future<void> runDiagnostics() async {
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('🔍 FIREBASE PHONE AUTHENTICATION DIAGNOSTICS');
    debugPrint('═══════════════════════════════════════════════════');
    
    await _checkFirebaseInitialization();
    await _checkPhoneAuthProvider();
    await _checkCurrentUser();
    _checkBuildConfiguration();
    
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('✅ Diagnostic check completed');
    debugPrint('═══════════════════════════════════════════════════');
  }
  
  /// Check if Firebase is properly initialized
  static Future<void> _checkFirebaseInitialization() async {
    debugPrint('\n📦 1. Firebase Initialization Check:');
    
    try {
      final app = Firebase.app();
      debugPrint('  ✅ Firebase initialized successfully');
      debugPrint('  📱 App name: ${app.name}');
      debugPrint('  🔑 Project ID: ${app.options.projectId}');
      debugPrint('  📮 App ID: ${app.options.appId}');
      debugPrint('  🔐 API Key: ${app.options.apiKey.substring(0, 10)}...');
    } catch (e) {
      debugPrint('  ❌ Firebase initialization failed: $e');
    }
  }
  
  /// Check Phone Authentication provider status
  static Future<void> _checkPhoneAuthProvider() async {
    debugPrint('\n📞 2. Phone Authentication Provider Check:');
    
    try {
      final auth = FirebaseAuth.instance;
      debugPrint('  ✅ FirebaseAuth instance available');
      debugPrint('  🌐 Auth domain: ${auth.app.options.projectId}.firebaseapp.com');
      
      // Try to get sign-in methods (this will work if properly configured)
      try {
        await auth.fetchSignInMethodsForEmail('test@example.com');
        debugPrint('  ✅ Can communicate with Firebase Auth');
      } catch (e) {
        if (e.toString().contains('network')) {
          debugPrint('  ⚠️  Network issue detected');
        } else {
          debugPrint('  ✅ Firebase Auth is reachable');
        }
      }
      
      // Check language code (important for SMS)
      debugPrint('  🗣️  Language code: ${auth.languageCode ?? "default"}');
      
    } catch (e) {
      debugPrint('  ❌ Phone auth provider check failed: $e');
    }
  }
  
  /// Check current user status
  static Future<void> _checkCurrentUser() async {
    debugPrint('\n👤 3. Current User Check:');
    
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null) {
        debugPrint('  ✅ User is signed in');
        debugPrint('  📱 UID: ${user.uid}');
        debugPrint('  📞 Phone: ${user.phoneNumber ?? "Not set"}');
        debugPrint('  ✉️  Email: ${user.email ?? "Not set"}');
        debugPrint('  🔐 Provider: ${user.providerData.map((p) => p.providerId).join(", ")}');
      } else {
        debugPrint('  ℹ️  No user currently signed in');
      }
    } catch (e) {
      debugPrint('  ❌ User check failed: $e');
    }
  }
  
  /// Check build configuration
  static void _checkBuildConfiguration() {
    debugPrint('\n🔧 4. Build Configuration Check:');
    
    debugPrint('  📱 Platform: ${defaultTargetPlatform.name}');
    debugPrint('  🏗️  Debug mode: ${kDebugMode ? "Yes" : "No"}');
    debugPrint('  🏭 Profile mode: ${kProfileMode ? "Yes" : "No"}');
    debugPrint('  🚀 Release mode: ${kReleaseMode ? "Yes" : "No"}');
  }
  
  /// Test phone number formatting
  static String testPhoneNumberFormat(String phoneNumber) {
    debugPrint('\n📞 Testing phone number format:');
    debugPrint('  Input: $phoneNumber');
    
    // Add country code if not present
    final formatted = phoneNumber.startsWith('+')
        ? phoneNumber
        : '+88$phoneNumber'; // Bangladesh
    
    debugPrint('  Formatted: $formatted');
    debugPrint('  Length: ${formatted.length}');
    debugPrint('  Valid format: ${formatted.startsWith("+88") && formatted.length == 14 ? "✅" : "❌"}');
    
    return formatted;
  }
  
  /// Manual OTP send test with detailed logging
  static Future<void> testSendOTP(String phoneNumber) async {
    debugPrint('\n🧪 TESTING OTP SEND:');
    debugPrint('═══════════════════════════════════════════════════');
    
    final formatted = testPhoneNumberFormat(phoneNumber);
    
    try {
      final auth = FirebaseAuth.instance;
      
      debugPrint('\n⏳ Initiating verifyPhoneNumber...');
      
      await auth.verifyPhoneNumber(
        phoneNumber: formatted,
        timeout: const Duration(seconds: 120),
        
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ AUTO-VERIFICATION COMPLETED!');
          debugPrint('   Credential: ${credential.signInMethod}');
          try {
            final result = await auth.signInWithCredential(credential);
            debugPrint('✅ Auto sign-in successful!');
            debugPrint('   User: ${result.user?.uid}');
          } catch (e) {
            debugPrint('❌ Auto sign-in failed: $e');
          }
        },
        
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ VERIFICATION FAILED!');
          debugPrint('   Error code: ${e.code}');
          debugPrint('   Error message: ${e.message}');
          debugPrint('   Full error: ${e.toString()}');
          
          // Specific error guidance
          switch (e.code) {
            case 'invalid-phone-number':
              debugPrint('   💡 Fix: Check phone number format');
              break;
            case 'quota-exceeded':
              debugPrint('   💡 Fix: Wait 24 hours or upgrade Firebase plan');
              break;
            case 'app-not-authorized':
              debugPrint('   💡 Fix: Add SHA keys to Firebase console');
              debugPrint('   💡 Fix: Enable Play Integrity API');
              break;
            case 'network-request-failed':
              debugPrint('   💡 Fix: Check internet connection');
              break;
            default:
              debugPrint('   💡 Check: PHONE_AUTH_TROUBLESHOOTING.md');
          }
        },
        
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ CODE SENT SUCCESSFULLY!');
          debugPrint('   Verification ID: $verificationId');
          debugPrint('   Resend token: ${resendToken ?? "null"}');
          debugPrint('   ✅ SMS should arrive within 1-2 minutes');
        },
        
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️  Auto-retrieval timeout');
          debugPrint('   Verification ID: $verificationId');
          debugPrint('   ℹ️  Normal behavior - waiting for manual code entry');
        },
      );
      
    } catch (e) {
      debugPrint('❌ EXCEPTION DURING VERIFICATION:');
      debugPrint('   ${e.toString()}');
    }
    
    debugPrint('═══════════════════════════════════════════════════');
  }
  
  /// Print all necessary configuration steps
  static void printSetupGuide() {
    debugPrint('\n📚 PHONE AUTH SETUP CHECKLIST:');
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('1. ☐ Firebase Console:');
    debugPrint('   - Authentication → Sign-in method → Phone (Enabled)');
    debugPrint('   - Remove any test phone numbers');
    debugPrint('   - Project Settings → Add SHA-1 and SHA-256');
    debugPrint('   - Download updated google-services.json');
    debugPrint('');
    debugPrint('2. ☐ Google Cloud Console:');
    debugPrint('   - Enable "Android Device Verification API"');
    debugPrint('   - Enable "Play Integrity API"');
    debugPrint('   - Enable "Identity Toolkit API"');
    debugPrint('');
    debugPrint('3. ☐ Local Setup:');
    debugPrint('   - Place google-services.json in android/app/');
    debugPrint('   - Run: flutter clean');
    debugPrint('   - Run: flutter pub get');
    debugPrint('   - Rebuild: flutter run');
    debugPrint('');
    debugPrint('4. ☐ Testing:');
    debugPrint('   - Use real Android device (not emulator)');
    debugPrint('   - Ensure internet connection');
    debugPrint('   - Phone format: +880XXXXXXXXXX');
    debugPrint('═══════════════════════════════════════════════════');
  }
}
