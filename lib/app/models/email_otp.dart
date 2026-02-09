class EmailOTP {
  final String email;
  final String otp;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isVerified;

  EmailOTP({
    required this.email,
    required this.otp,
    required this.createdAt,
    required this.expiresAt,
    this.isVerified = false,
  });

  // Check if OTP has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'otp': otp,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  // Create from Firestore Map
  factory EmailOTP.fromMap(Map<String, dynamic> map) {
    return EmailOTP(
      email: map['email'] as String,
      otp: map['otp'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }
}
