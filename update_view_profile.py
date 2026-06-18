import sys

with open('lib/view_profile.dart', 'r') as f:
    content = f.read()

helper_methods = """
  Widget _buildNeonHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1A),
        border: Border.all(
          color: const Color(0xFF00CED1).withOpacity(0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CED1).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF00CED1).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'View Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00CED1), size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

"""

build_idx = content.find('  @override\n  Widget build(BuildContext context) {')
content = content[:build_idx] + helper_methods + content[build_idx:]

build_start = content.find('  @override\n  Widget build(BuildContext context) {')
content_before_build = content[:build_start]

# We need to rewrite the entire build method and the _buildMessagePanel and _buildAvailabilityCalendar methods to match the new dark theme.
# Actually, the python script will replace from `_buildAvailabilityCalendar` all the way to the end.

avail_idx = content.find('  Widget _buildAvailabilityCalendar() {')
content_before_avail = content[:avail_idx]

new_methods = """  Widget _buildAvailabilityCalendar() {
    final weeklyAvailability = _profile?.weeklyAvailability ?? {};
    
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasAvailability
                  ? const Color(0xFF8B4C9E)
                  : const Color(0xFF8B4C9E).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: hasAvailability
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: timeSlots
                            .map(
                              (slot) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Color(0xFF00CED1),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      slot,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : const Text(
                        "Not available",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white30,
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
        color: const Color(0xFF0A0F1A),
        border: const Border(
          top: BorderSide(color: Color(0xFF00CED1), width: 2),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CED1).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4C9E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Send a Message",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00CED1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    "Messages are for scheduling only (150 character limit)",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  if (_userQuota != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: _userQuota!.hasMessagesRemaining
                            ? const Color(0xFF00CED1).withOpacity(0.1)
                            : const Color(0xFF8B4C9E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _userQuota!.hasMessagesRemaining
                              ? const Color(0xFF00CED1)
                              : const Color(0xFF8B4C9E),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _userQuota!.hasMessagesRemaining
                                ? Icons.check_circle
                                : Icons.warning,
                            color: _userQuota!.hasMessagesRemaining
                                ? const Color(0xFF00CED1)
                                : const Color(0xFF8B4C9E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Messages Remaining: ${_userQuota!.remainingMessages}/${_userQuota!.totalMessages}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!_userQuota!.hasMessagesRemaining)
                            TextButton(
                              onPressed: _showPurchaseDialog,
                              child: const Text("Buy More", style: TextStyle(color: Color(0xFF00CED1))),
                            ),
                        ],
                      ),
                    ),
                  
                  TextField(
                    controller: _messageController,
                    scrollController: _textFieldScrollController,
                    maxLength: _maxCharacters,
                    minLines: 3,
                    maxLines: 6,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your message here...",
                      hintStyle: const TextStyle(
                        color: Colors.white30,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B4C9E)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF00CED1), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      counterText: "$remainingChars characters remaining",
                      counterStyle: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00CED1).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A0F1A),
                          side: const BorderSide(color: Color(0xFF00CED1), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00CED1),
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: Color(0xFF00CED1)),
                                  SizedBox(width: 8),
                                  Text(
                                    "Send Message",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00CED1),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8B4C9E), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00CED1), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF00CED1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SlidingUpPanel(
              controller: _panelController,
              minHeight: 0,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: Colors.transparent,
              onPanelSlide: (double position) {
                setState(() {
                  _isPanelOpen = position > 0.1;
                });
              },
              panel: _buildMessagePanel(),
              body: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00CED1)))
                  : Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.5),
                          radius: 1.0,
                          colors: [
                            const Color(0xFF00CED1).withOpacity(0.1),
                            Colors.black,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNeonHeader(),
                            
                            // Profile Avatar and Info
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  // Glowing Text Avatar (using initials like in ProfileScreen)
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        _getFirstName().isNotEmpty ? _getFirstName()[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          fontSize: 90,
                                          fontFamily: 'serif',
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 3
                                            ..color = const Color(0xFF00CED1),
                                          shadows: [
                                            BoxShadow(
                                              color: const Color(0xFF00CED1).withOpacity(0.8),
                                              blurRadius: 20,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _getFirstName().isNotEmpty ? _getFirstName()[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          fontSize: 90,
                                          fontFamily: 'serif',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _profile?.name ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _profile?.email.split('@').first ?? 'user',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF00CED1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_profile?.goalStatement != null && _profile!.goalStatement!.isNotEmpty)
                                    Text(
                                      _profile!.goalStatement!,
                                      style: const TextStyle(fontSize: 14, color: Color(0xFFBAA7D8)),
                                      textAlign: TextAlign.center,
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            
                            // Profile Details
                            if (_profile?.gender != null && _profile!.gender!.isNotEmpty)
                              _buildSection(
                                icon: Icons.person_outline,
                                title: "Gender",
                                content: Text(_profile!.gender!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            if (_profile?.hobbies != null && _profile!.hobbies!.isNotEmpty)
                              _buildSection(
                                icon: Icons.favorite_outline,
                                title: "Hobbies / Focus Areas",
                                content: Text(_profile!.hobbies!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            if (_profile?.timezone != null && _profile!.timezone!.isNotEmpty)
                              _buildSection(
                                icon: Icons.location_on,
                                title: "Timezone",
                                content: Text(_profile!.timezone!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            if (_profile?.education != null && _profile!.education!.isNotEmpty)
                              _buildSection(
                                icon: Icons.school,
                                title: "Education",
                                content: Text(_profile!.education!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            if (_profile?.profession != null && _profile!.profession!.isNotEmpty)
                              _buildSection(
                                icon: Icons.work,
                                title: "Profession",
                                content: Text(_profile!.profession!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              ),

                            const SizedBox(height: 8),

                            // Availability Schedule Section
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF8B4C9E), width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Color(0xFF00CED1),
                                        size: 24,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Weekly Availability",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00CED1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  _buildAvailabilityCalendar(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 100), // Extra space for FAB
                          ],
                        ),
                      ),
                    ),
            ),
            
            if (!_isPanelOpen)
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00CED1).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      _panelController.open();
                    },
                    backgroundColor: const Color(0xFF0A0F1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF00CED1), width: 1.5),
                    ),
                    icon: const Icon(Icons.message, color: Color(0xFF00CED1)),
                    label: Text(
                      "Message ${_getFirstName()}",
                      style: const TextStyle(
                        color: Color(0xFF00CED1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    elevation: 0,
                  ),
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
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00CED1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00CED1).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF00CED1),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Message sent successfully!",
                            style: TextStyle(
                              color: Colors.white,
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
        ),
      ),
    );
  }
}
"""

with open('lib/view_profile.dart', 'w') as f:
    f.write(content_before_avail + new_methods)

