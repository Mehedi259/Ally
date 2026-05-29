import 'package:exploration_project/messaging/message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exploration_project/bots/bot_seed_data.dart';
import 'package:exploration_project/bots/bot_service.dart';
import 'package:exploration_project/service_locator.dart';

class FirebaseMessageService implements IMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'messages';

  @override
  Future<List<Message>> getMessages(String token, String userId) async {
    userId = ServiceLocator.getLoggedInUserId();
    print('Fetching messages for userId: $userId');
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7)).toIso8601String();
      final snapshot = await _firestore
          .collection(_collection)
          .where('recipientId', isEqualTo: userId)
          .where('sentAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .where('sentAt', isLessThanOrEqualTo: now.toIso8601String())
          .get();

      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String token, Message message) async {
    try {
      await _firestore.collection(_collection).add(message.toJson());
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  @override
  UserMessageQuota getUserQuota(String token, String userId) {
    // Stub: return a default quota allowing 10 messages
    return UserMessageQuota(
      totalMessages: 10,
      usedMessages: 0,
      subscriptionTier: 'free',
    );
  }
  
  @override
  Future<void> purchaseMessages(String token, String userId, String packageId) {
    // TODO: implement purchaseMessages
    throw UnimplementedError();
  }

  @override
  Future<List<Message>> getReceivedMessages(String token, String userId) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7)).toIso8601String();
      final snapshot = await _firestore
          .collection(_collection)
          .where('recipientId', isEqualTo: ServiceLocator.getLoggedInUserId())
          .where('sentAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .where('sentAt', isLessThanOrEqualTo: now.toIso8601String())
          .orderBy('sentAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching received messages: $e');
      return [];
    }
  }

  @override
  Future<void> writeBotMessages(
    String botSenderId,
    String recipientId,
    List<({DateTime scheduledAt, String content})> schedule,
  ) async {
    try {
      final batch = _firestore.batch();
      for (final entry in schedule) {
        final id = '${botSenderId}_${recipientId}_${entry.scheduledAt.millisecondsSinceEpoch}';
        final ref = _firestore.collection(_collection).doc(id);
        batch.set(ref, Message(
          id: id,
          senderId: botSenderId,
          recipientId: recipientId,
          content: entry.content,
          sentAt: entry.scheduledAt,
        ).toJson());
      }
      await batch.commit();
      print('Wrote ${schedule.length} bot messages to Firestore.');
    } catch (e) {
      print('Error writing bot messages: $e');
    }
  }

  @override
  Future<void> cancelFutureBotMessages(String userId) async {
    try {
      final botIds = BotSeedData.archetypes
          .map((a) => BotSenderHelper.senderIdForArchetype(a.id))
          .toSet();
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection(_collection)
          .where('recipientId', isEqualTo: userId)
          .get();

      final toDelete = snapshot.docs.where((doc) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        final sentAt = DateTime.tryParse(data['sentAt'] as String? ?? '');
        return botIds.contains(senderId) && sentAt != null && sentAt.isAfter(now);
      }).toList();

      if (toDelete.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in toDelete) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('Cancelled ${toDelete.length} future bot messages.');
    } catch (e) {
      print('Error cancelling future bot messages: $e');
    }
  }

  @override
  Future<List<Message>> getSentMessages(String token, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('senderId', isEqualTo: ServiceLocator.getLoggedInUserId())
          .orderBy('sentAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching sent messages: $e');
      return [];
    }
  }
}
