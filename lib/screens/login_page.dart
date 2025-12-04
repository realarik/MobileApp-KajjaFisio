import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajjafisioapp/screens/forgotpw.dart';
import 'package:kajjafisioapp/screens/register_page.dart';
import 'package:kajjafisioapp/screens/admin/my_orders_admin.dart';
import 'package:kajjafisioapp/screens/pasien/home_pasien.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkUserLoginStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkUserLoginStatus() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (currentUser.email?.toLowerCase() == 'terapiskjfisiohome25@gmail.com') {
          await _saveAdminDataToFirebase(currentUser);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyOrdersAdminPage()),
          );
        } else {
          await _saveUserDataToFirebase(currentUser);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePasienPage()),
          );
        }
      });
    }
  }

  void _loginUser() async {
  if (_isLoading) return;

  setState(() {
    _isLoading = true;
  });

  HapticFeedback.lightImpact();

  try {
    final emailInput = _emailController.text.trim();
    final passwordInput = _passwordController.text.trim();
    print('[DEBUG] Login attempt: email="$emailInput" password_length=${passwordInput.length}');
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailInput,
      password: passwordInput,
    );

    if (userCredential.user != null) {
      if (userCredential.user!.email?.toLowerCase() == 'terapiskjfisiohome25@gmail.com') {
        await _saveAdminDataToFirebase(userCredential.user!);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyOrdersAdminPage()),
          );
        }
      } else {
        await _saveUserDataToFirebase(userCredential.user!);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePasienPage()),
          );
        }
      }
    }
  } on FirebaseAuthException catch (e) {
    print('[LOGIN ERROR] code: "+e.code+" message: "+(e.message ?? "")');
    String message;
    if (e.code == 'user-not-found') {
      message = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password provided for that user.';
    } else {
      message = e.message ?? 'An unknown error occurred.';
    }
    if (mounted) {
      _showErrorSnackBar(message);
    }
  } catch (e) {
    print('[LOGIN ERROR] Unexpected: $e');
    if (mounted) {
      _showErrorSnackBar('Terjadi kesalahan tak terduga: $e');
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.08,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Header dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to your account',
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.04,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.06),

                      // Form dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Email field
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                icon: Icons.email_outlined,
                                constraints: constraints,
                              ),

                              const SizedBox(height: 20),

                              // Password field
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hintText: 'Enter your password',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                constraints: constraints,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordPage()),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor:
                                        AppColors.primaryColor.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.045,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.06),

                      // Sign up link dengan animasi
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: constraints.maxWidth * 0.04,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage()),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: constraints.maxWidth * 0.04,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required BoxConstraints constraints,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.04,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.04,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: constraints.maxWidth * 0.04,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveUserDataToFirebase(User user) async {
    try {
      final String userId = user.uid;
      final String email = user.email ?? '';
      final String displayName = user.displayName ?? email.split('@')[0];

      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc('pasien')
          .collection('data')
          .doc(userId)
          .get();

      final Map<String, dynamic> userData = {
        'uid': userId,
        'email': email,
        'displayName': displayName,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!userDoc.exists) {
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['isActive'] = true;
      }

      await _firestore
          .collection('users')
          .doc('pasien')
          .collection('data')
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> _saveAdminDataToFirebase(User user) async {
    try {
      final String userId = user.uid;
      final String email = user.email ?? '';
      final String displayName = 'Admin KajjaFisio';

      final DocumentSnapshot adminDoc = await _firestore
          .collection('users')
          .doc('admin')
          .collection('data')
          .doc(userId)
          .get();

      final Map<String, dynamic> adminData = {
        'uid': userId,
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'permissions': [
          'read',
          'write',
          'delete',
          'manage_orders',
          'manage_users'
        ],
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!adminDoc.exists) {
        adminData['createdAt'] = FieldValue.serverTimestamp();
        adminData['isActive'] = true;
        adminData['loginCount'] = 1;
      } else {
        final currentData = adminDoc.data() as Map<String, dynamic>?;
        final currentLoginCount = currentData?['loginCount'] ?? 0;
        adminData['loginCount'] = currentLoginCount + 1;
      }

      await _firestore
          .collection('users')
          .doc('admin')
          .collection('data')
          .doc(userId)
          .set(adminData, SetOptions(merge: true));
    } catch (e) {
      print('Error saving admin data: $e');
    }
  }
}
