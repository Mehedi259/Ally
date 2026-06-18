import sys
import re

with open('lib/edit_profile.dart', 'r') as f:
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
              'Edit Profile',
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

  InputDecoration _customInputDecoration(String labelText, {String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: Color(0xFF00CED1)),
      hintStyle: const TextStyle(color: Colors.white30),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF0A0F1A),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF8B4C9E)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00CED1), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

"""

# Insert helper methods before the build method
build_idx = content.find('  @override\n  Widget build(BuildContext context) {')
content = content[:build_idx] + helper_methods + content[build_idx:]

# Now replace the build method contents and the rest of the file
# We will use regex to find the start of build and replace from there to the end.

build_start = content.find('  @override\n  Widget build(BuildContext context) {')
content_before_build = content[:build_start]

new_build_method = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00CED1)))
          : SafeArea(
              child: Theme(
                data: ThemeData.dark().copyWith(
                  primaryColor: const Color(0xFF00CED1),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF00CED1),
                    secondary: Color(0xFF8B4C9E),
                  ),
                ),
                child: Container(
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Info Section
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Color(0xFF00CED1)),
                                  const SizedBox(width: 10),
                                  Text(
                                      "Basic Information",
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _nameController,
                                decoration: _customInputDecoration("Name"),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                decoration: _customInputDecoration("Email"),
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                dropdownColor: const Color(0xFF0A0F1A),
                                decoration: _customInputDecoration("Region/Timezone"),
                                value: _selectedTimezone,
                                items: _timezoneOptions.map((String timezone) {
                                  return DropdownMenuItem<String>(
                                    value: timezone,
                                    child: Text(timezone, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedTimezone = newValue;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                dropdownColor: const Color(0xFF0A0F1A),
                                decoration: _customInputDecoration("Gender"),
                                value: _selectedGender,
                                items: _genderOptions.map((String gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _birthdayController,
                                decoration: _customInputDecoration("Birthday", hintText: 'MM/DD/YYYY', suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00CED1))),
                                readOnly: true,
                                style: const TextStyle(color: Colors.white),
                                onTap: () => _selectBirthday(context),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _educationController,
                                decoration: _customInputDecoration("Education"),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _professionController,
                                decoration: _customInputDecoration("Profession"),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _hobbiesController,
                                decoration: _customInputDecoration("Focus Areas / Hobbies", hintText: "e.g. Discipline, Health"),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _goalStatementController,
                                decoration: _customInputDecoration("Goal Statement", hintText: "What is your main goal or aspiration?"),
                                maxLines: 3,
                                style: const TextStyle(color: Colors.white),
                                textCapitalization: TextCapitalization.sentences,
                              ),
                              const SizedBox(height: 30),

                              // Schedule Section
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: Color(0xFF8B4C9E)),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Weekly Availability",
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Set your available time slots for each day",
                                style: TextStyle(color: Colors.white70)
                              ),
                              const SizedBox(height: 15),

                              // Schedule Editor for each day
                              ..._weeklySchedule.entries.map((entry) {
                                final day = entry.key;
                                final slots = entry.value;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A0F1A),
                                    border: Border.all(color: const Color(0xFF8B4C9E).withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Day header with add button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              day,
                                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00CED1)),
                                              onPressed: () => _addTimeSlot(day),
                                              tooltip: "Add time slot",
                                            ),
                                          ],
                                        ),
                                        // Time slots
                                        if (slots.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              "No availability set",
                                              style: TextStyle(color: Colors.white30),
                                            ),
                                          )
                                        else
                                          ...slots.asMap().entries.map((slotEntry) {
                                            final index = slotEntry.key;
                                            final slot = slotEntry.value;

                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Start time button
                                                  Expanded(
                                                    child: OutlinedButton.icon(
                                                      icon: const Icon(Icons.access_time, size: 16, color: Color(0xFF00CED1)),
                                                      label: Text(_formatTime(slot['start']!), style: const TextStyle(color: Colors.white)),
                                                      style: OutlinedButton.styleFrom(
                                                        side: const BorderSide(color: Color(0xFF00CED1)),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      onPressed: () => _selectTime(
                                                        context,
                                                        day,
                                                        index,
                                                        'start',
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text("to", style: TextStyle(color: Colors.white70)),
                                                  const SizedBox(width: 8),
                                                  // End time button
                                                  Expanded(
                                                    child: OutlinedButton.icon(
                                                      icon: const Icon(Icons.access_time, size: 16, color: Color(0xFF8B4C9E)),
                                                      label: Text(_formatTime(slot['end']!), style: const TextStyle(color: Colors.white)),
                                                      style: OutlinedButton.styleFrom(
                                                        side: const BorderSide(color: Color(0xFF8B4C9E)),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      onPressed: () => _selectTime(
                                                        context,
                                                        day,
                                                        index,
                                                        'end',
                                                      ),
                                                    ),
                                                  ),
                                                  // Delete button
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                    onPressed: () =>
                                                        _removeTimeSlot(day, index),
                                                    tooltip: "Remove",
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 30),

                              // My Ally Bot Section
                              Row(
                                children: [
                                  const Icon(Icons.smart_toy_outlined, color: Color(0xFF00CED1)),
                                  const SizedBox(width: 10),
                                  Text(
                                    "My Ally Archetype",
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Choose one or more archetypes to receive personalized messages",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 10),

                              // Select All / Clear All row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedArchetypes = _archetypeOptions.map((a) => a.id).toList();
                                      });
                                    },
                                    child: const Text('Select All', style: TextStyle(color: Color(0xFF00CED1))),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedArchetypes = [];
                                        _botDays = [];
                                      });
                                    },
                                    child: const Text('Clear All', style: TextStyle(color: Color(0xFF8B4C9E))),
                                  ),
                                ],
                              ),

                              // Multi-select Wrap of FilterChips
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: _archetypeOptions.map((archetype) {
                                  final selected = _selectedArchetypes.contains(archetype.id);
                                  return FilterChip(
                                    label: Text(archetype.displayName, style: TextStyle(color: selected ? Colors.black : Colors.white)),
                                    selected: selected,
                                    selectedColor: const Color(0xFF00CED1),
                                    backgroundColor: const Color(0xFF0A0F1A),
                                    shape: StadiumBorder(side: BorderSide(color: selected ? const Color(0xFF00CED1) : const Color(0xFF8B4C9E))),
                                    onSelected: (bool value) {
                                      setState(() {
                                        if (value) {
                                          _selectedArchetypes.add(archetype.id);
                                        } else {
                                          _selectedArchetypes.remove(archetype.id);
                                          if (_selectedArchetypes.isEmpty) _botDays = [];
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                              // Days and time
                              if (_selectedArchetypes.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const Text(
                                  "Receive messages on:",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: List.generate(_daysOfWeek.length, (index) {
                                    final day = _daysOfWeek[index];
                                    final selected = _botDays.contains(day);
                                    return FilterChip(
                                      label: Text(_dayAbbreviations[index], style: TextStyle(color: selected ? Colors.black : Colors.white)),
                                      selected: selected,
                                      selectedColor: const Color(0xFF8B4C9E),
                                      backgroundColor: const Color(0xFF0A0F1A),
                                      shape: StadiumBorder(side: BorderSide(color: selected ? const Color(0xFF8B4C9E) : const Color(0xFF00CED1).withOpacity(0.5))),
                                      onSelected: (bool value) {
                                        setState(() {
                                          if (value) {
                                            _botDays.add(day);
                                          } else {
                                            _botDays.remove(day);
                                          }
                                        });
                                      },
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "At time:",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.access_time, color: Color(0xFF00CED1)),
                                  label: Text(_formatTime(_botTime), style: const TextStyle(color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF00CED1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _selectBotTime(context),
                                ),
                              ],

                              const SizedBox(height: 40),

                              // Save button
                              SizedBox(
                                width: double.infinity,
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
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A0F1A),
                                      side: const BorderSide(color: Color(0xFF00CED1), width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: _isSaving ? null : _saveProfile,
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00CED1)),
                                            ),
                                          )
                                        : const Text(
                                            "Save Changes",
                                            style: TextStyle(fontSize: 18, color: Color(0xFF00CED1), fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
"""

with open('lib/edit_profile.dart', 'w') as f:
    f.write(content_before_build + new_build_method)

