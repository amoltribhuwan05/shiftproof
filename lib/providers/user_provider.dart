import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/services/auth_service.dart';

part 'user_provider.g.dart';

enum UserContext { tenant, owner }

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<AppUser?> build() async {
    try {
      // Wait for Firebase to restore the auth session before hitting the API.
      final firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
      if (firebaseUser == null) return null;

      final user = await AuthService.instance.getMe();
      // Default to OWNER if ONLY owner, otherwise TENANT
      if (user.isOwner && !user.isTenant) {
        _currentContext = UserContext.owner;
      } else {
        _currentContext = UserContext.tenant;
      }
      return user;
    } on Exception catch (e, st) {
      debugPrint('Error in UserNotifier: $e\n$st');
      return null;
    }
  }

  UserContext _currentContext = UserContext.tenant;
  UserContext get currentContext => _currentContext;

  void setContext(UserContext context) {
    final user = state.valueOrNull;
    if (user == null) return;
    if (context == UserContext.owner && !user.isOwner) return;
    if (context == UserContext.tenant && !user.isTenant) return;
    _currentContext = context;
    ref.notifyListeners();
  }

  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => AuthService.instance.getMe());
    // Re-apply context logic after refresh to keep context consistent with roles
    final user = state.valueOrNull;
    if (user == null) return;
    if (_currentContext == UserContext.owner && !user.isOwner) {
      _currentContext = UserContext.tenant;
    } else if (_currentContext == UserContext.tenant && !user.isTenant && user.isOwner) {
      _currentContext = UserContext.owner;
    }
  }

  void clearUser() {
    state = const AsyncData(null);
  }

  bool get isOwnerContext => _currentContext == UserContext.owner;
  bool get isTenantContext => _currentContext == UserContext.tenant;
  
  bool get profileCompleted => state.valueOrNull?.profileCompleted ?? false;
  bool get isAuthenticated => state.valueOrNull != null;
}
