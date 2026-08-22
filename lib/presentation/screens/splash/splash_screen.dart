import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _taglineFade;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Light status bar icons on gradient background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    
    // Navigate after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_hasNavigated) {
        _checkAuthAndNavigate();
      }
    });
  }

  void _checkAuthAndNavigate() {
    final authState = ref.read(authProvider);
    
    if (!authState.isLoading) {
      _hasNavigated = true;
      if (authState.isAuthenticated && authState.user != null) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      } else {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      // If still loading, check again after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasNavigated) {
          _checkAuthAndNavigate();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Restore dark icons for other screens
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF154A7A), Color(0xFF1F66A6), Color(0xFF4A8AC4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Logo — fade in
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Image.asset(
                      'assets/icons/witoutbg.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // App name
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Text(
                      'Pharma Way',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tagline — delayed subtle fade
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      'طريقك الأمثل لإدارة الأدوية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha:0.7),
                          ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  // Subtle loading indicator
                  FadeTransition(
                    opacity: _taglineFade,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
