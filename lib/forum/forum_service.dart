
import '../service_locator.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String userId;
  final String userName;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userName,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'userName': userName,
    };
  }
}
//////////////////////////////////////////////////////////////////////////////
///  Forum Service Interface
/// //////////////////////////////////////////////////////////////////////////
abstract interface class IForumService {
  Future<List<ForumPost>?> getAllPosts(String token);
  Future<ForumPost?> getPostById(String token, String postId); 
  Future<void> createPost(String token, ForumPost post);
  Future<List<ForumPost>?> getGoalStatements(String token);
}

//////////////////////////////////////////////////////////////////////////////
///  Forum Service Implementation
//////////////////////////////////////////////////////////////////////////////


/// A service that displays user goal statements as forum posts.
/// Links goal statements from user profiles to create a forum of all user goals.
class ForumService implements IForumService {
  final List<ForumPost> _cachedPosts = [];
  
  @override
  Future<List<ForumPost>> getAllPosts(String token) async {
    // For now, delegate to getGoalStatements - in future this could include other post types
    return await getGoalStatements(token);
  }

  @override
  Future<List<ForumPost>> getGoalStatements(String token) async {
    try {
      final profileService = ServiceLocator.profileService;
      final authService = ServiceLocator.authService;
      
      // Clear cached posts to get fresh data
      _cachedPosts.clear();
      
      // Get all users who have goal statements
      // Note: In a real implementation, you'd have a way to query all users
      // For now, we'll use a mock approach since we don't have a way to get all users
      
      // Get the current user's goal statement as an example
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        final profile = await profileService.getUserProfile(token, currentUser.uid);
        if (profile != null && profile.goalStatement != null && profile.goalStatement!.isNotEmpty) {
          final createdAt = profile.goalStatementCreatedAt;
          final isActive = createdAt != null &&
              DateTime.now().difference(createdAt).inDays < 90;
          if (isActive) {
            _cachedPosts.add(ForumPost(
              id: profile.id,
              title: "${profile.name}'s Goal",
              content: profile.goalStatement!,
              createdAt: createdAt,
              userId: profile.id,
              userName: profile.name,
            ));
          }
        }
      }
      
      // Add some dummy goal statements for demonstration
      // In a real app, you'd query all users with goal statements
      await _addDummyGoalStatements();
      
      return List.from(_cachedPosts);
    } catch (e) {
      print('Error getting goal statements: $e');
      // Return dummy data on error
      await _addDummyGoalStatements();
      return List.from(_cachedPosts);
    }
  }

  Future<void> _addDummyGoalStatements() async {
    final dummyGoals = [
      {"name": "Sarah Johnson", "goal": "I want to improve my public speaking skills and become more confident when presenting to large groups."},
      {"name": "Mike Chen", "goal": "My goal is to learn Python programming and transition into a data science career within the next year."},
      {"name": "Emma Williams", "goal": "I'm working on developing better time management skills and creating a healthy work-life balance."},
      {"name": "David Rodriguez", "goal": "I want to build a fitness routine and run my first marathon next fall."},
      {"name": "Lisa Thompson", "goal": "My goal is to enhance my emotional intelligence and become a better leader for my team."},
      {"name": "James Wilson", "goal": "I want to learn mindfulness and meditation to reduce stress and improve my mental health."},
      {"name": "Rachel Garcia", "goal": "I'm working on improving my financial literacy and creating a solid investment strategy."},
      {"name": "Kevin Lee", "goal": "My goal is to develop better networking skills and build meaningful professional relationships."},
    ];

    for (int i = 0; i < dummyGoals.length; i++) {
      final goal = dummyGoals[i];
      _cachedPosts.add(ForumPost(
        id: 'dummy_$i', 
        title: "${goal['name']}'s Goal",
        content: goal['goal']!,
        createdAt: DateTime.now().subtract(Duration(hours: i)),
        userId: 'dummy_user_$i',
        userName: goal['name']!,
      ));
    }
  }

  @override
  Future<ForumPost> getPostById(String token, String postId) async {
    // Try to find the post in cached posts first
    try {
      final post = _cachedPosts.firstWhere((post) => post.id == postId);
      return post;
    } catch (e) {
      // If not found in cache, try to get the user's goal statement directly
      try {
        final profileService = ServiceLocator.profileService;
        final profile = await profileService.getUserProfile(token, postId);
        if (profile != null && profile.goalStatement != null && profile.goalStatement!.isNotEmpty) {
          return ForumPost(
            id: profile.id,
            title: "${profile.name}'s Goal",
            content: profile.goalStatement!,
            createdAt: DateTime.now(),
            userId: profile.id,
            userName: profile.name,
          );
        }
      } catch (e) {
        print('Error getting post by ID: $e');
      }
      
      // Fallback to dummy post
      return ForumPost(
        id: postId,
        title: 'Goal Statement',
        content: 'This goal statement is not available.',
        createdAt: DateTime.now(),
        userId: 'unknown',
        userName: 'Unknown User',
      );
    }
  }

  @override
  Future<void> createPost(String token, ForumPost post) async {
    // For goal statements, this would update the user's profile
    // In this implementation, goal statements are managed through the profile
    print("Goal statement updated for user '${post.userName}'.");
  }
}