import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kajjafisioapp/screens/register_page.dart';
import 'package:kajjafisioapp/screens/login_page.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
  body: Container(
    color: AppColors.primaryColor,
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.08,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top spacing
                      SizedBox(height: constraints.maxHeight * 0.08),
                      // Logo dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildLogo(constraints),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.06),
                      // Welcome text dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildWelcomeText(constraints),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      // Description dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildDescription(constraints),
                        ),
                      ),
                      // Flexible spacing - akan mengambil sisa ruang yang tersedia
                      const Expanded(child: SizedBox()),
                      // Buttons dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildButtons(constraints),
                        ),
                      ),
                      // Bottom spacing
                      SizedBox(height: constraints.maxHeight * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  ),
);
  }

  Widget _buildLogo(BoxConstraints constraints) {
  final logoSize = constraints.maxWidth * 0.25;
  return Image.asset(
    'assets/images/Logo_KJ.png',
    width: logoSize,
    height: logoSize,
    fit: BoxFit.contain,
  );
}

  Widget _buildWelcomeText(BoxConstraints constraints) {
    return Text(
      'Welcome to KajjaFisio!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: constraints.maxWidth * 0.065,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
        height: 1.2,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth * 0.05,
      ),
      child: Text(
        'KajjaFisio melayani kebutuhan terapi seluruh keluarga dengan nyaman tanpa antrian, tanpa ribet, hasil maksimal di rumah aja!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: constraints.maxWidth * 0.04,
          color: AppColors.textColor.withOpacity(0.7),
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildButtons(BoxConstraints constraints) {
    return Column(
      children: [
        // Get Started Button
        Container(
          width: double.infinity,
          height: 56,
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to registration or main app
              _handleGetStarted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primaryColor,
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Get Started',
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.045,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        
        // Sign In Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to sign in
              _handleSignIn();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black.withOpacity(0.15),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.045,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleGetStarted() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }

  void _handleSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}