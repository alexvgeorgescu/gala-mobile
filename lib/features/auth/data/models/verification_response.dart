class VerificationResponse {
  final String challengeToken;
  final int codeLength;
  final int expiresIn;
  final int userStatus;

  const VerificationResponse({
    required this.challengeToken,
    required this.codeLength,
    required this.expiresIn,
    required this.userStatus,
  });

  bool get isRegistered => userStatus == 1;

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      challengeToken: json['challengeToken'] as String,
      codeLength: json['codeLength'] as int,
      expiresIn: json['expiresIn'] as int,
      userStatus: json['userStatus'] as int,
    );
  }
}
