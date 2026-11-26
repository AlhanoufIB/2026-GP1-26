import 'package:firebase_auth/firebase_auth.dart';

import '../dataconnect_generated/generated.dart';
import 'auth_service.dart';

/// Real backend: Firebase Authentication (login) + SQL Connect (users table).
/// Implements the same [AuthService] interface as [MockAuthService], so the
/// screens work the same way.
///
/// The user only types phone + password. Firebase Auth uses
/// 966XXXXXXXXX@mullak.app behind the scenes as the account ID; it is never
/// shown in the app.
///
/// OTP is interface-only this phase: no SMS is sent and any 6-digit code is
/// accepted once phone + password were correct.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MullakConnector _db = MullakConnector.instance;

  /// True after phone + password were correct, until the OTP screen is passed.
  bool _passedPassword = false;

  /// Accepts 05XXXXXXXX / 5XXXXXXXX / 9665XXXXXXXX / +9665XXXXXXXX
  /// and returns +9665XXXXXXXX (the form stored in the database).
  String _normalize(String input) {
    var p = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('00966')) p = p.substring(5);
    if (p.startsWith('966')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return '+966$p';
  }

  /// +966501234567  ->  966501234567@mullak.app
  String _loginId(String phone) =>
      '${_normalize(phone).substring(1)}@mullak.app';

  @override
  Future<bool> phoneExists(String phone) async {
    // Checked inside signUp instead: Firebase refuses a second account with
    // the same login ID and we turn that into "رقم الجوال مسجل مسبقاً".
    return false;
  }

  @override
  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    // 1) Create the login account (Firebase signs the user in automatically).
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _loginId(phone),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_arabicMessage(e.code));
    }

    // 2) Save the user in the "users" table.
    try {
      await _db
          .upsertUser(
            fullName: name.trim(),
            phoneNumber: _normalize(phone),
            // One account can search for property AND list property
            // (overlapping specialization), so both roles are on.
            bOwnerFlag: true,
            pOwnerFlag: true,
          )
          .execute();
    } catch (_) {
      // Database save failed: remove the half-created login account so the
      // same phone number can be used again.
      await _auth.currentUser?.delete();
      throw AuthException('تعذّر إنشاء الحساب، حاول مرة أخرى');
    }

    // 3) Sign-up does NOT log the user in (they go to the login page).
    await _auth.signOut();
  }

  @override
  Future<bool> checkCredentials({
    required String phone,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _loginId(phone),
        password: password,
      );
      _passedPassword = true;
      return true;
    } on FirebaseAuthException catch (e) {
      _passedPassword = false;
      const wrongLogin = [
        'invalid-credential',
        'wrong-password',
        'user-not-found',
        'invalid-email',
      ];
      if (wrongLogin.contains(e.code)) return false;
      throw AuthException(_arabicMessage(e.code)); // network, too many tries…
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    // Interface only this phase: nothing is sent.
  }

  @override
  Future<bool> verifyOtp(String code) async {
    // Interface only this phase: the default code 123456 (shown as a note
    // on the OTP screen) is accepted once phone + password were correct.
    final ok = _passedPassword &&
        _auth.currentUser != null &&
        code == MockAuthService.testCode;
    if (ok) _passedPassword = false; // a wrong code can be retried
    return ok;
  }

  @override
  String? get currentUserName => _auth.currentUser?.displayName;

  @override
  void signOut() {
    _passedPassword = false;
    _auth.signOut();
  }

  String _arabicMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'هذا الرقم مسجّل مسبقاً، سجّل الدخول بدلاً من ذلك';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      case 'operation-not-allowed':
        return 'تسجيل الدخول غير مفعّل في Firebase';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }
}
