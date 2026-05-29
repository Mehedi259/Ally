# 🌟 Ally By Avea

**A Personal Development & Community Engagement Platform**

Ally By Avea is a Flutter-based mobile application that combines personal goal tracking, AI-powered motivational coaching, and community support to help users achieve their aspirations through daily guidance and peer connection.

---

## 📱 Overview

Ally By Avea empowers users to:
- **Set and share personal goals** with a supportive community
- **Receive daily motivational messages** from AI-powered archetype advisors
- **Connect with like-minded individuals** through direct messaging
- **Track progress** with scheduled reminders and notifications
- **Build accountability** through a goal-sharing forum

---

## ✨ Key Features

### 🎯 Goal Statement Forum
- Share your personal goals and aspirations with the community
- View and get inspired by others' goal statements
- Automatic syncing between profile and forum
- 90-day goal tracking with expiration reminders

### 🤖 Archetype-Based Bot System
Choose from **10 unique personality-based advisors** to guide your journey:

1. **Calm Monk** - Peaceful wisdom and mindfulness
2. **Champion Coach** - High-energy motivation and encouragement
3. **Drill Sergeant** - No-excuses discipline and accountability
4. **Gentle Guide Bestie** - Warm, caring support
5. **Mindful Millionaire** - Wealth-building and financial guidance
6. **Observational Comedian** - Light-hearted humor and perspective
7. **Stoic Mentor** - Ancient wisdom and resilience
8. **Boardroom CEO** - Strategic thinking and leadership
9. **Voice of Enough** - Self-acceptance and contentment
10. **The Steward** - Responsibility and service

Each archetype delivers **100+ unique messages** tailored to their personality, scheduled according to your preferences.

### 💬 Direct Messaging
- Connect with other users in the community
- Message quota system (3 free messages for trial users)
- Future support for message packages via in-app purchases

### 🔔 Smart Notifications
- **Scheduled bot messages** based on your selected days and times
- **Goal statement reminders** (83-day warning, 90-day expiration)
- **Timezone-aware scheduling** for accurate delivery
- Local push notifications for Android and iOS

### 👤 Comprehensive User Profiles
- Personal information (name, email, timezone, gender, birthday)
- Professional details (education, profession, hobbies)
- Goal statement with creation tracking
- Weekly availability scheduling
- Bot preferences (archetype selection, messaging schedule)
- Subscription and trial management

### 🔐 Secure Authentication
- Email/password authentication
- Google Sign-In integration
- Email verification flow
- Secure user data isolation

---

## 🏗️ Technical Architecture

### Tech Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Cloud Messaging
- **State Management**: Service-based architecture with dependency injection
- **Notifications**: Flutter Local Notifications with timezone support

### Project Structure
```
lib/
├── authentication/     # Login, signup, onboarding flows
├── bots/              # Archetype system and bot services
├── firebase/          # Firebase integration layer
├── forum/             # Goal statement forum
├── messaging/         # Direct messaging system
├── notifications/     # Local push notifications
├── profile/           # User profile management
├── themes/            # UI theming (Dark Purple theme)
├── main.dart          # Application entry point
└── service_locator.dart  # Dependency injection
```

### Design Patterns
- **Service Layer Pattern**: Clear separation between UI and business logic
- **Repository Pattern**: Firebase services implement abstract interfaces
- **Singleton Pattern**: Service locator and notification service
- **Caching Strategy**: Profile and bot data caching for performance

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Firebase account and project setup
- Android Studio / Xcode for platform-specific builds

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Mehedi259/Ally.git
cd Ally
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
- Add your `google-services.json` to `android/app/`
- Add your `GoogleService-Info.plist` to `ios/Runner/`
- Update `firebase_options.dart` with your Firebase configuration

4. **Run the app**
```bash
flutter run
```

### Build for Production

**Android APK**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

---

## 📦 Dependencies

### Core Dependencies
- `firebase_core: ^3.8.1` - Firebase initialization
- `firebase_auth: ^5.3.4` - User authentication
- `cloud_firestore: ^5.6.0` - Database
- `firebase_messaging: ^15.2.10` - Push notifications
- `google_sign_in: ^6.2.2` - Google authentication
- `flutter_local_notifications: ^21.0.0` - Local notifications
- `timezone: ^0.11.0` - Timezone handling
- `sliding_up_panel: ^2.0.0+1` - UI panels
- `flutter_beep: ^1.0.0` - Audio feedback

### Dev Dependencies
- `flutter_launcher_icons: ^0.14.4` - App icon generation
- `flutter_lints: ^5.0.0` - Code quality

---

## 🌍 Platform Support

| Platform | Status | Min Version |
|----------|--------|-------------|
| Android  | ✅ Supported | API 21+ |
| iOS      | ✅ Supported | iOS 12+ |
| Web      | ✅ Configured | - |
| Windows  | ✅ Configured | - |
| macOS    | ⚠️ Partial | - |
| Linux    | ❌ Not configured | - |

---

## 📊 App Version

**Current Version**: 1.0.2+19

---

## 🔒 Security & Privacy

- Firebase Authentication for secure user management
- Firestore security rules for data access control
- User-specific data isolation
- Email verification for account security
- Secure token-based API communication

---

## 🗄️ Database Structure

### Firestore Collections

**profiles**
```json
{
  "id": "user_id",
  "name": "User Name",
  "email": "user@example.com",
  "timezone": "America/New_York",
  "goalStatement": "My personal goal",
  "goalStatementCreatedAt": "2026-05-29T10:00:00Z",
  "selectedArchetype": "calm_monk",
  "botDays": ["Monday", "Wednesday", "Friday"],
  "botTime": "09:00",
  "weeklyAvailability": {},
  "subscriber": false,
  "onboarded": true
}
```

**bots**
```json
{
  "id": "calm_monk",
  "displayName": "Calm Monk",
  "description": "Peaceful wisdom and mindfulness",
  "messages": ["Message 1", "Message 2", ...]
}
```

**messages**
```json
{
  "id": "message_id",
  "senderId": "sender_user_id",
  "recipientId": "recipient_user_id",
  "content": "Message content",
  "sentAt": "2026-05-29T10:00:00Z"
}
```

---

## 🎨 UI/UX Features

- **Dark Purple Theme**: Modern, calming color scheme
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Sliding panels and transitions
- **Intuitive Navigation**: Bottom navigation and menu system
- **Accessibility**: Material Design compliance

---

## 🔮 Upcoming Features

Based on the implementation plan:

- [ ] Multiple archetype selection
- [ ] Auto-delete messages after 3 days
- [ ] Maximum 3 concurrent bot messages
- [ ] Local timezone display for messages
- [ ] New archetypes: "Higher Self" and "Grandmaster of Do Nothing"
- [ ] 400 additional goal statements
- [ ] In-app purchase system for message packages
- [ ] Enhanced forum features
- [ ] Advanced notification customization

---

## 🤝 Contributing

This is a private project. For inquiries, please contact the project maintainer.

---

## 📄 License

Copyright © 2026 Ally By Avea. All rights reserved.

---

## 📞 Support

For support, feature requests, or bug reports, please contact the development team.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- All contributors and testers

---

**Built with ❤️ using Flutter**
