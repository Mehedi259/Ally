# Authentication Flow

This directory contains the complete authentication flow for Ally by Avea.

## Screens

### 1. Login Screen (`login.dart`)
**Purpose:** Allows existing users to sign in to their account

**Features:**
- Email and password fields with validation styling
- "Forgot Password?" link
- Primary "Sign In" button
- Social login options (Google, Apple, Facebook)
- "Sign Up" link for new users

**Navigation:**
- Taps "Sign Up" → Navigates to Sign Up Screen
- Taps "Forgot Password?" → (TODO: Navigate to password reset)
- Successful login → (TODO: Navigate to main app)

---

### 2. Sign Up Screen (`signup.dart`)
**Purpose:** Allows new users to create an account

**Features:**
- Full name input field
- Email address field
- Password field with visibility toggle and requirements hint
- Confirm password field
- Terms & Conditions and Privacy Policy checkbox with links
- Primary "Create Account" button
- Social sign up options (Google, Apple, Facebook)
- "Sign In" link for existing users

**Navigation:**
- Taps "Create Account" → Navigates to Email Verification Screen
- Taps "Sign In" → Returns to Login Screen
- Social sign up → (TODO: Handle social authentication)

**Form Validation (TODO):**
- Full name: Required, minimum 2 characters
- Email: Valid email format
- Password: Minimum 8 characters
- Confirm password: Must match password
- Terms checkbox: Must be checked

---

### 3. Email Verification Screen (`email_verification.dart`)
**Purpose:** Verifies user's email address with a 6-digit code

**Features:**
- Visual email icon indicator
- Display of the email being verified
- 6 individual digit input fields (auto-focus and advance)
- Automatic verification when all 6 digits are entered
- Manual "Verify Email" button
- Resend code functionality with 60-second countdown timer
- "Change Email Address" link to go back

**User Experience:**
- Auto-focuses on first digit field
- Automatically moves to next field when a digit is entered
- Clears field content when tapped for easy correction
- Auto-submits verification when all fields are filled
- Timer prevents spam by disabling resend for 60 seconds

**Navigation:**
- Successful verification → (TODO: Navigate to onboarding or main app)
- Taps "Change Email Address" → Returns to Sign Up Screen

---

## Design System

### Colors
- **Primary Purple:** `Color.fromARGB(255, 160, 126, 219)`
- **Google White:** `Colors.white` with grey border
- **Apple Black:** `Colors.black`
- **Facebook Blue:** `Color(0xFF1877F2)`

### Common Patterns
- **Border Radius:** 12px for all buttons and input fields
- **Input Focus:** 2px purple border
- **Button Padding:** Vertical 14-16px
- **Social Buttons:** Icon + centered label with brand colors

### Typography
- **Main Titles:** 28-36px, bold
- **Subtitles:** 16-18px, grey
- **Buttons:** 15-16px, medium/bold weight
- **Helper Text:** 14px, grey

---

## TODO: Backend Integration

### Authentication Service
Create an authentication service similar to `ForumService` and `ProfileService`:

```dart
abstract interface class IAuthService {
  Future<AuthResult> signIn(String email, String password);
  Future<AuthResult> signUp(String name, String email, String password);
  Future<bool> sendVerificationCode(String email);
  Future<bool> verifyEmail(String email, String code);
  Future<bool> resendVerificationCode(String email);
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();
  Future<AuthResult> signInWithFacebook();
  Future<bool> resetPassword(String email);
}
```

### Required Dependencies
When implementing actual authentication, consider adding:
- `firebase_auth` - For Firebase Authentication
- `google_sign_in` - For Google authentication
- `sign_in_with_apple` - For Apple authentication
- `flutter_facebook_auth` - For Facebook authentication
- `shared_preferences` or `flutter_secure_storage` - For storing auth tokens

### State Management
Consider implementing state management for:
- User authentication state
- Form validation
- Loading states during API calls
- Error handling and display

---

## Current Status

✅ **Completed:**
- Login screen UI with modern design
- Sign up screen UI with form fields
- Email verification screen with 6-digit code input
- Navigation flow between screens
- Social login button styling (Google, Apple, Facebook)
- Resend code timer functionality
- Terms & Conditions checkbox

⏳ **TODO:**
- Form validation logic
- Backend API integration
- Social authentication implementation
- Password reset flow
- Error handling and user feedback
- Loading states during authentication
- Secure token storage
- Session management
- "Remember me" functionality (optional)
