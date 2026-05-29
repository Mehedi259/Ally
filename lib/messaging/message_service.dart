class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
    };
  }
}

class UserMessageQuota {
  final int totalMessages;
  final int usedMessages;
  final String subscriptionTier;

  UserMessageQuota({
    required this.totalMessages,
    required this.usedMessages,
    required this.subscriptionTier,
  });

  int get remainingMessages => totalMessages - usedMessages;
  bool get hasMessagesRemaining => remainingMessages > 0;
}

//////////////////////////////////////////////////////////////////////////////
///  Message Service Interface
/// //////////////////////////////////////////////////////////////////////////
abstract interface class IMessageService {
  Future<void> sendMessage(String token, Message message);
  UserMessageQuota getUserQuota(String token, String userId);
  Future<List<Message>> getMessages(String token, String userId);
  Future<List<Message>> getReceivedMessages(String token, String userId);
  Future<List<Message>> getSentMessages(String token, String userId);
  Future<void> purchaseMessages(String token, String userId, String packageId);
  Future<void> writeBotMessages(
    String botSenderId,
    String recipientId,
    List<({DateTime scheduledAt, String content})> schedule,
  );
  Future<void> cancelFutureBotMessages(String userId);
}

//////////////////////////////////////////////////////////////////////////////
///  Message Service Implementation
//////////////////////////////////////////////////////////////////////////////

/// A mock implementation of the Message Service. In a real-world scenario, this would
/// interact with a backend server to send messages and manage quotas.
class MessageService implements IMessageService {

  int shortFrquency = 1;
  int longFrequency = 3;

  // Mock storage for user quotas
  final Map<String, UserMessageQuota> _userQuotas = {};

  @override
  Future<void> sendMessage(String token, Message message) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));

    // In a real implementation, this would send to a backend
    print(
      "Message sent from ${message.senderId} to ${message.recipientId}: ${message.content}",
    );

    // Update user quota
    if (_userQuotas.containsKey(message.senderId)) {
      final currentQuota = _userQuotas[message.senderId]!;
      _userQuotas[message.senderId] = UserMessageQuota(
        totalMessages: currentQuota.totalMessages,
        usedMessages: currentQuota.usedMessages + 1,
        subscriptionTier: currentQuota.subscriptionTier,
      );
    }
  }

  @override
  UserMessageQuota getUserQuota(String token, String userId) {
    // Return existing quota or create default free trial quota
    if (!_userQuotas.containsKey(userId)) {
      _userQuotas[userId] = UserMessageQuota(
        totalMessages: 3,
        usedMessages: 0,
        subscriptionTier: 'free_trial',
      );
    }
    return _userQuotas[userId]!;
  }

  @override
  Future<void> purchaseMessages(
    String token,
    String userId,
    String packageId,
  ) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));

    // Mock purchase logic - in reality this would involve payment processing
    int newTotal = 10; // 6-month package with 10 messages
    if (packageId == '6_month_package') {
      newTotal = 10;
    }

    _userQuotas[userId] = UserMessageQuota(
      totalMessages: newTotal,
      usedMessages: 0,
      subscriptionTier: '6_month',
    );

    print("User $userId purchased package $packageId");
  }
  
  @override
  Future<List<Message>> getMessages(String token, String userId) {
    // TODO: implement getMessages
    throw UnimplementedError();
  }

  @override
  Future<List<Message>> getReceivedMessages(String token, String userId) async {
    // Mock: return empty list for now
    return [];
  }

  @override
  Future<List<Message>> getSentMessages(String token, String userId) async {
    // Mock: return empty list for now
    return [];
  }

  @override
  Future<void> writeBotMessages(
    String botSenderId,
    String recipientId,
    List<({DateTime scheduledAt, String content})> schedule,
  ) async {}

  @override
  Future<void> cancelFutureBotMessages(String userId) async {}
}
