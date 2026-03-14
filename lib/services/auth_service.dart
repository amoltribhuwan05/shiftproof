import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shiftproof/data/api_client.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthException implements Exception {
  const AuthException({required this.code, required this.message});

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'Please enter a valid email address.',
      'user-not-found' => 'No account found for this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' => 'Invalid email or password.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Password is too weak.',
      'network-request-failed' =>
        'Network error. Please check your connection.',
      'popup-closed-by-user' => 'Sign-in was cancelled.',
      'user-disabled' => 'This account has been disabled.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };

    return AuthException(code: e.code, message: message);
  }
  final String code;
  final String message;

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

class AuthService {
  AuthService({
    ApiClient? apiClient,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _apiClient = apiClient ?? ApiClient.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '307341408241-vq8ahom2eqa196hoc435s3o8rbqq9vhh.apps.googleusercontent.com',
  );

  final ApiClient _apiClient;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitFuture;

  Future<void> _ensureGoogleInitialized() {
    return _googleInitFuture ??= _googleSignIn.initialize(
      serverClientId: _googleServerClientId,
    );
  }

  AuthException _mapGoogleSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => const AuthException(
        code: 'popup-closed-by-user',
        message: 'Sign-in was cancelled.',
      ),
      GoogleSignInExceptionCode.clientConfigurationError => const AuthException(
        code: 'google-client-config-error',
        message:
            'Google Sign-In is not configured correctly for this app build.',
      ),
      GoogleSignInExceptionCode.providerConfigurationError =>
        const AuthException(
          code: 'google-provider-config-error',
          message: 'Google Play Services are unavailable or misconfigured.',
        ),
      GoogleSignInExceptionCode.uiUnavailable => const AuthException(
        code: 'google-ui-unavailable',
        message: 'Google Sign-In UI is unavailable right now. Please retry.',
      ),
      GoogleSignInExceptionCode.interrupted => const AuthException(
        code: 'google-sign-in-interrupted',
        message: 'Google Sign-In was interrupted. Please retry.',
      ),
      _ => AuthException(
        code: e.code.name,
        message: e.description ?? 'Google sign-in failed. Please try again.',
      ),
    };
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final credential = await _firebaseAuth.signInWithPopup(provider);
        return credential.user;
      }

      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          code: 'missing-id-token',
          message: 'Google sign-in did not return a valid identity token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } on GoogleSignInException catch (e) {
      throw _mapGoogleSignInException(e);
    } on Exception catch (_) {
      throw const AuthException(
        code: 'google-sign-in-failed',
        message: 'Google sign-in failed. Please try again.',
      );
    }
  }

  Future<User?> signInWithApple() async {
    try {
      if (kIsWeb) {
        final provider = OAuthProvider('apple.com')
          ..addScope('email')
          ..addScope('name');
        final credential = await _firebaseAuth.signInWithPopup(provider);
        return credential.user;
      }

      if (defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.macOS) {
        throw const AuthException(
          code: 'unsupported-platform',
          message: 'Apple sign-in is only available on iOS and macOS.',
        );
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        throw const AuthException(
          code: 'apple-token-missing',
          message: 'Apple sign-in did not return a valid identity token.',
        );
      }

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException(
          code: 'popup-closed-by-user',
          message: 'Sign-in was cancelled.',
        );
      }
      throw AuthException(code: e.code.name, message: e.message);
    } on AuthException {
      rethrow;
    } on Exception catch (_) {
      throw const AuthException(
        code: 'apple-sign-in-failed',
        message: 'Apple sign-in failed. Please try again.',
      );
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (name.isNotEmpty) {
        await userCredential.user?.updateDisplayName(name);
        await userCredential.user?.reload();
      }
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } on Exception catch (_) {
      // Ignore provider-specific sign-out failures and continue.
    }
    await _firebaseAuth.signOut();
    try {
      await logout();
    } on Exception catch (_) {
      // Backend logout is best-effort if there is no active API session yet.
    }
  }

  Future<void> registerDeviceToken(String token) async {
    await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/auth/device-token',
      data: {'token': token},
    );
  }

  Future<void> logout() async {
    await _apiClient.dio.post<Map<String, dynamic>>('/api/v1/auth/logout');
  }

  Future<AppUser> getMe() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/auth/me',
    );
    return AppUser.fromJson(response.data!);
  }

  Future<CurrentStay?> getCurrentStay() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/auth/me/current-stay',
    );
    if (response.statusCode == 204 || response.data == null) {
      return null;
    }
    return CurrentStay.fromJson(response.data!);
  }
}
