import 'package:flutter/material.dart';
import 'email_verification.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:exploration_project/service_locator.dart';
import 'auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (!_agreedToTerms) {
      _showError('Please agree to the Terms & Conditions and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the user account
      await ServiceLocator.authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Save the user's name (but don't mark as fully onboarded yet)
      // We'll use a temporary marker that create_profile.dart will replace
      await ServiceLocator.authService.updateDisplayName('_ONBOARDING_${_nameController.text.trim()}');

      // Send verification email
      await ServiceLocator.authService.sendEmailVerification();

      // Navigate to email verification screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: AveaThemes.current().primarySwatch,
      ),
      backgroundColor: AveaThemes.current().backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Header Section
                Text(
                  "Join Ally by Avea",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AveaThemes.current().primarySwatch,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create your account to get started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AveaThemes.current().secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Full Name TextField
                TextField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  style: TextStyle(color: AveaThemes.current().textColor),
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    labelStyle:  TextStyle(color: AveaThemes.current().secondaryTextColor),
                    prefixIcon:  Icon(Icons.person_outline, color: AveaThemes.current().primarySwatch),
                    filled: true,
                    fillColor: AveaThemes.current().cardBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:  BorderSide(
                        color: AveaThemes.current().primarySwatch,
                        width: 2,
                      ),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                
                // Email TextField
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  style:  TextStyle(color: AveaThemes.current().textColor),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                    prefixIcon: Icon(Icons.email_outlined, color: AveaThemes.current().primarySwatch),
                    filled: true,
                    fillColor: AveaThemes.current().cardBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:  BorderSide(color: AveaThemes.current().cardLighterBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AveaThemes.current().primarySwatch,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Password TextField
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  style: TextStyle(color: AveaThemes.current().textColor),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle:  TextStyle(color: AveaThemes.current().secondaryTextColor),
                    prefixIcon:  Icon(Icons.lock_outline, color: AveaThemes.current().primarySwatch),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AveaThemes.current().cardBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AveaThemes.current().primarySwatch,
                        width: 2,
                      ),
                    ),
                    helperText: "At least 8 characters",
                    helperStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 16),
                
                // Confirm Password TextField
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  style:  TextStyle(color: AveaThemes.current().textColor),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                    prefixIcon: Icon(Icons.lock_outline, color: AveaThemes.current().primarySwatch),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AveaThemes.current().cardBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AveaThemes.current().primarySwatch,
                        width: 2,
                      ),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),
                const SizedBox(height: 24),
                
                // Terms and Conditions Checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: AveaThemes.current().primarySwatch,
                        checkColor: Colors.white,
                        side: BorderSide(color: AveaThemes.current().cardLighterBackground),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            "I agree to the ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AveaThemes.current().textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Show terms and conditions
                            },
                            child:  Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                fontSize: 14,
                                color: AveaThemes.current().primarySwatch,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            " and ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AveaThemes.current().textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Show privacy policy
                            },
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 14,
                                color: AveaThemes.current().primarySwatch,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AveaThemes.current().primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: AveaThemes.current().primarySwatch.withValues(alpha: 0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                
                // Divider with "OR"
                Row(
                  children: [
                    Expanded(child: Divider(color: AveaThemes.current().cardLighterBackground)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(color: AveaThemes.current().secondaryTextColor),
                      ),
                    ),
                    Expanded(child: Divider(color: AveaThemes.current().cardLighterBackground)),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Social Sign Up Buttons
                _SocialSignUpButton(
                  onPressed: () {
                    // Handle Google sign up
                  },
                  icon: Icons.g_mobiledata,
                  label: "Sign up with Google",
                  backgroundColor: AveaThemes.current().cardBackgroundColor,
                  textColor: AveaThemes.current().textColor,
                  borderColor: AveaThemes.current().cardLighterBackground,
                ),
                const SizedBox(height: 12),
                
                _SocialSignUpButton(
                  onPressed: () {
                    // Handle Apple sign up
                  },
                  icon: Icons.apple,
                  label: "Sign up with Apple",
                  backgroundColor: AveaThemes.current().cardBackgroundColor,
                  textColor: AveaThemes.current().textColor,
                  borderColor: AveaThemes.current().cardLighterBackground,
                ),
                const SizedBox(height: 12),
                
                _SocialSignUpButton(
                  onPressed: () {
                    // Handle Facebook sign up
                  },
                  icon: Icons.facebook,
                  label: "Sign up with Facebook",
                  backgroundColor: AveaThemes.current().cardBackgroundColor,
                  textColor: AveaThemes.current().textColor,
                  borderColor: AveaThemes.current().cardLighterBackground,
                ),
                const SizedBox(height: 32),
                
                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AveaThemes.current().secondaryTextColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: AveaThemes.current().primarySwatch,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSignUpButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialSignUpButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: borderColor ?? backgroundColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
