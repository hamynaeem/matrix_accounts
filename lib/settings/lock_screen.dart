import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix_accounts/core/config/providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  bool _isAuthenticating = false;
  String _errorMessage = '';
  String _biometricCapability = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBiometricCapability();
    _attemptBiometricAuth();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  Future<void> _loadBiometricCapability() async {
    final biometricService = ref.read(biometricServiceProvider);
    final capability =
        await biometricService.getBiometricCapabilityDescription();
    if (mounted) {
      setState(() {
        _biometricCapability = capability;
      });
    }
  }

  Future<void> _attemptBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);

      // Check if biometric authentication is available
      final canCheck = await biometricService.canCheckBiometrics;
      if (!canCheck) {
        setState(() {
          _errorMessage = 'Biometric authentication is not available';
          _isAuthenticating = false;
        });
        return;
      }

      // Attempt authentication
      final isAuthenticated = await biometricService.authenticateUser(
        reason: 'Unlock Matrix Accounts',
      );

      if (isAuthenticated) {
        await biometricService.unlockApp();
        if (mounted) {
          _navigateToApp();
        }
      } else {
        _showAuthFailure();
      }
    } catch (e) {
      _showAuthFailure('Authentication failed: ${e.toString()}');
    }
  }

  void _showAuthFailure([String? message]) {
    if (mounted) {
      setState(() {
        _errorMessage = message ?? 'Authentication failed. Please try again.';
        _isAuthenticating = false;
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  void _navigateToApp() {
    final authService = ref.read(authServiceProvider);

    if (authService.hasSelectedCompany) {
      context.go('/dashboard');
    } else if (authService.isLoggedIn) {
      context.go('/company');
    } else {
      context.go('/login');
    }
  }

  Widget _buildLockIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.fingerprint,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Matrix Accounts',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'App is locked',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildAuthButton() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 4, 0),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _attemptBiometricAuth,
                icon: _isAuthenticating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.fingerprint),
                label: Text(_isAuthenticating ? 'Authenticating...' : 'Unlock'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_biometricCapability.isNotEmpty)
                Text(
                  _biometricCapability,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildLockIcon(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 60),
                _buildAuthButton(),
                const SizedBox(height: 24),
                _buildErrorMessage(),
                const Spacer(),

                // Emergency unlock option (for development)
                if (Theme.of(context).brightness ==
                    Brightness.light) // Only show in debug
                  TextButton(
                    onPressed: () async {
                      final biometricService =
                          ref.read(biometricServiceProvider);
                      await biometricService.unlockApp();
                      _navigateToApp();
                    },
                    child: Text(
                      'Emergency Unlock (Dev Only)',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
