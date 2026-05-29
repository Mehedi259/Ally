

class UserProfile {
  String id;
  String name;
  String email;
  String? timezone;
  String? gender;
  String? birthday;
  String? education;
  String? profession;
  String? hobbies;
  String? goalStatement;
  DateTime? goalStatementCreatedAt;
  bool onboarded;

  // Internal tracking fields — not shown to the user
  DateTime? creationDate;
  DateTime? updateDate;
  DateTime? subscriptionCancel;
  bool subscriber;
  DateTime? trialEnds;

  // Weekly availability: Map of day name to list of time slots
  // Example: {'Monday': [{'start': '09:00', 'end': '12:00'}]}
  Map<String, List<Map<String, String>>> weeklyAvailability;

  // Bot/archetype settings
  String? selectedArchetype; // null = no bot selected, e.g. 'calm_monk'
  List<String> botDays;      // Days to receive messages, e.g. ['Monday', 'Wednesday']
  String? botTime;           // Time to receive message in 24h format, e.g. '09:00'

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.timezone,
    this.gender,
    this.birthday,
    this.education,
    this.profession,
    this.hobbies,
    this.goalStatement,
    this.goalStatementCreatedAt,
    this.onboarded = false,
    Map<String, List<Map<String, String>>>? weeklyAvailability,
    this.selectedArchetype,
    List<String>? botDays,
    this.botTime,
    this.creationDate,
    this.updateDate,
    this.subscriptionCancel,
    this.subscriber = false,
    this.trialEnds,
  }) : weeklyAvailability = weeklyAvailability ?? {},
       botDays = botDays ?? [];

  /// Create UserProfile from Firestore document
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse weekly availability
    Map<String, List<Map<String, String>>> availability = {};
    if (json['weeklyAvailability'] != null) {
      final availData = json['weeklyAvailability'] as Map<String, dynamic>;
      availData.forEach((day, slots) {
        availability[day] = (slots as List)
            .map((slot) => Map<String, String>.from(slot as Map))
            .toList();
      });
    }

    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      timezone: json['timezone'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      education: json['education'] as String?,
      profession: json['profession'] as String?,
      hobbies: json['hobbies'] as String?,
      goalStatement: json['goalStatement'] as String?,
      goalStatementCreatedAt: json['goalStatementCreatedAt'] != null
          ? DateTime.parse(json['goalStatementCreatedAt'] as String)
          : null,
      onboarded: json['onboarded'] as bool? ?? false,
      weeklyAvailability: availability,
      selectedArchetype: json['selectedArchetype'] as String?,
      botDays: (json['botDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      botTime: json['botTime'] as String?,
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'] as String)
          : null,
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'] as String)
          : null,
      subscriptionCancel: json['subscriptionCancel'] != null
          ? DateTime.parse(json['subscriptionCancel'] as String)
          : null,
      subscriber: json['subscriber'] as bool? ?? false,
      trialEnds: json['trialEnds'] != null
          ? DateTime.parse(json['trialEnds'] as String)
          : null,
    );
  }

  /// Convert UserProfile to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'timezone': timezone,
      'gender': gender,
      'birthday': birthday,
      'education': education,
      'profession': profession,
      'hobbies': hobbies,
      'goalStatement': goalStatement,
      'goalStatementCreatedAt': goalStatementCreatedAt?.toIso8601String(),
      'onboarded': onboarded,
      'weeklyAvailability': weeklyAvailability,
      'selectedArchetype': selectedArchetype,
      'botDays': botDays,
      'botTime': botTime,
      'creationDate': creationDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'subscriptionCancel': subscriptionCancel?.toIso8601String(),
      'subscriber': subscriber,
      'trialEnds': trialEnds?.toIso8601String(),
    };
  }
}

abstract interface class IProfileService {
  Future<UserProfile?> getUserProfile(String token, String userId);
  Future<void> updateUserProfile(String token, UserProfile profile);
}

class CachingProfileService extends IProfileService {
  final IProfileService _delegate;
  final Map<String, UserProfile> _cache = {};
  final Map<String, Future<UserProfile?>> _inFlight = {};

  CachingProfileService(this._delegate);

  @override
  Future<UserProfile?> getUserProfile(String token, String userId) async {
    final cached = _cache[userId];
    if(_cache.containsKey(userId)){
      return Future.value(cached);
    }

    if(_inFlight.containsKey(userId)){
      return _inFlight[userId];
    }

    final profile = _delegate.getUserProfile(token, userId).then((profile){
      _inFlight.remove(userId);
      if(profile != null) {
        _cache[userId] = profile;
      }
      return profile;
    }).catchError((error){
      _inFlight.remove(userId);
      throw error;
    });

    _inFlight[userId] = profile;

    return profile;
  }

  @override
  Future<void> updateUserProfile(String token, UserProfile profile) {
    _cache.remove(profile.id);
    return _delegate.updateUserProfile(token, profile);
  }
}
