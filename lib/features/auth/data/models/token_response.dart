class TokenResponse {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final String scope;
  final String tokenType;

  const TokenResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.scope,
    required this.tokenType,
  });

  /// Parse from the initial token endpoint (camelCase keys).
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] as String,
      expiresIn: json['expiresIn'] as int,
      refreshToken: json['refreshToken'] as String,
      scope: json['scope'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  /// Parse from the OAuth2 refresh endpoint (snake_case keys).
  factory TokenResponse.fromRefreshJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      refreshToken: json['refresh_token'] as String,
      scope: json['scope'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }
}
