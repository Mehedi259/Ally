class BotArchetype {
  final String id;
  final String displayName;
  final String description;
  final List<String> messages;

  const BotArchetype({
    required this.id,
    required this.displayName,
    required this.description,
    required this.messages,
  });

  factory BotArchetype.fromJson(Map<String, dynamic> json) {
    return BotArchetype(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'description': description,
      'messages': messages,
    };
  }
}

abstract interface class IBotService {
  Future<List<BotArchetype>> getAllArchetypes();
  Future<BotArchetype?> getArchetype(String id);
  Future<void> activateBot(dynamic profile, BotArchetype archetype);
  Future<void> deactivateBot(String userId);
}

class CachingBotService implements IBotService {
  static const Duration _ttl = Duration(hours: 12);

  final IBotService _delegate;

  List<BotArchetype>? _cachedAll;
  DateTime? _cachedAt;
  Future<List<BotArchetype>>? _allInFlight;

  CachingBotService(this._delegate);

  bool get _isFresh =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _ttl;

  @override
  Future<List<BotArchetype>> getAllArchetypes() {
    if (_isFresh) return Future.value(_cachedAll);

    _allInFlight ??= _delegate.getAllArchetypes().then((archetypes) {
      _cachedAll = archetypes;
      _cachedAt = DateTime.now();
      _allInFlight = null;
      return archetypes;
    }).catchError((error) {
      _allInFlight = null;
      throw error;
    });

    return _allInFlight!;
  }

  @override
  Future<BotArchetype?> getArchetype(String id) async {
    if (_isFresh) {
      return _cachedAll!.where((a) => a.id == id).firstOrNull;
    }
    final all = await getAllArchetypes();
    return all.where((a) => a.id == id).firstOrNull;
  }

  @override
  Future<void> activateBot(dynamic profile, BotArchetype archetype) =>
      _delegate.activateBot(profile, archetype);

  @override
  Future<void> deactivateBot(String userId) => _delegate.deactivateBot(userId);
}

/// Helpers for identifying bot senders in the messaging system.
class BotSenderHelper {
  static const String _botPrefix = 'bot_';

  static String senderIdForArchetype(String archetypeId) => '$_botPrefix$archetypeId';

  static bool isBotSenderId(String senderId) => senderId.startsWith(_botPrefix);

  static const Map<String, String> _displayNames = {
    'calm_monk': 'Calm Monk',
    'champion_coach': 'Champion Coach',
    'drill_sergeant': 'Drill Sergeant',
    'gentle_guide_bestie': 'Gentle Guide Bestie',
    'mindful_millionaire': 'Mindful Millionaire',
    'observational_comedian': 'Observational Comedian',
    'stoic_mentor': 'Stoic Mentor',
    'boardroom_ceo': 'Boardroom CEO',
    'voice_of_enough': 'The Voice of Enough',
    'the_steward': 'The Steward',
  };

  /// Returns the archetype display name for a bot senderId, or null if not a bot.
  static String? displayNameForSenderId(String senderId) {
    if (!isBotSenderId(senderId)) return null;
    final archetypeId = senderId.substring(_botPrefix.length);
    return _displayNames[archetypeId] ?? 'Your Ally Bot';
  }
}
