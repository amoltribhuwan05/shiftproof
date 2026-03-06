import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  // Stream listening to auth state changes
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  auth.User? get currentUser => _firebaseAuth.currentUser;

  // Sign In with Email & Password
  Future<auth.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(e.code, _handleAuthError(e.code));
    }
  }

  // Sign Up with Email & Password
  Future<auth.User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name
      await credential.user?.updateDisplayName(name);
      return credential.user;
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(e.code, _handleAuthError(e.code));
    }
  }

  // Sign In with Google
  Future<auth.User?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken, // idToken used as accessToken workaround if needed, or check tokens
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled || e.code == GoogleSignInExceptionCode.interrupted) {
         return null;
      }
      throw AuthException(e.code.name, _handleAuthError(e.code.name));
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(e.code, _handleAuthError(e.code));
    } catch (e) {
      throw AuthException(
        'google-signin-error',
        'An unexpected error occurred during Google Sign-In.',
      );
    }
  }

  // Sign In with Apple
  Future<auth.User?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      final auth.OAuthProvider authProvider = auth.OAuthProvider('apple.com');
      final auth.AuthCredential credential = authProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final name =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (name.isNotEmpty) {
          await userCredential.user?.updateDisplayName(name);
        }
      }

      return userCredential.user;
    } on auth.FirebaseAuthException catch (e) {
      throw AuthException(e.code, _handleAuthError(e.code));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      throw AuthException(
        'apple-signin-error',
        'Apple Sign-In authorization failed.',
      );
    } catch (e) {
      throw AuthException(
        'apple-signin-error',
        'An unexpected error occurred during Apple Sign-In.',
      );
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore if not initialized
    }
  }

  // Simple Error Mapper
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);

  @override
  String toString() => message;
}
