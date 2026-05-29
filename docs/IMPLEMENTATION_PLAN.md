# Ally By Avea - Complete Implementation Plan

**Project:** Ally By Avea App Updates  
**Client:** Amy  
**Platform:** Flutter (Android + iOS)  
**Backend:** Firebase (Firestore, Auth, Cloud Functions)

---

## 📋 Table of Contents

1. [Critical Bug Fixes](#1-critical-bug-fixes)
2. [UI/UX Improvements](#2-uiux-improvements)
3. [Archetype System Updates](#3-archetype-system-updates)
4. [Message System Enhancements](#4-message-system-enhancements)
5. [Theme & Design Updates](#5-theme--design-updates)
6. [Instructions & Welcome Page](#6-instructions--welcome-page)
7. [Android Build & Deployment](#7-android-build--deployment)
8. [App Store Submission](#8-app-store-submission)
9. [Subscription API (Future Phase)](#9-subscription-api-future-phase)

---

## Priority Matrix

| Priority | Tasks | Estimated Time |
|----------|-------|----------------|
| 🔴 **CRITICAL** | Bug Fixes (#1-10) | 3-5 days |
| 🟡 **HIGH** | Archetype Updates, Message Timing | 5-7 days |
| 🟢 **MEDIUM** | Theme, UI Polish | 3-4 days |
| 🔵 **LOW** | Android Build, Store Submission | 2-3 days |

**Total Estimated Time:** 2-3 weeks

---

## 1. Critical Bug Fixes

### 1.1 Goal Statement Not Posting to Forum ⚠️
**Issue:** User creates goal statement in profile but it doesn't appear in forum.

**Root Cause:** Profile update doesn't sync with forum collection.

**Solution:**
- [ ] Update `FirebaseProfileService.updateUserProfile()` to also update forum
- [ ] When `goalStatement` is saved, create/update corresponding forum post
- [ ] Add `goalStatementCreatedAt` timestamp

**Files to Modify:**
- `lib/firebase/firebase_profile_service.dart`
- `lib/firebase/firebase_forum_service.dart`

**Implementation Steps:**
```dart
// In firebase_profile_service.dart
Future<void> updateUserProfile(String token, UserProfile profile) async {
  // 1. Save profile to Firestore
  await _firestore.collection('profiles').doc(profile.id).set(profile.toJson());
  
  // 2. If goal statement exists, sync to forum
  if (profile.goalStatement != null && profile.goalStatement!.isNotEmpty) {
    await _syncGoalToForum(profile);
  } else {
    // If goal is empty/null, remove from forum
    await _removeGoalFromForum(profile.id);
  }
}
```

**Testing:**
- [ ] Create new goal statement → verify it appears in forum
- [ ] Update goal statement → verify forum post updates
- [ ] Delete goal statement → verify it disappears from forum

---

### 1.2 Goal Statement Not Deleting from Forum ⚠️
**Issue:** When user deletes goal from profile, it remains in forum.

**Solution:**
- [ ] Add delete functionality in profile edit screen
- [ ] When goal is deleted/cleared, remove from forum collection
- [ ] Update Firestore security rules to allow deletion

**Files to Modify:**
- `lib/edit_profile.dart`
- `lib/firebase/firebase_profile_service.dart`
- `firestore.rules`

**Implementation:**
```dart
// Add delete button in edit_profile.dart
if (profile.goalStatement != null) {
  ElevatedButton(
    onPressed: () async {
      // Clear goal statement
      profile.goalStatement = null;
      profile.goalStatementCreatedAt = null;
      await profileService.updateUserProfile('token', profile);
    },
    child: Text('Delete Goal Statement'),
  )
}
```

---

### 1.3 Wrong User Profile Opening from Forum ⚠️
**Issue:** Clicking on forum post opens incorrect user profile.

**Root Cause:** User ID not properly passed in navigation.

**Solution:**
- [ ] Fix `userId` parameter in `Post2` widget
- [ ] Ensure correct `userId` is passed from `ForumPost` to `ViewProfile`

**Files to Modify:**
- `lib/post.dart`
- `lib/forum.dart`

**Current Code Issue:**
```dart
// In forum.dart - WRONG
Post2(
  userId: post.userId,  // ✅ This is correct
  // ...
)

// In post.dart navigation - CHECK THIS
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ViewProfile(
      userId: widget.userId,  // ✅ Make sure this is correct
    ),
  ),
);
```

---

### 1.4 Edit Button Visible on Other Users' Profiles ⚠️
**Issue:** Edit button shows when viewing other users' profiles (security issue).

**Solution:**
- [ ] Add conditional check: only show edit button if viewing own profile
- [ ] Compare `currentUserId` with `profileUserId`

**Files to Modify:**
- `lib/view_profile.dart`

**Implementation:**
```dart
// In view_profile.dart
final currentUser = ServiceLocator.authService.currentUser;
final isOwnProfile = currentUser?.uid == widget.userId;

// Only show edit button if own profile
if (isOwnProfile) {
  IconButton(
    icon: Icon(Icons.edit),
    onPressed: () => Navigator.push(...),
  )
}
```

---

### 1.5 Unauthorized Goal Statement Editing ⚠️
**Issue:** Amy was able to change another user's goal statement.

**Solution:**
- [ ] Add server-side validation in Firestore rules
- [ ] Add client-side authorization checks
- [ ] Ensure only profile owner can edit their goal

**Files to Modify:**
- `firestore.rules`
- `lib/firebase/firebase_profile_service.dart`

**Firestore Rules Update:**
```javascript
match /profiles/{userId} {
  // Only owner can write
  allow write: if request.auth != null && request.auth.uid == userId;
  
  // Everyone can read
  allow read: if request.auth != null;
}
```

---

## 2. UI/UX Improvements

### 2.1 Remove Reply Button from Goal Statement Messages ✅
**Issue:** Reply button appears on archetype messages, which shouldn't be replied to.

**Solution:**
- [ ] Add message type check (bot message vs user message)
- [ ] Conditionally hide reply button for bot messages
- [ ] Use `BotSenderHelper.isBotSenderId()` to detect bot messages

**Files to Modify:**
- `lib/messaging/messages_screen.dart`

**Implementation:**
```dart
// In message list item
if (!BotSenderHelper.isBotSenderId(message.senderId)) {
  // Show reply button only for user messages
  IconButton(
    icon: Icon(Icons.reply),
    onPressed: () => _replyToMessage(message),
  )
}
```

---

### 2.2 Change Robot Icon to Groups Icon 🎨
**Issue:** Current archetype icon is robot, client wants "Groups" icon.

**Solution:**
- [ ] Replace `Icons.smart_toy` with `Icons.groups`
- [ ] Update icon in archetype selection UI
- [ ] Add custom icon if needed (from ChatGPT design)

**Files to Modify:**
- `lib/edit_profile.dart` (archetype selection section)

**Implementation:**
```dart
// Replace
Icon(Icons.smart_toy)  // ❌ Old

// With
Icon(Icons.groups)  // ✅ New
```

---

### 2.3 Add Sci-Fi Portal Banner on Forum 🎨
**Issue:** Forum needs visual enhancement with banner.

**Solution:**
- [ ] Create banner widget with client-provided text
- [ ] Add at top of forum screen
- [ ] Use gradient background (tan/purple palette)

**Files to Modify:**
- `lib/forum.dart`

**Implementation:**
```dart
// Add banner at top of forum
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFD4A574), Color(0xFFB8A0D9)],
    ),
  ),
  child: Text(
    'CLIENT_PROVIDED_BANNER_TEXT',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
)
```

---

## 3. Archetype System Updates

### 3.1 Add 2 New Archetypes 🤖
**New Archetypes:**
1. **Higher Self** - Spiritual, enlightened guidance
2. **Grandmaster of Do Nothing** - Zen, minimalist approach

**Solution:**
- [ ] Create 2 new archetype documents in Firestore
- [ ] Add archetype metadata (id, displayName, description)
- [ ] Update archetype selection dropdown

**Files to Modify:**
- `lib/bots/bot_seed_data.dart`
- Firestore `bots` collection

**Firestore Structure:**
```javascript
bots/higher_self {
  id: "higher_self",
  displayName: "Higher Self",
  description: "Spiritual guidance from your enlightened self",
  messages: [/* 200 messages */]
}

bots/grandmaster_of_do_nothing {
  id: "grandmaster_of_do_nothing",
  displayName: "Grandmaster of Do Nothing",
  description: "Zen wisdom through the art of non-doing",
  messages: [/* 200 messages */]
}
```

---

### 3.2 Add 400 Goal Statements (200 per Archetype) 📝
**Task:** Add motivational messages for each new archetype.

**Solution:**
- [ ] Receive 400 messages from client (copy-paste ready)
- [ ] Format as Dart list
- [ ] Upload to Firestore programmatically

**Files to Modify:**
- `lib/bots/bot_seed_data.dart`

**Implementation:**
```dart
// In bot_seed_data.dart
final higherSelfMessages = [
  "Message 1: ...",
  "Message 2: ...",
  // ... 200 messages
];

final grandmasterMessages = [
  "Message 1: ...",
  "Message 2: ...",
  // ... 200 messages
];

// Upload to Firestore
Future<void> seedNewArchetypes() async {
  await FirebaseFirestore.instance.collection('bots').doc('higher_self').set({
    'id': 'higher_self',
    'displayName': 'Higher Self',
    'description': '...',
    'messages': higherSelfMessages,
  });
  
  // Same for grandmaster_of_do_nothing
}
```

---

### 3.3 Multiple Archetype Selection 🎯
**Feature:** Allow users to select multiple archetypes or "Select All".

**Current:** Single archetype selection  
**New:** Multi-select with random daily rotation

**Solution:**
- [ ] Change UI from dropdown to multi-select chips
- [ ] Update profile model: `selectedArchetype` → `selectedArchetypes` (List)
- [ ] Add "Select All" button
- [ ] Modify bot scheduling to randomly pick from selected archetypes

**Files to Modify:**
- `lib/profile/profile_service.dart`
- `lib/edit_profile.dart`
- `lib/firebase/firebase_bot_service.dart`
- `lib/notifications/local_notifications_service.dart`

**Profile Model Update:**
```dart
class UserProfile {
  // OLD
  String? selectedArchetype;
  
  // NEW
  List<String> selectedArchetypes;  // Can have multiple
}
```

**UI Implementation:**
```dart
// Multi-select chips
Wrap(
  children: allArchetypes.map((archetype) {
    final isSelected = selectedArchetypes.contains(archetype.id);
    return FilterChip(
      label: Text(archetype.displayName),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedArchetypes.add(archetype.id);
          } else {
            selectedArchetypes.remove(archetype.id);
          }
        });
      },
    );
  }).toList(),
)

// Select All button
ElevatedButton(
  onPressed: () {
    setState(() {
      selectedArchetypes = allArchetypes.map((a) => a.id).toList();
    });
  },
  child: Text('Select All'),
)
```

**Random Selection Logic:**
```dart
// When scheduling notification
String getRandomArchetype() {
  if (selectedArchetypes.isEmpty) return null;
  final random = Random();
  return selectedArchetypes[random.nextInt(selectedArchetypes.length)];
}
```

---

## 4. Message System Enhancements

### 4.1 Auto-Delete Messages After 3 Days ⏰
**Feature:** Archetype messages automatically delete after 72 hours.

**Solution:**
- [ ] Add `expiresAt` timestamp field to messages
- [ ] Set `expiresAt = sentAt + 3 days`
- [ ] Query messages where `expiresAt > now()`
- [ ] Run cleanup job (Cloud Function or client-side)

**Files to Modify:**
- `lib/messaging/message_service.dart`
- `lib/firebase/firebase_message_service.dart`
- Firestore `messages` collection

**Message Model Update:**
```dart
class Message {
  final DateTime sentAt;
  final DateTime expiresAt;  // NEW
  
  Message({
    required this.sentAt,
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ?? sentAt.add(Duration(days: 3));
}
```

**Query Active Messages:**
```dart
Future<List<Message>> getActiveMessages(String userId) async {
  final now = DateTime.now();
  final snapshot = await _firestore
    .collection('messages')
    .where('recipientId', isEqualTo: userId)
    .where('expiresAt', isGreaterThan: now.toIso8601String())
    .orderBy('expiresAt', descending: true)
    .get();
  
  return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
}
```

**Cleanup Job (Optional - Cloud Function):**
```javascript
// Firebase Cloud Function
exports.cleanupExpiredMessages = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expired = await db.collection('messages')
      .where('expiresAt', '<', now)
      .get();
    
    const batch = db.batch();
    expired.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
  });
```

---

### 4.2 Maximum 3 Prompts Rule 📊
**Feature:** Never show more than 3 bot messages at once.

**Solution:**
- [ ] When fetching messages, limit to 3 most recent
- [ ] When new message arrives, delete oldest if count > 3
- [ ] Apply only to bot messages, not user messages

**Implementation:**
```dart
Future<List<Message>> getBotMessages(String userId) async {
  final messages = await getActiveMessages(userId);
  
  // Filter bot messages only
  final botMessages = messages
    .where((m) => BotSenderHelper.isBotSenderId(m.senderId))
    .toList();
  
  // Keep only 3 most recent
  if (botMessages.length > 3) {
    // Delete oldest messages
    final toDelete = botMessages.skip(3);
    for (var msg in toDelete) {
      await _firestore.collection('messages').doc(msg.id).delete();
    }
  }
  
  return botMessages.take(3).toList();
}
```

---

### 4.3 Show Local Time Instead of UTC ⏰
**Issue:** Message timestamps show UTC time, confusing users.

**Solution:**
- [ ] Convert UTC timestamps to user's local timezone
- [ ] Use `timezone` package (already in pubspec.yaml)
- [ ] Display relative time ("2 hours ago") or local time

**Files to Modify:**
- `lib/messaging/messages_screen.dart`

**Implementation:**
```dart
import 'package:timezone/timezone.dart' as tz;

String formatMessageTime(DateTime utcTime, String userTimezone) {
  // Convert UTC to user's timezone
  final location = tz.getLocation(userTimezone);
  final localTime = tz.TZDateTime.from(utcTime, location);
  
  // Show relative time
  final now = tz.TZDateTime.now(location);
  final difference = now.difference(localTime);
  
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

// Usage
Text(formatMessageTime(message.sentAt, profile.timezone ?? 'America/New_York'))
```

---

## 5. Theme & Design Updates

### 5.1 Change Theme from Tan to Client-Preferred Colors 🎨
**Issue:** Current tan theme not preferred by Amy.

**Solution:**
- [ ] Wait for Amy to provide color swatches
- [ ] Update `lib/themes/dark_purple_theme.dart` (line 246)
- [ ] Apply new color palette throughout app

**Files to Modify:**
- `lib/themes/dark_purple_theme.dart`

**Current Theme Location:**
```dart
// Line 246 in dark_purple_theme.dart
class AveaThemes {
  static AveaTheme current() {
    return AveaTheme(
      primarySwatch: Color(0xFFD4A574),  // ← Change this
      backgroundColor: Color(0xFFF5F5DC),  // ← And this
      // ... other colors
    );
  }
}
```

**Action Required:**
- [ ] Request color swatches from Amy
- [ ] Update theme file with new colors
- [ ] Test app with new theme

---

### 5.2 Apply HTML/CSS Design Direction 🎨
**Reference:** Amy shared HTML/CSS files for visual direction.

**Design Elements:**
- Warm morning-style UI
- Tan, off-white, and pastel purple palette
- Sci-Fi Portal banner on forum

**Solution:**
- [ ] Extract colors from HTML/CSS files
- [ ] Apply gradient backgrounds
- [ ] Update card styles to match reference

**Implementation:**
```dart
// Forum gradient background
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF5E6D3),  // Warm tan
        Color(0xFFE8D5F2),  // Pastel purple
      ],
    ),
  ),
)
```

---

## 6. Instructions & Welcome Page

### 6.1 Update App Instructions 📖
**Issue:** Current instructions are outdated.

**Solution:**
- [ ] Receive new instructions text from Amy
- [ ] Update welcome/onboarding screens
- [ ] Update in-app help/instructions page

**Files to Modify:**
- `lib/instructions.dart`
- `lib/authentication/onboarding_flow.dart`
- `lib/welcome.dart`

**Action Required:**
- [ ] Request new instructions document from Amy
- [ ] Replace old text with new content
- [ ] Update screenshots if needed

---

## 7. Android Build & Deployment

### 7.1 Create Android APK 📱
**Issue:** Only iOS build exists, need Android version.

**Solution:**
- [ ] Configure Android build settings
- [ ] Update `android/app/build.gradle`
- [ ] Generate signing key
- [ ] Build release APK

**Steps:**

1. **Generate Signing Key:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

2. **Configure Signing:**
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. **Update build.gradle:**
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. **Build APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

### 7.2 Upload to Google Play Console 🚀
**Task:** Submit app to Amy's Google Play Console account.

**Prerequisites:**
- [ ] Google Play Developer account ($25 one-time fee)
- [ ] App signing key
- [ ] App screenshots (phone + tablet)
- [ ] App description & metadata
- [ ] Privacy policy URL

**Steps:**

1. **Create App in Play Console:**
   - Go to Google Play Console
   - Create new app
   - Fill in app details

2. **Prepare Store Listing:**
   - App name: "Ally By Avea"
   - Short description (80 chars)
   - Full description (4000 chars)
   - Screenshots (minimum 2)
   - Feature graphic (1024x500)
   - App icon (512x512)

3. **Upload APK:**
   - Go to "Release" → "Production"
   - Upload `app-release.apk`
   - Fill in release notes

4. **Content Rating:**
   - Complete questionnaire
   - Get rating certificate

5. **Submit for Review:**
   - Review all sections
   - Submit app

**Timeline:** 1-3 days for Google review

---

## 8. App Store Submission

### 8.1 Transfer iOS App to Amy's Apple Account 🍎
**Task:** Change Bundle ID and transfer to Amy's developer account.

**Current Bundle ID:** `com.example.exploration_project`  
**New Bundle ID:** TBD (Amy will provide)

**Steps:**

1. **Update Bundle ID:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.amy.allybyavea</string>  <!-- New ID -->
```

2. **Update Xcode Project:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner target
   - Change Bundle Identifier
   - Update Team to Amy's account

3. **Update Provisioning Profile:**
   - Login to Apple Developer account
   - Create new App ID
   - Create provisioning profile
   - Download and install

4. **Build for TestFlight:**
```bash
flutter build ios --release
# Then archive in Xcode and upload to App Store Connect
```

---

### 8.2 TestFlight Setup 🧪
**Task:** Set up beta testing via TestFlight.

**Steps:**
1. Upload build to App Store Connect
2. Add internal testers (Amy + team)
3. Add external testers (beta users)
4. Distribute build

**Testing Checklist:**
- [ ] Authentication works
- [ ] Goal statements sync to forum
- [ ] Messages send/receive correctly
- [ ] Bot notifications arrive on schedule
- [ ] All UI elements display correctly

---

## 9. Subscription API (Future Phase)

### 9.1 Google Play Billing Integration 💳
**Feature:** In-app purchases for message packages.

**Package:** `in_app_purchase: ^3.1.13`

**Products to Create:**
- 6-month package: 10 messages ($X.XX)
- 1-year package: 25 messages ($X.XX)
- Lifetime: Unlimited messages ($X.XX)

**Implementation Steps:**

1. **Add Package:**
```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

2. **Create Products in Play Console:**
   - Go to "Monetize" → "Products" → "In-app products"
   - Create product IDs:
     - `six_month_package`
     - `one_year_package`
     - `lifetime_package`

3. **Implement Purchase Flow:**
```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  Future<void> purchasePackage(String productId) async {
    final ProductDetailsResponse response = await _iap.queryProductDetails({productId});
    final ProductDetails product = response.productDetails.first;
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
  
  Future<void> verifyPurchase(PurchaseDetails purchase) async {
    // Verify with backend
    // Update user's message quota in Firestore
  }
}
```

4. **Backend Verification (Cloud Function):**
```javascript
exports.verifyPurchase = functions.https.onCall(async (data, context) => {
  const { purchaseToken, productId } = data;
  
  // Verify with Google Play API
  const isValid = await verifyWithGoogle(purchaseToken);
  
  if (isValid) {
    // Update user's subscription in Firestore
    await admin.firestore()
      .collection('profiles')
      .doc(context.auth.uid)
      .update({
        subscriptionTier: productId,
        remainingMessages: getMessageCount(productId),
      });
  }
  
  return { success: isValid };
});
```

---

## 10. Testing Checklist

### Before Deployment:
- [ ] All bugs fixed and tested
- [ ] New archetypes working correctly
- [ ] Messages auto-delete after 3 days
- [ ] Local time displays correctly
- [ ] Multiple archetype selection works
- [ ] Theme updated with new colors
- [ ] Instructions updated
- [ ] Android APK builds successfully
- [ ] iOS build works on TestFlight

### User Acceptance Testing:
- [ ] Amy tests all features
- [ ] Beta testers provide feedback
- [ ] Fix any reported issues
- [ ] Final approval from Amy

---

## 11. Deployment Timeline

| Week | Tasks | Status |
|------|-------|--------|
| **Week 1** | Bug fixes (#1-10) | 🔴 Not Started |
| **Week 2** | Archetype updates, Message timing | 🔴 Not Started |
| **Week 3** | Theme updates, Android build | 🔴 Not Started |
| **Week 4** | Store submission, Testing | 🔴 Not Started |

---

## 12. Client Deliverables Needed

### From Amy:
- [ ] New color swatches for theme
- [ ] 400 goal statements (200 per archetype)
- [ ] New instructions text
- [ ] Banner text for forum
- [ ] Apple Developer account access
- [ ] Google Play Console account access
- [ ] App Store metadata (descriptions, screenshots)

---

## 13. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Store rejection | High | Follow guidelines strictly |
| Firebase quota exceeded | Medium | Monitor usage, upgrade plan |
| Bug in production | High | Thorough testing, staged rollout |
| Theme not approved | Low | Quick iteration with Amy |

---

## 14. Post-Launch Monitoring

### Metrics to Track:
- Daily active users
- Goal statement creation rate
- Message send/receive success rate
- Bot notification delivery rate
- Crash reports
- User feedback

### Tools:
- Firebase Analytics
- Firebase Crashlytics
- App Store Connect analytics
- Google Play Console analytics

---

## 15. Future Enhancements (Post-Launch)

- [ ] Apple Sign-In
- [ ] Facebook Sign-In
- [ ] Profile photo upload
- [ ] Direct messaging between users
- [ ] Goal progress tracking
- [ ] Achievement badges
- [ ] Social sharing features
- [ ] Push notifications for new forum posts

---

## Contact & Support

**Developer:** [Your Name]  
**Client:** Amy  
**Project Start:** [Date]  
**Target Launch:** [Date]

---

**Last Updated:** [Current Date]  
**Version:** 1.0
