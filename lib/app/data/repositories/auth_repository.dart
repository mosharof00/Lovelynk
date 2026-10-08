import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/supabase/supabase_service.dart';

enum SignUpOutcome {
  /// Account created (or still unconfirmed): a code was emailed.
  otpSent,

  /// Email confirmation is disabled on the project and a session exists.
  signedIn,
}

/// Which email code the Verify OTP screen is handling.
enum OtpPurpose {
  /// "Confirm signup" template.
  signup,

  /// "Reset password" template.
  recovery,
}

abstract class IAuthRepository {
  Session? get currentSession;

  Stream<AuthState> get authStateChanges;

  Future<SignUpOutcome> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Session> signIn({required String email, required String password});

  /// Verifies a sign-up or recovery code. Both return a signed-in session.
  Future<Session> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  });

  Future<void> resendOtp({required String email, required OtpPurpose purpose});

  /// Emails a recovery code. Succeeds even if the email isn't registered,
  /// so the app never reveals which emails have accounts.
  Future<void> sendPasswordResetOtp(String email);

  /// Requires the session from a verified recovery code.
  Future<void> updatePassword(String newPassword);

  Future<void> signOut();
}

class AuthRepository implements IAuthRepository {
  final SupabaseService _supabase;

  AuthRepository(this._supabase);

  GoTrueClient get _auth => _supabase.auth;

  String _normalise(String email) => email.trim().toLowerCase();

  @override
  Session? get currentSession => _auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  @override
  Future<SignUpOutcome> signUp({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _supabase.handleRequest(
      () => _auth.signUp(
        email: _normalise(email),
        password: password,
        data: {'full_name': fullName.trim()},
      ),
      (dynamic data) {
        final res = data as AuthResponse;
        if (res.session != null) return SignUpOutcome.signedIn;
        // With email confirmation on, an already-confirmed email returns an
        // obfuscated user with no identities instead of an error.
        // An unconfirmed email returns the user and re-sends the code.
        if (res.user?.identities?.isEmpty ?? false) {
          throw ApiException(
            'An account with this email already exists. Please sign in.',
            code: ApiErrorCode.accountExists,
          );
        }
        return SignUpOutcome.otpSent;
      },
      'Sign up',
    );
  }

  @override
  Future<Session> signIn({required String email, required String password}) {
    return _supabase.handleRequest(
      () => _auth.signInWithPassword(
        email: _normalise(email),
        password: password,
      ),
      (dynamic data) => _requireSession(data as AuthResponse),
      'Sign in',
    );
  }

  @override
  Future<Session> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  }) {
    return _supabase.handleRequest(
      () => _auth.verifyOTP(
        email: _normalise(email),
        token: token.trim(),
        type: switch (purpose) {
          OtpPurpose.signup => OtpType.signup,
          OtpPurpose.recovery => OtpType.recovery,
        },
      ),
      (dynamic data) => _requireSession(data as AuthResponse),
      'Verify ${purpose.name} OTP',
    );
  }

  @override
  Future<void> resendOtp({
    required String email,
    required OtpPurpose purpose,
  }) {
    switch (purpose) {
      case OtpPurpose.signup:
        return _supabase.handleRequest(
          () => _auth.resend(type: OtpType.signup, email: _normalise(email)),
          (_) {},
          'Resend signup OTP',
        );
      case OtpPurpose.recovery:
        return sendPasswordResetOtp(email);
    }
  }

  @override
  Future<void> sendPasswordResetOtp(String email) {
    return _supabase.handleRequest(
      () => _auth.resetPasswordForEmail(_normalise(email)),
      (_) {},
      'Send password reset OTP',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return _supabase.handleRequest(
      () => _auth.updateUser(UserAttributes(password: newPassword)),
      (_) {},
      'Update password',
    );
  }

  @override
  Future<void> signOut() {
    return _supabase.handleRequest(
      () => _auth.signOut(scope: SignOutScope.local),
      (_) {},
      'Sign out',
    );
  }

  Session _requireSession(AuthResponse res) {
    final session = res.session;
    if (session == null) {
      throw ApiException('Could not start a session. Please try again.');
    }
    return session;
  }
}
