/// The ONE place the screens talk to for sign-up / login / OTP.
///
/// Right now [AuthService.instance] is a [MockAuthService], so the whole flow
/// works without any backend. When Firebase is ready we write a
/// `FirebaseAuthService` that implements this same interface and change ONE
/// line below. The screens won't need to change.
abstract class AuthService {
  static AuthService instance = MockAuthService();

  /// True if an account with this phone already exists.
  Future<bool> phoneExists(String phone);

  /// Creates the account. The user is NOT logged in by this.
  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  });

  /// Step 1 of login: checks phone + password. Returns false if wrong.
  Future<bool> checkCredentials({
    required String phone,
    required String password,
  });

  /// Step 2 of login: "sends" a one-time code to [phone].
  Future<void> sendOtp(String phone);

  /// Step 2 of login: returns true if [code] is correct. When it is, the
  /// user becomes logged in.
  Future<bool> verifyOtp(String code);

  /// Name of the logged-in user (null when nobody is logged in).
  String? get currentUserName;

  void signOut();
}

/// Fake backend for development. Keeps users in memory only, so they are
/// lost when the app restarts. That is why one demo account is pre-created.
///
///   Demo account:  phone 0500000000   password 12345678
///   Correct OTP:   always [testCode]
class MockAuthService implements AuthService {
  static const testCode = '123456';
  static const demoPhone = '0500000000';
  static const demoPassword = '12345678';

  // phone (+966...) -> {name, password}
  final Map<String, Map<String, String>> _users = {
    '+966500000000': {'name': 'مستخدم تجريبي', 'password': demoPassword},
  };

  String? _pendingPhone; // passed credentials, waiting for the OTP
  String? _loggedInPhone;

  @override
  Future<bool> phoneExists(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.containsKey(phone);
  }

  @override
  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _users[phone] = {'name': name, 'password': password};
  }

  @override
  Future<bool> checkCredentials({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = _users[phone]?['password'] == password;
    _pendingPhone = ok ? phone : null;
    return ok;
  }

  @override
  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // The code only counts if the password step was passed first.
    if (_pendingPhone == null || code != testCode) return false;
    _loggedInPhone = _pendingPhone;
    _pendingPhone = null;
    return true;
  }

  @override
  String? get currentUserName => _users[_loggedInPhone]?['name'];

  @override
  void signOut() {
    _loggedInPhone = null;
    _pendingPhone = null;
  }
}
