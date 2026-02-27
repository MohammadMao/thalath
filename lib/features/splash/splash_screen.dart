import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/services/sound_service.dart';
import '../../core/theming/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Play the open sound
    Get.find<SoundService>().playGameOpen();

    // Navigate after splash duration
    Future.delayed(const Duration(milliseconds: 2400), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final auth = Get.find<AuthService>();
    if (auth.firebaseUser.value != null) {
      Get.offAllNamed('/lobby');
    } else {
      Get.offAllNamed('/home');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Gradient background ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1A2E), // deep navy
                  AppTheme.darkBackground,
                  Color(0xFF091714), // deep teal-green
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // ── Radial glow behind logo ───────────────────────────────────
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryTeal.withValues(alpha: 0.18),
                    AppTheme.primaryGreen.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // ── Logo + subtitle ──────────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App logo
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 160,
                      height: 160,
                    ),
                    const SizedBox(height: 24),
                    // Subtitle
                    Text(
                      'اختبر مفرداتك العربية!',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary.withValues(alpha: 0.75),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
