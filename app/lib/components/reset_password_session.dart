class ResetPasswordSession {
  // Private constructor
  ResetPasswordSession._privateConstructor();

  // Single instance of the cache
  static final ResetPasswordSession _instance = ResetPasswordSession._privateConstructor();

  // Factory constructor to return the same instance
  factory ResetPasswordSession() {
    return _instance;
  }

  // Data to store in the cache
  String? _email;
  String? _otpToken;

  // Getter for email
  String? get email => _email;

  // Setter for email
  set email(String? value) {
    _email = value;
  }

  // Getter for OTP token
  String? get otpToken => _otpToken;

  // Setter for OTP token
  set otpToken(String? value) {
    _otpToken = value;
  }

  // Method to clear the cache
  void clearCache() {
    _email = null;
    _otpToken = null;
  }
}
