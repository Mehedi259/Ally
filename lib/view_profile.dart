import 'package:flutter/material.dart';
import 'package:exploration_project/service_locator.dart';
import 'package:exploration_project/messaging/message_service.dart';
import 'package:exploration_project/profile/profile_service.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:flutter_beep/flutter_beep.dart';  // Disabled due to Android namespace issues

class ViewProfile extends StatefulWidget {
  final String? userId;
  final String? currentUserId;

  const ViewProfile({super.key, this.userId, this.currentUserId});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final TextEditingController _messageController = TextEditingController();
  final PanelController _panelController = PanelController();
  final int _maxCharacters = 200;
  bool _isSending = false;
  UserMessageQuota? _userQuota;
  bool _showSuccessBanner = false;
  bool _isPanelOpen = false;
  
  // Profile data
  UserProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserQuota();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    try {
      final userId = widget.userId;
      if (userId == null) {
        setState(() => _isLoadingProfile = false);
        return;
      }
      
      final profile = await ServiceLocator.profileService.getUserProfile(
        'dummy_token',
        userId,
      );
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  void _loadUserQuota() {
    final messageService = ServiceLocator.messageService;
    final currentUserId = widget.currentUserId ?? "current_user_id";
    setState(() {
      _userQuota = messageService.getUserQuota("dummy_token", currentUserId);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      _showSnackBar("Please enter a message");
      return;
    }

    if (_userQuota == null || !_userQuota!.hasMessagesRemaining) {
      _showPurchaseDialog();
      return;
    }

    setState(() {
      _isSending = true;
    });

    final messageService = ServiceLocator.messageService;
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: ServiceLocator.getLoggedInUserId(),
      recipientId: widget.userId ?? "recipient_user_id",
      content: _messageController.text,
      sentAt: DateTime.now(),
    );

    try {
      await messageService.sendMessage("dummy_token", message);
      _messageController.clear();
      _loadUserQuota();
      
      // Close the panel
      if (_panelController.isPanelOpen) {
        await _panelController.close();
      }
      
      // Play system success sound (disabled due to package issues)
      // try {
      //   FlutterBeep.beep();
      // } catch (soundError) {
      //   // Silently fail if sound can't play
      //   debugPrint('Could not play sound: $soundError');
      // }
      
      // Show success banner
      setState(() {
        _showSuccessBanner = true;
      });
      
      // Hide banner after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessBanner = false;
          });
        }
      });
    } catch (e) {
      _showSnackBar("Failed to send message: $e");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("No Messages Remaining"),
        content: Text(
          "You've used all your messages. Purchase more messages to continue connecting with others.\n\n"
          "\$5.99 for 6 months includes 10 messages",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseMessages();
            },
            child: Text("Purchase"),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseMessages() async {
    final messageService = ServiceLocator.messageService;
    final currentUserId = widget.currentUserId ?? "current_user_id";

    try {
      await messageService.purchaseMessages(
        "dummy_token",
        currentUserId,
        "6_month_package",
      );
      _loadUserQuota();
      _showSnackBar("Messages purchased successfully!");
    } catch (e) {
      _showSnackBar("Purchase failed: $e");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _getFirstName() {
    if (_profile == null) return 'User';
    return _profile!.name.split(' ').first;
  }
  
  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AveaThemes.current().primarySwatch, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // Leaving this style for now, removed color
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,  // Leaving this style for now, removed color
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCalendar() {
    // Get availability from profile or use empty map
    final weeklyAvailability = _profile?.weeklyAvailability ?? {};
    
    // Convert time slots to display format
    final availability = <String, List<String>>{};
    for (var day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']) {
      final slots = weeklyAvailability[day] ?? [];
      availability[day] = slots.map((slot) {
        final start = _formatTime(slot['start'] ?? '09:00');
        final end = _formatTime(slot['end'] ?? '17:00');
        return '$start - $end';
      }).toList();
    }

    return Column(
      children: availability.entries.map((entry) {
        final day = entry.key;
        final timeSlots = entry.value;
        final hasAvailability = timeSlots.isNotEmpty;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasAvailability
                ? AveaThemes.current().primarySwatch.withAlpha(25)
                : AveaThemes.current().cardLighterBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasAvailability
                  ? AveaThemes.current().primarySwatch.withAlpha(76)
                  : AveaThemes.current().cardLighterBackground,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day name
              SizedBox(
                width: 80,
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Time slots or unavailable message
              Expanded(
                child: hasAvailability
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: timeSlots
                            .map(
                              (slot) => Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    AveaThemes.current().availabilityTimeIcon,
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: AveaThemes.current().primarySwatch,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      slot,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AveaThemes.current().textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Text(
                        "Not available",
                        style: TextStyle(
                          fontSize: 13,
                          color: AveaThemes.current().secondaryTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessagePanel() {
    final remainingChars = _maxCharacters - _messageController.text.length;

    return Container(
      decoration: BoxDecoration(
        color: AveaThemes.current().cardBackgroundColor,
        borderRadius: BorderRadius.only(
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
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AveaThemes.current().secondaryTextColor.withAlpha(128),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Send a Message",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AveaThemes.current().textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    "Messages are for scheduling only (200 character limit)",
                    style: TextStyle(
                      fontSize: 14,
                      color: AveaThemes.current().secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Message Quota Display
                  if (_userQuota != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 20),
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
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Messages Remaining: ${_userQuota!.remainingMessages}/${_userQuota!.totalMessages}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (!_userQuota!.hasMessagesRemaining)
                            TextButton(
                              onPressed: _showPurchaseDialog,
                              child: Text("Buy More"),
                            ),
                        ],
                      ),
                    ),
                  
                  // Message Input
                  TextField(
                    controller: _messageController,
                    maxLength: _maxCharacters,
                    maxLines: 1,
                    style: TextStyle(color: AveaThemes.current().textColor),
                    decoration: InputDecoration(
                      hintText: "Type your message here...",
                      hintStyle: TextStyle(
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                      filled: true,
                      fillColor: AveaThemes.current().cardLighterBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      counterText: "$remainingChars characters remaining",
                      counterStyle: TextStyle(
                        color: AveaThemes.current().secondaryTextColor,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update character count
                    },
                  ),
                  SizedBox(height: 20),
                  
                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AveaThemes.current().primarySwatch,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSending
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Send Message",
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with SlidingUpPanel
        SlidingUpPanel(
          controller: _panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          onPanelSlide: (double position) {
            // Track panel state - position is 0.0 (closed) to 1.0 (open)
            setState(() {
              _isPanelOpen = position > 0.1; // Consider panel open if more than 10% visible
            });
          },
          panel: _buildMessagePanel(),
          body: _isLoadingProfile
              ? Center(child: CircularProgressIndicator())
              : Container(
            color: AveaThemes.current().backgroundColor,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 160, 126, 219),
                              const Color.fromARGB(255, 180, 150, 230),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Profile Avatar
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: const Color.fromARGB(255, 160, 126, 219),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Name
                            Text(
                              _profile?.name ?? 'Unknown User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            // Goal Statement with icon
                            if (_profile?.goalStatement != null && _profile!.goalStatement!.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _profile!.goalStatement!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Goal Statement Card (own profile only)
                    if (widget.userId != null && widget.userId == widget.currentUserId)
                      _buildGoalStatementCard(),

                    if (widget.userId != null && widget.userId == widget.currentUserId)
                      SizedBox(height: 20),

                    // Profile Details Card
                    Card(
                      elevation: 2,
                      color: AveaThemes.current().cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (_profile?.gender != null && _profile!.gender!.isNotEmpty)
                              _buildProfileRow(
                                  Icons.person_outline,
                                  "Gender",
                                  _profile!.gender!),
                            if (_profile?.gender != null && _profile!.gender!.isNotEmpty)
                              Divider(
                                height: 20,
                                color: AveaThemes.current().cardLighterBackground,
                              ),
                            if (_profile?.hobbies != null && _profile!.hobbies!.isNotEmpty)
                              _buildProfileRow(
                                Icons.favorite_outline,
                                "Hobbies",
                                _profile!.hobbies!,
                              ),
                            if (_profile?.hobbies != null && _profile!.hobbies!.isNotEmpty)
                              Divider(
                                height: 20,
                                color: AveaThemes.current().cardLighterBackground,
                              ),
                            if (_profile?.timezone != null && _profile!.timezone!.isNotEmpty)
                              _buildProfileRow(
                                Icons.location_on,
                                "Timezone",
                                _profile!.timezone!,
                              ),
                            if (_profile?.education != null && _profile!.education!.isNotEmpty) ...[
                              Divider(
                                height: 20,
                                color: AveaThemes.current().cardLighterBackground,
                              ),
                              _buildProfileRow(
                                Icons.school,
                                "Education",
                                _profile!.education!,
                              ),
                            ],
                            if (_profile?.profession != null && _profile!.profession!.isNotEmpty) ...[
                              Divider(
                                height: 20,
                                color: AveaThemes.current().cardLighterBackground,
                              ),
                              _buildProfileRow(
                                Icons.work,
                                "Profession",
                                _profile!.profession!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Availability Schedule Section
                    Card(
                      elevation: 2,
                      color: AveaThemes.current().cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: AveaThemes.current().primarySwatch,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Weekly Availability",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AveaThemes.current().textColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            _buildAvailabilityCalendar(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 100), // Extra space for FAB
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Floating Action Button to open messaging panel
        // Only show when panel is closed
        if (!_isPanelOpen)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                _panelController.open();
              },
              backgroundColor: AveaThemes.current().primarySwatch,
              icon: Icon(Icons.message, color: Colors.white),
              label: Text(
                "Message ${_getFirstName()}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 6,
            ),
          ),
        
        // Success Banner
        if (_showSuccessBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Message sent successfully!",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoalStatementCard() {
    final goalStatement = _profile?.goalStatement;
    final createdAt = _profile?.goalStatementCreatedAt;
    final bool hasStatement = goalStatement != null && goalStatement.isNotEmpty;
    final bool isExpired = hasStatement &&
        (createdAt == null || DateTime.now().difference(createdAt).inDays >= 90);
    final int daysRemaining = (createdAt != null && hasStatement)
        ? (90 - DateTime.now().difference(createdAt).inDays).clamp(0, 90)
        : 0;

    return Card(
      elevation: 2,
      color: AveaThemes.current().cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, color: AveaThemes.current().primarySwatch, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Your Goal Statement',
                  style: TextStyle(
                    color: AveaThemes.current().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showGoalStatementEditor(),
                  child: Text(
                    hasStatement && !isExpired ? 'Edit' : 'Add',
                    style: TextStyle(color: AveaThemes.current().primarySwatch),
                  ),
                ),
              ],
            ),
            if (isExpired) ...[
              const SizedBox(height: 8),
              Text(
                'Your goal statement has expired. Add a new one to appear on the forum.',
                style: TextStyle(color: AveaThemes.current().secondaryTextColor, fontSize: 13),
              ),
            ] else if (hasStatement) ...[
              const SizedBox(height: 8),
              Text(
                goalStatement,
                style: TextStyle(color: AveaThemes.current().textColor, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '$daysRemaining days remaining on forum',
                style: TextStyle(color: AveaThemes.current().secondaryTextColor, fontSize: 12),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Share your goal with the community. It will appear on the forum for 90 days.',
                style: TextStyle(color: AveaThemes.current().secondaryTextColor, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGoalStatementEditor() {
    final controller = TextEditingController(text: _profile?.goalStatement ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AveaThemes.current().cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Goal Statement',
                    style: TextStyle(
                      color: AveaThemes.current().textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Will appear on the forum for 90 days.',
                    style: TextStyle(color: AveaThemes.current().secondaryTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    minLines: 4,
                    maxLines: null,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: AveaThemes.current().textColor),
                    decoration: InputDecoration(
                      hintText: 'What is your main goal or aspiration?',
                      hintStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                      filled: true,
                      fillColor: AveaThemes.current().cardLighterBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              setModalState(() => isSaving = true);
                              final nav = Navigator.of(context);
                              await _saveGoalStatement(controller.text.trim());
                              nav.pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AveaThemes.current().primarySwatch,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Goal Statement'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveGoalStatement(String text) async {
    if (_profile == null) return;
    final p = _profile!;
    final updatedProfile = UserProfile(
      id: p.id,
      name: p.name,
      email: p.email,
      timezone: p.timezone,
      gender: p.gender,
      birthday: p.birthday,
      education: p.education,
      profession: p.profession,
      hobbies: p.hobbies,
      goalStatement: text.isEmpty ? null : text,
      goalStatementCreatedAt: text.isEmpty ? null : DateTime.now(),
      onboarded: p.onboarded,
      weeklyAvailability: p.weeklyAvailability,
    );
    await ServiceLocator.profileService.updateUserProfile('dummy_token', updatedProfile);
    await _loadProfile();
  }
}
