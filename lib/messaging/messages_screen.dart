import 'dart:async';

import 'package:flutter/material.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:exploration_project/bots/bot_service.dart';
import 'package:exploration_project/service_locator.dart';
import 'package:exploration_project/profile/profile_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:flutter_beep/flutter_beep.dart';  // Disabled due to Android namespace issues
import 'message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const _autoRefreshInterval = Duration(seconds: 30);
  
  bool _showingSent = false;
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _autoRefreshTimer;
  
  // Cache for user profiles (to display sender/recipient names)
  final Map<String, UserProfile?> _profileCache = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      if (mounted && !_isLoading) {
        _loadMessages();
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = ServiceLocator.authService.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "Not logged in";
          _isLoading = false;
        });
        return;
      }

      final messageService = ServiceLocator.messageService;
      final messages = _showingSent
          ? await messageService.getSentMessages('token', user.uid)
          : await messageService.getReceivedMessages('token', user.uid);

      // Pre-fetch profiles for all senders/recipients
      final userIds = _showingSent
          ? messages.map((m) => m.recipientId).toSet()
          : messages.map((m) => m.senderId).toSet();

      for (final userId in userIds) {
        if (!_profileCache.containsKey(userId)) {
          try {
            final profile = await ServiceLocator.profileService.getUserProfile(
              'token',
              userId,
            );
            _profileCache[userId] = profile;
          } catch (_) {
            _profileCache[userId] = null;
          }
        }
      }

      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load messages";
        _isLoading = false;
      });
    }
  }

  void _toggleView() {
    setState(() {
      _showingSent = !_showingSent;
    });
    _loadMessages();
  }

  String _getUserName(String userId) {
    // Bot senders resolve immediately without a profile lookup
    final botName = BotSenderHelper.displayNameForSenderId(userId);
    if (botName != null) return botName;

    final cachedProfile = _profileCache[userId];
    if (cachedProfile != null) {
      return cachedProfile.name;
    }

    /* If the user's profile isn't in the cache, then we need to fetch it
       asynchronously.   That means returning a dummy value for now and
       notifying the widget once its complete.
     */
    _fetchProfileData(userId);
    return "Unknown User";
  }

  void  _fetchProfileData(String userId) async {
    UserProfile? profile = await ServiceLocator.profileService.getUserProfile(
        'Dummy Token',
        userId
    );
    _profileCache[userId] = profile;
    setState((){});
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openMessageDetail(Message message) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageDetailScreen(
          message: message,
          senderName:   _getUserName(message.senderId),
          recipientName: _getUserName(message.recipientId),
          isSentMessage: _showingSent,
        ),
      ),
    ).then((_) => _loadMessages()); // Refresh after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showingSent ? 'Sent Messages' : 'Received Messages'),
        backgroundColor: AveaThemes.current().primarySwatch,
        actions: [
          IconButton(
            icon: Icon(_showingSent ? Icons.inbox : Icons.outbox),
            tooltip: _showingSent ? 'View Received' : 'View Sent',
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Container(
        color: AveaThemes.current().backgroundColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AveaThemes.current().primarySwatch),
      );
    }

    if (_errorMessage != null) {
      return RefreshIndicator(
        onRefresh: _loadMessages,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: AveaThemes.current().textColor),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _loadMessages,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AveaThemes.current().textColor,
                      side: BorderSide(color: AveaThemes.current().secondaryTextColor),
                    ),
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(color: AveaThemes.current().secondaryTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMessages,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showingSent ? Icons.outbox : Icons.inbox,
                    size: 64,
                    color: AveaThemes.current().secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showingSent ? 'No sent messages' : 'No messages received',
                    style:TextStyle(
                      color: AveaThemes.current().textColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showingSent
                        ? 'Messages you send will appear here'
                        : 'Messages sent to you will appear here',
                    style: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(color: AveaThemes.current().secondaryTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final message = _messages[index];
          final otherUserId = _showingSent ? message.recipientId : message.senderId;
          final otherUserName = _getUserName(otherUserId);

          return GestureDetector(
            onTap: () => _openMessageDetail(message),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AveaThemes.current().cardLighterBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _showingSent ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: _showingSent ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showingSent ? 'To: $otherUserName' : 'From: $otherUserName',
                            style: TextStyle(
                              color: AveaThemes.current().textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(message.sentAt),
                        style: TextStyle(
                          color: AveaThemes.current().secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.content,
                    style: TextStyle(color: AveaThemes.current().textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessageDetailScreen extends StatefulWidget {
  final Message message;
  final String senderName;
  final String recipientName;
  final bool isSentMessage;

  const MessageDetailScreen({
    super.key,
    required this.message,
    required this.senderName,
    required this.recipientName,
    required this.isSentMessage,
  });

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final PanelController _panelController = PanelController();
  final int _maxCharacters = 150;
  bool _isSending = false;
  UserMessageQuota? _userQuota;
  bool _showSuccessBanner = false;

  @override
  void initState() {
    super.initState();
    _loadUserQuota();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _loadUserQuota() {
    final user = ServiceLocator.authService.currentUser;
    if (user == null) return;
    
    final messageService = ServiceLocator.messageService;
    setState(() {
      _userQuota = messageService.getUserQuota('token', user.uid);
    });
  }

  Future<void> _sendReply() async {
    if (_replyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    if (_userQuota == null || !_userQuota!.hasMessagesRemaining) {
      _showPurchaseDialog();
      return;
    }

    setState(() => _isSending = true);

    try {
      final user = ServiceLocator.authService.currentUser;
      if (user == null) throw Exception('Not logged in');

      final messageService = ServiceLocator.messageService;
      final reply = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: user.uid,
        recipientId: widget.message.senderId,
        content: _replyController.text,
        sentAt: DateTime.now(),
      );

      await messageService.sendMessage('token', reply);
      _replyController.clear();
      _loadUserQuota();

      // Close the panel
      if (_panelController.isPanelOpen) {
        await _panelController.close();
      }

      // Play system success sound (disabled due to package issues)
      // try {
      //   FlutterBeep.beep();
      // } catch (soundError) {
      //   debugPrint('Could not play sound: $soundError');
      // }

      // Show success banner
      setState(() {
        _showSuccessBanner = true;
      });

      // Hide banner after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessBanner = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reply'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Messages Remaining'),
        content: const Text(
          'You\'ve used all your messages. Purchase more messages to continue connecting with others.\n\n'
          '\$5.99 for 6 months includes 10 messages',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseMessages();
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseMessages() async {
    final user = ServiceLocator.authService.currentUser;
    if (user == null) return;

    final messageService = ServiceLocator.messageService;

    try {
      await messageService.purchaseMessages('token', user.uid, '6_month_package');
      _loadUserQuota();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Messages purchased successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Whether this message is from a bot archetype (no reply allowed)
  bool get _isBotMessage => BotSenderHelper.isBotSenderId(widget.message.senderId);

  Widget _buildBodyForReceived() {
    if (_isBotMessage) {
      // For bot messages: no reply panel, just the content
      return _buildMessageContent();
    }
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height * 0.7,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      panel: _buildReplyPanel(),
      body: _buildMessageContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSentMessage
            ? 'To: ${widget.recipientName}'
            : 'From: ${widget.senderName}'),
        backgroundColor: AveaThemes.current().primarySwatch,
      ),
      body: Stack(
        children: [
          // Main content with SlidingUpPanel (only for non-bot received messages)
          if (!widget.isSentMessage)
            _buildBodyForReceived()
          else
            _buildMessageContent(),
          // Success Banner
          if (_showSuccessBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Reply sent successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Reply FAB (only for non-bot received messages)
      floatingActionButton: (!widget.isSentMessage && !_isBotMessage)
          ? FloatingActionButton.extended(
              onPressed: () => _panelController.open(),
              backgroundColor: AveaThemes.current().primarySwatch,
              icon: const Icon(Icons.reply),
              label: const Text('Reply'),
            )
          : null,
    );
  }

  Widget _buildReplyPanel() {
    final remainingChars = _maxCharacters - _replyController.text.length;

    return Container(
      decoration: BoxDecoration(
        color: AveaThemes.current().cardBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AveaThemes.current().secondaryTextColor.withAlpha(128),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Reply to Message',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AveaThemes.current().textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Replying to ${widget.senderName} (150 character limit)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AveaThemes.current().secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Message Quota Display
                  if (_userQuota != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _userQuota!.hasMessagesRemaining
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _userQuota!.hasMessagesRemaining
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _userQuota!.hasMessagesRemaining
                                ? Icons.check_circle
                                : Icons.warning,
                            color: _userQuota!.hasMessagesRemaining
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Messages Remaining: ${_userQuota!.remainingMessages}/${_userQuota!.totalMessages}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (!_userQuota!.hasMessagesRemaining)
                            TextButton(
                              onPressed: _showPurchaseDialog,
                              child: const Text('Buy More'),
                            ),
                        ],
                      ),
                    ),
                  // Message Input
                  TextField(
                    controller: _replyController,
                    maxLength: _maxCharacters,
                    minLines: 1,
                    maxLines: null,
                    style: TextStyle(color: AveaThemes.current().textColor),
                    decoration: InputDecoration(
                      hintText: 'Type your reply here...',
                      hintStyle: TextStyle(
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                      filled: true,
                      fillColor: AveaThemes.current().cardLighterBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '$remainingChars characters remaining',
                      counterStyle: TextStyle(
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update character count
                    },
                  ),
                  const SizedBox(height: 20),
                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendReply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AveaThemes.current().primarySwatch,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Send Reply',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Container(
      color: AveaThemes.current().backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message metadata
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AveaThemes.current().cardLighterBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isSentMessage ? 'Sent' : 'Received',
                        style: TextStyle(
                          color: widget.isSentMessage
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDateTime(widget.message.sentAt),
                        style:  TextStyle(
                          color: AveaThemes.current().secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.isSentMessage)
                    Text(
                      'To: ${widget.recipientName}',
                      style: TextStyle(
                        color: AveaThemes.current().textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      'From: ${widget.senderName}',
                      style: TextStyle(
                        color: AveaThemes.current().textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Message content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AveaThemes.current().cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.message.content,
                style: TextStyle(
                  color: AveaThemes.current().textColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            // Add padding at bottom for FAB visibility
            if (!widget.isSentMessage) const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
