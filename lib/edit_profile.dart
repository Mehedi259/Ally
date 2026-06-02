import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'bots/bot_service.dart';
import 'service_locator.dart';
import 'profile/profile_service.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _goalStatementController = TextEditingController();
  String? _originalGoalStatement;
  DateTime? _originalGoalStatementCreatedAt;

  // Dropdown selections
  String? _selectedGender = 'Unknown';
  String? _selectedTimezone = 'US/Pacific';
  DateTime? _selectedBirthday;
  
  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

  // Gender options
  final List<String> _genderOptions = ['Unknown', 'Male', 'Female'];

  // US Timezone options
  final List<String> _timezoneOptions = [
    'US/Eastern',
    'US/Central',
    'US/Mountain',
    'US/Pacific',
    'US/Alaska',
    'US/Hawaii',
  ];

  // Schedule state for each day
  final Map<String, List<Map<String, String>>> _weeklySchedule = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  // Bot/archetype settings
  List<String> _selectedArchetypes = []; // multi-select
  List<String> _botDays = [];
  String _botTime = '09:00';
  List<BotArchetype> _archetypeOptions = [];

  static const List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _dayAbbreviations = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = ServiceLocator.authService.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final results = await Future.wait([
        ServiceLocator.profileService.getUserProfile('dummy_token', currentUser.uid),
        ServiceLocator.botService.getAllArchetypes(),
      ]);
      final profile = results[0] as UserProfile?;
      final archetypes = results[1] as List<BotArchetype>;

      if (profile != null && mounted) {
        setState(() {
          _archetypeOptions = archetypes;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _selectedTimezone = profile.timezone ?? 'US/Pacific';
          _selectedGender = profile.gender ?? 'Unknown';
          _educationController.text = profile.education ?? '';
          _professionController.text = profile.profession ?? '';
          _hobbiesController.text = profile.hobbies ?? '';
          _goalStatementController.text = profile.goalStatement ?? '';
          _originalGoalStatement = profile.goalStatement;
          _originalGoalStatementCreatedAt = profile.goalStatementCreatedAt;
          
          if (profile.birthday != null && profile.birthday!.isNotEmpty) {
            _birthdayController.text = profile.birthday!;
            // Parse birthday if needed
            try {
              final parts = profile.birthday!.split('/');
              if (parts.length == 3) {
                _selectedBirthday = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[0]),
                  int.parse(parts[1]),
                );
              }
            } catch (e) {
              // Ignore parsing errors
            }
          }
          
          // Load weekly availability
          _weeklySchedule.clear();
          if (profile.weeklyAvailability.isNotEmpty) {
            _weeklySchedule.addAll(profile.weeklyAvailability);
          } else {
            // Initialize with empty lists if no data
            for (var day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']) {
              _weeklySchedule[day] = [];
            }
          }

          // Load bot settings
          _selectedArchetypes = List<String>.from(
            profile.selectedArchetypes.isNotEmpty
                ? profile.selectedArchetypes
                : (profile.selectedArchetype != null ? [profile.selectedArchetype!] : []),
          );
          _botDays = List<String>.from(profile.botDays);
          _botTime = profile.botTime ?? '09:00';

          _isLoading = false;
        });
      } else {
        setState(() {
          _archetypeOptions = archetypes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final currentUser = ServiceLocator.authService.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final newGoalStatement = _goalStatementController.text.trim();
      final goalStatementChanged = newGoalStatement != (_originalGoalStatement ?? '');
      final goalStatementCreatedAt = newGoalStatement.isEmpty
          ? null
          : (goalStatementChanged ? DateTime.now() : _originalGoalStatementCreatedAt);

      final profile = UserProfile(
        id: currentUser.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        timezone: _selectedTimezone,
        gender: _selectedGender,
        birthday: _birthdayController.text,
        education: _educationController.text.trim(),
        profession: _professionController.text.trim(),
        hobbies: _hobbiesController.text.trim(),
        goalStatement: newGoalStatement.isEmpty ? null : newGoalStatement,
        goalStatementCreatedAt: goalStatementCreatedAt,
        onboarded: true,
        weeklyAvailability: Map.from(_weeklySchedule),
        selectedArchetypes: List<String>.from(_selectedArchetypes),
        selectedArchetype: _selectedArchetypes.isNotEmpty ? _selectedArchetypes.first : null,
        botDays: List<String>.from(_botDays),
        botTime: _selectedArchetypes.isNotEmpty ? _botTime : null,
        lastActivityAt: DateTime.now().toUtc(),
      );

      await ServiceLocator.profileService.updateUserProfile('dummy_token', profile);

      // Schedule or cancel goal statement expiry notifications
      if (goalStatementCreatedAt != null) {
        await ServiceLocator.localNotificationsService
            .scheduleGoalStatementNotifications(goalStatementCreatedAt);
      } else {
        await ServiceLocator.localNotificationsService
            .cancelGoalStatementNotifications();
      }

      // Activate or deactivate bot
      if (_selectedArchetypes.isNotEmpty && _botDays.isNotEmpty) {
        // Use the first selected archetype as the primary one
        final archetype = await ServiceLocator.botService.getArchetype(_selectedArchetypes.first);
        if (archetype != null) {
          await ServiceLocator.botService.activateBot(profile, archetype);
        }
      } else {
        await ServiceLocator.botService.deactivateBot(currentUser.uid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile and schedule saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addTimeSlot(String day) {
    setState(() {
      _weeklySchedule[day]!.add({'start': '09:00', 'end': '17:00'});
    });
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      _weeklySchedule[day]!.removeAt(index);
    });
  }

  Future<void> _selectTime(
    BuildContext context,
    String day,
    int slotIndex,
    String timeType,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _weeklySchedule[day]![slotIndex][timeType] = '$hour:$minute';
      });
    }
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _selectBotTime(BuildContext context) async {
    final timeParts = _botTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _botTime = '$hour:$minute';
      });
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthday ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 120), // Max 120 years old
      lastDate: now, // Can't select future dates
      helpText: 'Select your birthday',
    );

    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text =
            '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _professionController.dispose();
    _hobbiesController.dispose();
    _birthdayController.dispose();
    _goalStatementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: AveaThemes.current().primarySwatch
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // AveaThemes.current().basicInfoIcon,
                  AveaThemes.current().basicInformationIcon,
                  SizedBox(width: 10),
                  Text(
                      "Basic Information",
                      style: Theme.of(context).textTheme.titleLarge
                  ),
                ],
              ),
              // Basic Info Section

              SizedBox(height: 15),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(

                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Region/Timezone",
                  border: OutlineInputBorder(),
                ),
                value: _selectedTimezone,
                items: _timezoneOptions.map((String timezone) {
                  return DropdownMenuItem<String>(
                    value: timezone,
                    child: Text(timezone),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimezone = newValue;
                  });
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: _birthdayController,
                decoration: InputDecoration(
                  labelText: "Birthday",
                  border: OutlineInputBorder(),
                  hintText: 'MM/DD/YYYY',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectBirthday(context),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _educationController,
                decoration: InputDecoration(
                  labelText: "Education",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _professionController,
                decoration: InputDecoration(
                  labelText: "Profession",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _hobbiesController,
                decoration: InputDecoration(
                  labelText: "Hobbies",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _goalStatementController,
                decoration: InputDecoration(
                  labelText: "Goal Statement",
                  border: OutlineInputBorder(),
                  hintText: "What is your main goal or aspiration?",
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 30),

              // Schedule Section
              Row(
                children: [
                  AveaThemes.current().availabilityIcon,
                  SizedBox(width: 10),
                  Text(
                    "Weekly Availability",
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Set your available time slots for each day",
                style: Theme.of(context).textTheme.bodyMedium
              ),
              SizedBox(height: 15),

              // Schedule Editor for each day
              ..._weeklySchedule.entries.map((entry) {
                final day = entry.key;
                final slots = entry.value;

                return Card(
                  margin: EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day header with add button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day,
                              style: Theme.of(context).textTheme.titleMedium
                            ),
                            IconButton(
                              icon: AveaThemes.current().availabilityAddIcon,
                              onPressed: () => _addTimeSlot(day),
                              tooltip: "Add time slot",
                            ),
                          ],
                        ),
                        // Time slots
                        if (slots.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "No availability set",
                            ),
                          )
                        else
                          ...slots.asMap().entries.map((slotEntry) {
                            final index = slotEntry.key;
                            final slot = slotEntry.value;

                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(8),

                              // This decoration style is custom to this control
                              // It's not global in ThemeData
                              decoration: AveaThemes.current().availabilityBoxDecoration,
                              child: Row(
                                children: [
                                  // Start time button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: Icon(Icons.access_time, size: 16),
                                      label: Text(_formatTime(slot['start']!)),
                                      onPressed: () => _selectTime(
                                        context,
                                        day,
                                        index,
                                        'start',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "to",
                                  ),
                                  SizedBox(width: 8),
                                  // End time button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: AveaThemes.current().availabilityTimeIcon,
                                      label: Text(_formatTime(slot['end']!)),
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
                                    icon: AveaThemes.current().availabilityDeleteIcon,
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

              SizedBox(height: 30),

              // My Ally Bot Section
              Row(
                children: [
                  AveaThemes.current().archetypeIcon,
                  SizedBox(width: 10),
                  Text(
                    "My Ally Archetype",
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Choose one or more archetypes to receive personalized messages",
              ),
              SizedBox(height: 10),

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
                    child: Text('Select All'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedArchetypes = [];
                        _botDays = [];
                      });
                    },
                    child: Text('Clear All'),
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
                    label: Text(archetype.displayName),
                    selected: selected,
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

              // Days and time — only shown when at least one archetype is selected
              if (_selectedArchetypes.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  "Receive messages on:",
                  style: Theme.of(context).textTheme.titleMedium
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: List.generate(_daysOfWeek.length, (index) {
                    final day = _daysOfWeek[index];
                    final selected = _botDays.contains(day);
                    return FilterChip(
                      label: Text(_dayAbbreviations[index]),
                      selected: selected,
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
                SizedBox(height: 16),
                Text(
                  "At time:",
                  style: Theme.of(context).textTheme.titleMedium
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: AveaThemes.current().availabilityTimeIcon,
                  label: Text(_formatTime(_botTime)),
                  onPressed: () => _selectBotTime(context),
                ),
              ],

              SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 160, 126, 219),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
