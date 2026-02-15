import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

enum UserRole { renter, owner }

class AuthProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  bool _requiresRoleSelection = false;
  String? _currentUserId;
  UserRole? _role;

  bool get isInitializing => _isInitializing;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  bool get requiresRoleSelection => _requiresRoleSelection;
  String? get currentUserId => _currentUserId;
  UserRole? get role => _role;

  Future<void> initialize() async {
    final prefs = StorageService.instance.prefs;
    _hasSeenOnboarding = prefs.getBool(StorageService.onboardingKey) ?? false;
    _isLoggedIn = prefs.getBool(StorageService.loginStateKey) ?? false;
    _currentUserId = prefs.getString(StorageService.currentUserKey);
    final roleRaw = prefs.getString(StorageService.roleKey);
    if (roleRaw != null) {
      _role = roleRaw == 'owner' ? UserRole.owner : UserRole.renter;
    }
    _requiresRoleSelection = _isLoggedIn && _role == null;

    await Future<void>.delayed(const Duration(milliseconds: 900));
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    await StorageService.instance.prefs
        .setBool(StorageService.onboardingKey, true);
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _currentUserId = email.trim().toLowerCase();
    _isLoggedIn = true;

    final roleRaw = StorageService.instance.prefs.getString(_roleKeyFor(email));
    if (roleRaw == null) {
      _role = null;
      _requiresRoleSelection = true;
    } else {
      _role = roleRaw == 'owner' ? UserRole.owner : UserRole.renter;
      _requiresRoleSelection = false;
      await StorageService.instance.prefs.setString(StorageService.roleKey, roleRaw);
    }

    await StorageService.instance.prefs
        .setBool(StorageService.loginStateKey, true);
    await StorageService.instance.prefs
        .setString(StorageService.currentUserKey, _currentUserId!);

    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _currentUserId = email.trim().toLowerCase();
    _isLoggedIn = true;
    _role = null;
    _requiresRoleSelection = true;

    await StorageService.instance.prefs
        .setBool(StorageService.loginStateKey, true);
    await StorageService.instance.prefs
        .setString(StorageService.currentUserKey, _currentUserId!);

    notifyListeners();
  }

  Future<void> setRole(UserRole role) async {
    if (_currentUserId == null) return;

    _role = role;
    _requiresRoleSelection = false;
    final value = role == UserRole.owner ? 'owner' : 'renter';

    await StorageService.instance.prefs
        .setString(_roleKeyFor(_currentUserId!), value);
    await StorageService.instance.prefs.setString(StorageService.roleKey, value);

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _requiresRoleSelection = false;
    _currentUserId = null;
    _role = null;

    await StorageService.instance.prefs
        .setBool(StorageService.loginStateKey, false);
    await StorageService.instance.prefs.remove(StorageService.currentUserKey);
    await StorageService.instance.prefs.remove(StorageService.roleKey);

    notifyListeners();
  }

  String _roleKeyFor(String email) => 'user_role_${email.trim().toLowerCase()}';
}
