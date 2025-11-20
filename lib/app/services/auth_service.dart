import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../models/user_profile.dart';
import '../models/email_otp.dart';
import 'user_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = Get.find<UserService>();

  // Phone verification ID
  String? _verificationId;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize service
  Future<AuthService> init() async {
    return this;
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        final profile = UserProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        await _userService.createUserProfile(profile);

        // Update display name
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Delete user profile from Firestore
        await _userService.deleteUserProfile(uid);
        // Delete auth account
        await _auth.currentUser?.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Reauthenticate user
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user?.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to reauthenticate: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Failed to reload user: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create user profile if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final profile = UserProfile(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'User',
          email: userCredential.user!.email ?? '',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await _userService.createUserProfile(profile);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Phone Authentication - Send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    required Function() codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign in on Android
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          codeAutoRetrievalTimeout();
        },
      );
    } catch (e) {
      throw Exception('Failed to verify phone number: $e');
    }
  }

  // Verify OTP and Sign In
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
    String? name,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create user profile if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final profile = UserProfile(
          uid: userCredential.user!.uid,
          name: name ?? 'User',
          email: userCredential.user!.email ?? '',
          createdAt: DateTime.now(),
        );
        await _userService.createUserProfile(profile);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Email OTP - Generate and send OTP
  Future<void> sendEmailOTP(String email) async {
    try {
      // Generate 6-digit OTP
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();

      // Create OTP record
      final emailOTP = EmailOTP(
        email: email,
        otp: otp,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      // Save to Firestore
      await _firestore
          .collection('email_otps')
          .doc(email)
          .set(emailOTP.toMap());

      // TODO: Send email via Cloud Functions or third-party service
      // For development, print OTP to console
      print('📧 Email OTP for $email: $otp');
      print('⏰ Expires at: ${emailOTP.expiresAt}');

      // In production, you would call a Cloud Function like:
      // await FirebaseFunctions.instance
      //     .httpsCallable('sendEmailOTP')
      //     .call({'email': email, 'otp': otp});
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Email OTP - Verify OTP
  Future<bool> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      // Get OTP record from Firestore
      final doc = await _firestore.collection('email_otps').doc(email).get();

      if (!doc.exists) {
        throw Exception('No OTP found for this email');
      }

      final emailOTP = EmailOTP.fromMap(doc.data()!);

      // Check if already verified
      if (emailOTP.isVerified) {
        throw Exception('OTP already used');
      }

      // Check if expired
      if (emailOTP.isExpired) {
        throw Exception('OTP has expired. Please request a new one');
      }

      // Verify OTP
      if (emailOTP.otp != otp) {
        throw Exception('Invalid OTP');
      }

      // Mark as verified
      await _firestore.collection('email_otps').doc(email).update({
        'isVerified': true,
      });

      return true;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Email OTP - Sign up with email OTP verification
  Future<void> signUpWithEmailOTP({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if email already exists
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        throw Exception('This email is already registered');
      }

      // Send OTP
      await sendEmailOTP(email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  // Email OTP - Complete signup after OTP verification
  Future<UserCredential> completeEmailSignup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        final profile = UserProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );
        await _userService.createUserProfile(profile);

        // Update display name
        await credential.user!.updateDisplayName(name);

        // Delete OTP record
        await _firestore.collection('email_otps').doc(email).delete();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to complete signup: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
