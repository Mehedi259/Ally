# Ally By Avea - বাংলা কাজের তালিকা

**প্রজেক্ট:** Ally By Avea অ্যাপ আপডেট  
**ক্লায়েন্ট:** Amy  
**সময়:** ২-৩ সপ্তাহ

---

## 📋 মোট কাজের সংখ্যা: ১৭টি

### 🔴 জরুরি কাজ (১ম সপ্তাহ)
### 🟡 গুরুত্বপূর্ণ কাজ (২য় সপ্তাহ)  
### 🟢 সাধারণ কাজ (৩য় সপ্তাহ)

---

## 🔴 জরুরি বাগ ফিক্স (১-১০ নম্বর)

### ১. Goal Statement Forum-এ দেখা যাচ্ছে না ⚠️

**সমস্যা:** ইউজার প্রোফাইলে goal লিখলেও forum-এ আসছে না।

**কারণ:** Profile save হলে forum-এ sync হচ্ছে না।

**সমাধান:**
- Profile update করার সময় forum-এও save করতে হবে
- যদি goal থাকে → forum-এ post করবে
- যদি goal না থাকে → forum থেকে মুছে দেবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/firebase/firebase_profile_service.dart`
- `lib/firebase/firebase_forum_service.dart`

---

### ২. Goal Delete করলে Forum থেকে মুছছে না ⚠️

**সমস্যা:** Profile থেকে goal মুছলেও forum-এ থেকে যাচ্ছে।

**সমাধান:**
- Goal delete button যোগ করতে হবে
- Delete করলে profile + forum দুই জায়গা থেকেই মুছবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/edit_profile.dart`
- `lib/firebase/firebase_profile_service.dart`

---

### ৩. Forum থেকে ভুল Profile খুলছে ⚠️

**সমস্যা:** Forum post-এ ক্লিক করলে অন্য কারো profile দেখাচ্ছে।

**কারণ:** User ID ভুল pass হচ্ছে।

**সমাধান:**
- সঠিক userId pass করতে হবে navigation-এ

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/post.dart`
- `lib/forum.dart`

---

### ৪. অন্যের Profile-এ Edit Button দেখাচ্ছে ⚠️

**সমস্যা:** অন্যের profile দেখার সময়ও edit button আসছে।

**সমাধান:**
- শুধু নিজের profile-এ edit button দেখাবে
- Current user ID check করতে হবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/view_profile.dart`

---

### ৫. Amy অন্যের Goal Edit করতে পারছে ⚠️

**সমস্যা:** Security issue - যে কেউ যে কারো goal change করতে পারছে।

**সমাধান:**
- Firestore rules update করতে হবে
- শুধু নিজের goal edit করা যাবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `firestore.rules`
- `lib/firebase/firebase_profile_service.dart`

---


## 🎨 UI/UX পরিবর্তন (৬-৮ নম্বর)

### ৬. Reply Button সরাতে হবে ✅

**সমস্যা:** Bot message-এ reply button দেখাচ্ছে।

**সমাধান:**
- Bot message-এ reply button hide করতে হবে
- শুধু user message-এ reply button থাকবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/messaging/messages_screen.dart`

---

### ৭. Robot Icon পরিবর্তন করতে হবে 🎨

**সমস্যা:** এখন robot icon আছে, Groups icon চাই।

**সমাধান:**
- `Icons.smart_toy` এর জায়গায় `Icons.groups` দিতে হবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/edit_profile.dart`

---

### ৮. Forum-এ Banner যোগ করতে হবে 🎨

**সমাধান:**
- Forum-এর উপরে একটা সুন্দর banner যোগ করতে হবে
- Amy banner text দেবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/forum.dart`

---

## 🤖 Archetype System (৯-১১ নম্বর)

### ৯. ২টি নতুন Archetype যোগ করতে হবে

**নতুন Archetype:**
1. **Higher Self** - আধ্যাত্মিক গাইড
2. **Grandmaster of Do Nothing** - জেন মাস্টার

**সমাধান:**
- Firestore-এ ২টি নতুন bot document তৈরি করতে হবে
- Dropdown-এ নতুন option যোগ করতে হবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/bots/bot_seed_data.dart`
- Firestore `bots` collection

---

### ১০. ৪০০টি Goal Statement যোগ করতে হবে 📝

**কাজ:** প্রতিটি নতুন archetype-এর জন্য ২০০টি করে message।

**সমাধান:**
- Amy থেকে ৪০০টি message নিতে হবে
- Firestore-এ upload করতে হবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/bots/bot_seed_data.dart`

---

### ১১. একাধিক Archetype Select করার সুবিধা 🎯

**নতুন ফিচার:** একসাথে অনেকগুলো archetype select করা যাবে।

**কীভাবে কাজ করবে:**
- Multi-select chips UI
- "Select All" button
- প্রতিদিন random archetype থেকে message আসবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/profile/profile_service.dart`
- `lib/edit_profile.dart`
- `lib/firebase/firebase_bot_service.dart`

---

## ⏰ Message System (১২-১৪ নম্বর)

### ১২. ৩ দিন পর Message Auto-Delete

**ফিচার:** Bot message ৭২ ঘণ্টা পর automatically মুছে যাবে।

**সমাধান:**
- Message-এ `expiresAt` field যোগ করতে হবে
- `expiresAt = sentAt + 3 days`
- শুধু active message দেখাবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/messaging/message_service.dart`
- `lib/firebase/firebase_message_service.dart`

---

### ১৩. সর্বোচ্চ ৩টি Message থাকবে 📊

**নিয়ম:** একসাথে ৩টির বেশি bot message থাকবে না।

**সমাধান:**
- নতুন message এলে পুরনো delete হবে
- সবসময় শেষ ৩টি message দেখাবে

---

### ১৪. UTC Time না দেখিয়ে Local Time দেখাতে হবে ⏰

**সমস্যা:** Message time UTC-তে দেখাচ্ছে।

**সমাধান:**
- User-এর timezone অনুযায়ী time convert করতে হবে
- "২ ঘণ্টা আগে" এভাবে দেখাবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/messaging/messages_screen.dart`

---

## 🎨 Theme & Design (১৫-১৬ নম্বর)

### ১৫. Theme Color পরিবর্তন করতে হবে

**সমস্যা:** এখনকার tan theme Amy পছন্দ করছে না।

**সমাধান:**
- Amy নতুন color swatches দেবে
- `lib/themes/dark_purple_theme.dart` file update করতে হবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/themes/dark_purple_theme.dart` (line 246)

**Amy থেকে লাগবে:**
- নতুন color codes

---

### ১৬. Instructions আপডেট করতে হবে 📖

**সমস্যা:** পুরনো instructions আছে।

**সমাধান:**
- Amy নতুন instructions text দেবে
- Welcome page ও onboarding update করতে হবে

**কোন ফাইল পরিবর্তন করতে হবে:**
- `lib/instructions.dart`
- `lib/authentication/onboarding_flow.dart`
- `lib/welcome.dart`

**Amy থেকে লাগবে:**
- নতুন instructions text

---

## 📱 Android Build (১৭ নম্বর)

### ১৭. Android APK তৈরি করতে হবে

**কাজ:** এখন শুধু iOS আছে, Android version বানাতে হবে।

**ধাপসমূহ:**

**১. Signing Key তৈরি:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**২. Build Configuration:**
- `android/app/build.gradle` update করতে হবে
- Signing config যোগ করতে হবে

**৩. APK Build:**
```bash
flutter build apk --release
```

**৪. Google Play Console-এ Upload:**
- Amy-র Google Play account-এ access লাগবে
- APK upload করতে হবে
- App details fill করতে হবে

---

## 🍎 iOS App Store (বোনাস)

### iOS App Transfer করতে হবে

**কাজ:** Amy-র Apple Developer account-এ transfer করতে হবে।

**ধাপসমূহ:**

**১. Bundle ID পরিবর্তন:**
- নতুন Bundle ID: Amy দেবে
- Xcode-এ update করতে হবে

**২. TestFlight Setup:**
- Build upload করতে হবে
- Beta testing setup করতে হবে

**৩. App Store Submission:**
- Screenshots তৈরি করতে হবে
- App description লিখতে হবে
- Submit করতে হবে

---

## ✅ Amy থেকে যা যা লাগবে

### অবশ্যই লাগবে:
- [ ] নতুন color swatches (theme-এর জন্য)
- [ ] ৪০০টি goal statements (২০০ × ২)
- [ ] নতুন instructions text
- [ ] Forum banner text
- [ ] Apple Developer account access
- [ ] Google Play Console account access

---

## 📅 সময়সূচী

| সপ্তাহ | কাজ | সময় |
|--------|-----|------|
| **১ম সপ্তাহ** | Bug fixes (১-৫) | ৩-৫ দিন |
| **২য় সপ্তাহ** | Archetype + Message (৯-১৪) | ৫-৭ দিন |
| **৩য় সপ্তাহ** | Theme + Android (১৫-১৭) | ৩-৪ দিন |
| **৪র্থ সপ্তাহ** | Testing + Store submission | ২-৩ দিন |

**মোট সময়:** ২-৩ সপ্তাহ

---

## 🎯 কাজের ক্রম (Priority অনুযায়ী)

### প্রথমে করতে হবে (সবচেয়ে জরুরি):
1. ✅ Goal Statement forum sync (১ নম্বর)
2. ✅ Goal delete করলে forum থেকে মুছা (২ নম্বর)
3. ✅ ভুল profile খোলার সমস্যা (৩ নম্বর)
4. ✅ Edit button security (৪-৫ নম্বর)

### তারপর করতে হবে:
5. ✅ Reply button সরানো (৬ নম্বর)
6. ✅ ২টি নতুন archetype (৯-১০ নম্বর)
7. ✅ Message timing (১২-১৪ নম্বর)
8. ✅ Multiple archetype selection (১১ নম্বর)

### শেষে করতে হবে:
9. ✅ Theme update (১৫ নম্বর)
10. ✅ Instructions update (১৬ নম্বর)
11. ✅ Android build (১৭ নম্বর)

---

## 🧪 Testing Checklist

### প্রতিটি কাজ শেষে test করতে হবে:

**Bug Fixes:**
- [ ] Goal statement লিখলে forum-এ দেখা যাচ্ছে কিনা
- [ ] Goal delete করলে forum থেকে মুছছে কিনা
- [ ] Forum থেকে সঠিক profile খুলছে কিনা
- [ ] শুধু নিজের profile-এ edit button দেখাচ্ছে কিনা

**Archetype:**
- [ ] নতুন ২টি archetype dropdown-এ আছে কিনা
- [ ] Multiple archetype select করা যাচ্ছে কিনা
- [ ] প্রতিদিন random message আসছে কিনা

**Messages:**
- [ ] ৩ দিন পর message মুছে যাচ্ছে কিনা
- [ ] সর্বোচ্চ ৩টি message দেখাচ্ছে কিনা
- [ ] Local time সঠিকভাবে দেখাচ্ছে কিনা
- [ ] Bot message-এ reply button নেই কিনা

**UI:**
- [ ] নতুন theme সুন্দর দেখাচ্ছে কিনা
- [ ] Forum banner ঠিকমতো দেখাচ্ছে কিনা
- [ ] Groups icon দেখাচ্ছে কিনা

**Build:**
- [ ] Android APK তৈরি হচ্ছে কিনা
- [ ] App install হচ্ছে কিনা
- [ ] সব feature কাজ করছে কিনা

---

## 📞 যোগাযোগ

**Developer:** [আপনার নাম]  
**Client:** Amy  
**শুরুর তারিখ:** [তারিখ]  
**শেষ করার লক্ষ্য:** [তারিখ]

---

## 💡 গুরুত্বপূর্ণ নোট

### মনে রাখবেন:
1. **প্রতিটি কাজ শেষে test করবেন**
2. **Code commit করার আগে review করবেন**
3. **Amy-কে regular update দেবেন**
4. **সমস্যা হলে documentation check করবেন**
5. **Backup রাখবেন সবসময়**

### কাজ শুরু করার আগে:
- [ ] এই পুরো document পড়ুন
- [ ] Amy থেকে সব deliverables collect করুন
- [ ] Development environment setup করুন
- [ ] Git branch তৈরি করুন

### কাজ শেষ হলে:
- [ ] সব testing complete করুন
- [ ] Amy-কে demo দিন
- [ ] Feedback নিন এবং fix করুন
- [ ] Final approval নিন
- [ ] Store-এ submit করুন

---

**শুভকামনা! 🚀**

আপনি পারবেন! প্রতিটি কাজ ধাপে ধাপে করুন, তাড়াহুড়ো করবেন না। 

কোনো সমস্যা হলে এই document-এ ফিরে আসুন।
