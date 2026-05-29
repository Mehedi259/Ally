import 'package:exploration_project/firebase/firebase_message_service.dart';
import 'package:exploration_project/notifications/local_notifications_service.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:flutter/material.dart';

import 'authentication/auth_service.dart';
import 'bots/bot_service.dart';
import 'forum/forum_service.dart';
import 'messaging/message_service.dart';
import 'profile/profile_service.dart';
import 'firebase/firebase_bot_service.dart';
import 'firebase/firebase_profile_service.dart';
import 'firebase/firebase_forum_service.dart';

class ServiceLocator {
  static IAuthService? _authService;
  static IProfileService? _profileService;
  static IForumService? _forumService;
  static IMessageService? _messageService;
  static LocalNotificationsService? _localNotificationsService;
  static IBotService? _botService;
  
  static IAuthService get authService {
    _authService ??= FirebaseAuthService();
    return _authService!;
  }
  
  static IProfileService get profileService {
    _profileService ??= FirebaseProfileService();
    return _profileService!;
  }

  static IForumService get forumService {
    _forumService ??= FirebaseForumService();
    return _forumService!;
  }
  
  static IMessageService get messageService {
    _messageService ??= FirebaseMessageService();
    return _messageService!;
  }

  static LocalNotificationsService get localNotificationsService {
    _localNotificationsService ??= LocalNotificationsService.instance();
    _localNotificationsService?.init();
    return _localNotificationsService!;
  }

  static IBotService get botService {
    _botService ??= CachingBotService(FirebaseBotService());
    return _botService!;
  }

  static String getLoggedInUserId() {
    final user = authService.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user is currently logged in');
    }
  }
}
