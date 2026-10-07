import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/supabase/supabase_service.dart';

enum SignUpOutcome {
  /// Account created (or still unconfirmed): a code was emailed.
  otpSent,

  /// Email confirmation is disabled on the project and a session exists.
  signedIn,
}

abstract class IAuthRepository {
  Session? get currentSession;

  Stream<AuthState> get authStateChanges;

  Future<SignUpOutcome> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Session> verifySignUpOtp({
    required String email,
    required String token,
  });

  Future<void> resendSignUpOtp(String email);

  Future<Session> signIn({required String email, required String password});

  Future<void> signOut();
}

class AuthRepository implements IAuthRepository {
  final SupabaseService _supabase;

  AuthRepository(this._supabase);

  GoTrueClient get _auth => _supabase.auth;

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
        email: email.trim().toLowerCase(),
        password: password,
        data: {'full_name': fullName.trim()},
      ),
      (dynamic data) {
        final res = data as AuthResponse;
        if (res.session != null) return SignUpOutcome.signedIn;
        // With email confirmation on, an already-confirmed email returns an
        // obfuscated user with no identities instead of an error.
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
  Future<Session> verifySignUpOtp({
    required String email,
    required String token,
  }) {
    return _supabase.handleRequest(
      () => _auth.verifyOTP(
        email: email.trim().toLowerCase(),
        token: token.trim(),
        type: OtpType.signup,
      ),
      (dynamic data) => _requireSession(data as AuthResponse),
      'Verify sign-up OTP',
    );
  }

  @override
  Future<void> resendSignUpOtp(String email) {
    return _supabase.handleRequest(
      () => _auth.resend(type: OtpType.signup, email: email.trim().toLowerCase()),
      (_) {},
      'Resend sign-up OTP',
    );
  }

  @override
  Future<Session> signIn({required String email, required String password}) {
    return _supabase.handleRequest(
      () => _auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      ),
      (dynamic data) => _requireSession(data as AuthResponse),
      'Sign in',
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
