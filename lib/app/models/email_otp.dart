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

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'otp': otp,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
    };
  }

  // Create from Firestore map
  factory EmailOTP.fromMap(Map<String, dynamic> map) {
    return EmailOTP(
      email: map['email'] ?? '',
      otp: map['otp'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] ?? 0),
      isVerified: map['isVerified'] ?? false,
    );
  }

  // Check if OTP is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Create copy with updated fields
  EmailOTP copyWith({
    String? email,
    String? otp,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isVerified,
  }) {
    return EmailOTP(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
