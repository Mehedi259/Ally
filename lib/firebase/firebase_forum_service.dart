import 'package:exploration_project/forum/forum_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseForumService implements IForumService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ForumPost>?> getAllPosts(String token) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 90)).toIso8601String();
      final snapshot = await _firestore
          .collection('profiles')
          .where('goalStatementCreatedAt', isGreaterThanOrEqualTo: cutoff)
          .get();

      print(snapshot.docs.length);
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final goalStatement = data['goalStatement'] as String?;
            if (goalStatement == null || goalStatement.isEmpty) return null;
            return ForumPost(
              id: doc.id,
              title: "${data['name']}'s Goal",
              content: goalStatement,
              createdAt: DateTime.parse(data['goalStatementCreatedAt'] as String),
              userId: doc.id,
              userName: data['name'] as String? ?? 'Unknown',
            );
          })
          .whereType<ForumPost>()
          .toList();
    } catch (e) {
      return [];
    }
  }


  @override
  Future<ForumPost?> getPostById(String token, String postId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(postId).get();
      if(!doc.exists){
        return null;
      }

      final data = doc.data()!;
      final goalStatement = data['goalStatement'] as String?;
      if (goalStatement == null || goalStatement.isEmpty) return null;
      return ForumPost(
        id: doc.id,
        title: "${data['name']}'s Goal",
        content: goalStatement,
        createdAt: DateTime.parse(data['goalStatementCreatedAt'] as String),
        userId: doc.id,
        userName: data['name'] as String? ?? 'Unknown',
      );
    } catch (e){
      print("Error fetching forum post: $e");
      rethrow;
    }
  }

  @override
  Future<void> createPost(String token, ForumPost post) async {
    // Goal statements are managed through the profile service, not created here
  }

  @override
  Future<List<ForumPost>?> getGoalStatements(String token) async {
    return await getAllPosts(token);
  }
}
