import 'package:flutter/material.dart';
import 'package:exploration_project/service_locator.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'dart:async';
import 'auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  
  bool _isResendEnabled = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  Timer? _verificationCheckTimer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startVerificationCheckTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  void _startVerificationCheckTimer() {
    // Check every 3 seconds if the user has verified their email
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        await ServiceLocator.authService.reloadUser();
        final user = ServiceLocator.authService.currentUser;
        
        if (user != null && user.emailVerified) {
          timer.cancel();
          if (mounted) {
            // Email verified! Pop back to root and let auth state handle navigation
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } catch (e) {
        // Ignore errors during periodic check
      }
    });
  }

  Future<void> _verifyCode() async {

    setState(() {
      _isVerifying = true;
    });

    try {
      // Reload user data to check if email is verified
      await ServiceLocator.authService.reloadUser();
      final user = ServiceLocator.authService.currentUser;
      
      if (user != null && user.emailVerified) {
        if (mounted) {
          // Email verified! Navigate to main app
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Pop back to root and let auth state handle navigation
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please click the verification link in your email'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_isResendEnabled) return;

    try {
      await ServiceLocator.authService.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Verification email resent!'),
            backgroundColor: AveaThemes.current().primarySwatch,
          ),
        );
      }

      _startResendTimer();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend email. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
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
                const SizedBox(height: 40),
                
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AveaThemes.current().primarySwatch.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: AveaThemes.current().primarySwatch,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                 Text(
                  "Check Your Email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AveaThemes.current().textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                 Text(
                  "We've sent a verification link to",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AveaThemes.current().secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AveaThemes.current().primarySwatch,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Click the link in the email to verify your account.\nYou can close this screen once verified.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AveaThemes.current().secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 48),
                
                const SizedBox(height: 16),
                
                // Check Verification Status Button
                ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
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
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "I've Verified My Email",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                
                // Resend Code Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
     Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                    ),
                    TextButton(
                      onPressed: _isResendEnabled ? _resendCode : null,
                      child: Text(
                        _isResendEnabled
                            ? "Resend"
                            : "Resend in ${_resendCountdown}s",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isResendEnabled
                              ? AveaThemes.current().primarySwatch
                              : AveaThemes.current().cardLighterBackground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Change Email
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text(
                    "Change Email Address",
                    style: TextStyle(
                      fontSize: 14,
                      color: AveaThemes.current().primarySwatch,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
