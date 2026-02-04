import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/providers.dart';
import '../services/biometric_service.dart';

/// Mixin to handle app lifecycle events and automatic locking
mixin AppLifecycleMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final biometricService = ref.read(biometricServiceProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed(biometricService);
        break;
      case AppLifecycleState.paused:
        _handleAppPaused(biometricService);
        break;
      case AppLifecycleState.inactive:
        // App is transitioning between foreground and background
        break;
      case AppLifecycleState.detached:
        // App is detached (rare state)
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS specific)
        break;
    }
  }

  Future<void> _handleAppPaused(BiometricService biometricService) async {
    _wasInBackground = true;
    if (biometricService.isBiometricEnabled) {
      await biometricService.updateLastActiveTime();
    }
  }

  Future<void> _handleAppResumed(BiometricService biometricService) async {
    if (!_wasInBackground || !biometricService.isBiometricEnabled) {
      return;
    }

    _wasInBackground = false;

    // Check if app should auto-lock
    if (biometricService.shouldAutoLock()) {
      await biometricService.lockApp();

      // Navigate to lock screen
      if (mounted && context.canPop()) {
        // If we can pop, we're not at the root, so push lock screen
        context.push('/lock');
      } else {
        // We're at root level, replace with lock screen
        context.go('/lock');
      }
    }
  }
}

/// Provider for app lock state
final appLockStateProvider =
    StateNotifierProvider<AppLockStateNotifier, AppLockState>((ref) {
  return AppLockStateNotifier(ref);
});

enum AppLockState {
  unlocked,
  locked,
  checking,
}

class AppLockStateNotifier extends StateNotifier<AppLockState> {
  final Ref _ref;

  AppLockStateNotifier(this._ref) : super(AppLockState.unlocked) {
    _checkInitialLockState();
  }

  Future<void> _checkInitialLockState() async {
    state = AppLockState.checking;

    final biometricService = _ref.read(biometricServiceProvider);

    if (biometricService.isAppLocked ||
        (biometricService.isBiometricEnabled &&
            biometricService.shouldAutoLock())) {
      state = AppLockState.locked;
    } else {
      state = AppLockState.unlocked;
    }
  }

  Future<void> lockApp() async {
    final biometricService = _ref.read(biometricServiceProvider);
    await biometricService.lockApp();
    state = AppLockState.locked;
  }

  Future<void> unlockApp() async {
    final biometricService = _ref.read(biometricServiceProvider);
    await biometricService.unlockApp();
    state = AppLockState.unlocked;
  }

  Future<bool> authenticateAndUnlock() async {
    final biometricService = _ref.read(biometricServiceProvider);

    final isAuthenticated = await biometricService.authenticateUser(
      reason: 'Unlock Matrix Accounts',
    );

    if (isAuthenticated) {
      await unlockApp();
      return true;
    }

    return false;
  }
}
