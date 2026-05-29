import 'package:exploration_project/forum/forum_service.dart';
import 'package:exploration_project/notifications/local_notifications_service.dart';
import 'package:flutter/material.dart';
import 'service_locator.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'view_profile.dart';
import 'post.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  final IForumService _forumService = ServiceLocator.forumService;
  late Future<List<ForumPost>?> _postsFuture;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  bool get _isSearchActive => _searchQuery.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _postsFuture = _forumService.getAllPosts("dummy_token");
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _forumService.getAllPosts("dummy_token");
    });
    await _postsFuture;
  }

  Widget _buildSearchBar() {
    return Container(
      color: AveaThemes.current().primarySwatch,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search goal statements...',
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search, color: Colors.white60),
          suffixIcon: _isSearchActive
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white30),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AveaThemes.current().cardLighterBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SkeletonBar(width: 180, height: 16),
              SizedBox(height: 10),
              _SkeletonBar(width: double.infinity, height: 12),
              SizedBox(height: 6),
              _SkeletonBar(width: 220, height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AveaThemes.current().backgroundColor,
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<ForumPost>?>(
              future: _postsFuture,
              builder: (context, snapshot) {
                Widget listBody;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  listBody = _buildSkeletonList();
                } else if (snapshot.hasError) {
                  listBody = ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          "Failed to load forum posts.",
                          style: TextStyle(color: AveaThemes.current().textColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Pull down to retry.",
                          style: TextStyle(color: AveaThemes.current().secondaryTextColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton(
                          onPressed: _refreshPosts,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AveaThemes.current().textColor,
                            side: BorderSide(color: AveaThemes.current().secondaryTextColor),
                          ),
                          child: const Text("Retry"),
                        ),
                      ),
                    ],
                  );
                } else {
                  final posts = snapshot.data ?? [];

                  final filteredPosts = _searchQuery.isEmpty
                      ? posts
                      : posts
                          .where((p) =>
                              p.content
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              p.title
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (posts.isEmpty) {
                    listBody = ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            "No posts yet.",
                            style: TextStyle(color: AveaThemes.current().textColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Pull down to refresh.",
                            style: TextStyle(color: AveaThemes.current().secondaryTextColor),
                          ),
                        ),
                      ],
                    );
                  } else {
                    final postWidgets = filteredPosts.indexed.map((element) {
                      final index = element.$1;
                      final post = element.$2;
                      final colorIndex = index % AveaThemes.current().postTextColors.length;
                      final textColor = AveaThemes.current().postTextColors[colorIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Post2(
                          title: post.title,
                          content: post.content,
                          createdAt: post.createdAt,
                          userId: post.userId,
                          textColor: textColor,
                        ),
                      );
                    }).toList();

                    listBody = ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 8),
                        if (filteredPosts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 40),
                            child: Center(
                              child: Text(
                                'No results for "$_searchQuery"',
                                style: TextStyle(
                                    color: AveaThemes.current().secondaryTextColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...postWidgets,
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                }

                return RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: listBody,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AveaThemes.current().cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class GoalPostCard extends StatelessWidget {
  final ForumPost post;
  final Color textColor;

  const GoalPostCard({
    Key? key,
    required this.post,
    required this.textColor,
  }) : super(key: key);

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AveaThemes.current().cardLighterBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text("${post.userName}'s Profile"),
                  backgroundColor: const Color.fromARGB(255, 160, 126, 219),
                ),
                body: ViewProfile(
                  currentUserId: 'current_user_id',
                  userId: post.userId,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AveaThemes.current().primarySwatch.withValues(alpha: 0.2),
                    child: Text(
                      post.userName.isNotEmpty
                          ? post.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AveaThemes.current().primarySwatch,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(post.createdAt),
                          style: TextStyle(
                            color: AveaThemes.current().secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AveaThemes.current().secondaryTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AveaThemes.current().primarySwatch.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AveaThemes.current().primarySwatch.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  post.content,
                  style: TextStyle(
                    color: AveaThemes.current().textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 16,
                        color: AveaThemes.current().primarySwatch,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Goal Statement',
                        style: TextStyle(
                          color: AveaThemes.current().primarySwatch,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Tap to view profile',
                    style: TextStyle(
                      color: AveaThemes.current().secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
