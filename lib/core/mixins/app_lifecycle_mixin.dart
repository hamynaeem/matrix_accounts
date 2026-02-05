import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/providers.dart';
import '../services/biometric_service.dart';
import '../utils/debug_utils.dart';

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

    DebugUtils.logLifecycleEvent('App lifecycle changed to: ${state.name}');

    final biometricService = ref.read(biometricServiceProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        DebugUtils.logLifecycleEvent('App resumed, handling biometric check');
        _handleAppResumed(biometricService);
        break;
      case AppLifecycleState.paused:
        DebugUtils.logLifecycleEvent('App paused, updating last active time');
        _handleAppPaused(biometricService);
        break;
      case AppLifecycleState.inactive:
        DebugUtils.logLifecycleEvent('App inactive (transitioning)');
        break;
      case AppLifecycleState.detached:
        DebugUtils.logLifecycleEvent('App detached (rare state)');
        break;
      case AppLifecycleState.hidden:
        DebugUtils.logLifecycleEvent('App hidden (iOS specific)');
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
      DebugUtils.logLifecycleEvent('Skipping auto-lock check',
          context: 'Not from background or biometric disabled');
      return;
    }

    _wasInBackground = false;

    // Check if app should auto-lock
    if (biometricService.shouldAutoLock()) {
      DebugUtils.logLifecycleEvent(
          'Auto-lock triggered, navigating to lock screen');
      await biometricService.lockApp();

      // Navigate to lock screen with safety checks
      if (mounted) {
        try {
          final currentLocation =
              GoRouter.of(context).routeInformationProvider.value.location;
          DebugUtils.logNavigationEvent('Current location check',
              route: currentLocation);

          if (currentLocation != '/lock') {
            if (context.canPop()) {
              // If we can pop, we're not at the root, so push lock screen
              DebugUtils.logNavigationEvent('Pushing lock screen (non-root)');
              context.push('/lock');
            } else {
              // We're at root level, replace with lock screen
              DebugUtils.logNavigationEvent('Navigating to lock screen (root)');
              context.go('/lock');
            }
          } else {
            DebugUtils.logNavigationEvent(
                'Already on lock screen, skipping navigation');
          }
        } catch (e) {
          // If navigation fails, try a safer approach
          DebugUtils.logError('Navigation error in app resume',
              error: e, tag: 'Navigation');
          try {
            context.go('/lock');
            DebugUtils.logNavigationEvent('Fallback navigation successful');
          } catch (e2) {
            DebugUtils.logError('Fallback navigation also failed',
                error: e2, tag: 'Navigation');
          }
        }
      } else {
        DebugUtils.logWarning('Widget not mounted, skipping navigation',
            tag: 'Navigation');
      }
    } else {
      DebugUtils.logLifecycleEvent('Auto-lock not required');
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
