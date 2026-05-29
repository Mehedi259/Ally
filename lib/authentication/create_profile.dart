import 'package:flutter/material.dart';
import 'package:exploration_project/service_locator.dart';
import 'package:exploration_project/profile/profile_service.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
/// Profile creation screen for new users during onboarding
class CreateProfileScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final int currentStep;

  const CreateProfileScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
    required this.currentStep,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameController = TextEditingController();
  final _educationController = TextEditingController();
  final _professionController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _birthdayController = TextEditingController();
  
  String? _selectedGender = 'Unknown';
  String? _selectedTimezone = 'US/Pacific';
  DateTime? _selectedBirthday;
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Reload user data to ensure we have the latest display name
    await ServiceLocator.authService.reloadUser();
    
    // Pre-populate name from current user if available
    final user = ServiceLocator.authService.currentUser;
    if (user != null && mounted) {
      final displayName = user.displayName ?? '';
      // Extract name from onboarding marker if present
      if (displayName.startsWith('_ONBOARDING_')) {
        setState(() {
          _nameController.text = displayName.substring('_ONBOARDING_'.length);
        });
      } else if (displayName.isNotEmpty) {
        setState(() {
          _nameController.text = displayName;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _educationController.dispose();
    _professionController.dispose();
    _hobbiesController.dispose();
    _birthdayController.dispose();
    super.dispose();
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

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthday ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
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

  Future<void> _saveProfile() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTimezone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your timezone'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = ServiceLocator.authService.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }
      
      print('Creating profile for user: ${user.uid}');
      
      // Save the user's display name
      await ServiceLocator.authService.updateDisplayName(_nameController.text.trim());
      
      // Create and save the full profile to Firestore with onboarded = true
      final profile = UserProfile(
        id: user.uid,
        name: _nameController.text.trim(),
        email: user.email ?? '',
        timezone: _selectedTimezone,
        gender: _selectedGender,
        birthday: _birthdayController.text.isNotEmpty ? _birthdayController.text : null,
        education: _educationController.text.isNotEmpty ? _educationController.text : null,
        profession: _professionController.text.isNotEmpty ? _professionController.text : null,
        hobbies: _hobbiesController.text.isNotEmpty ? _hobbiesController.text : null,
        onboarded: true,
        weeklyAvailability: _weeklySchedule,
        creationDate: DateTime.now(),
      );
      
      await ServiceLocator.profileService.updateUserProfile('dummy_token', profile);
      
      // Verify the profile was saved correctly
      final savedProfile = await ServiceLocator.profileService.getUserProfile('dummy_token', user.uid);
      if (savedProfile == null || !savedProfile.onboarded) {
        throw Exception('Profile verification failed after save');
      }
      
      print('Profile creation completed successfully');
      
      if (mounted) {
        // Reload the auth state
        await ServiceLocator.authService.reloadUser();

        // Mark onboarding as complete and continue
        if (mounted) {
          widget.onComplete();
        }
      }
    } catch (e) {
      print('ERROR: Profile save failed during onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile. Please try again.\nError: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Profile"),
        backgroundColor: AveaThemes.current().primarySwatch,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : widget.onBack,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            color: AveaThemes.current().primarySwatch,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, top: 2),
                  child: Text(
                    'Step ${widget.currentStep + 1} of 3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: (widget.currentStep + 1) / 3,
                  backgroundColor: AveaThemes.current().primarySwatch.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: AveaThemes.current().backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro text
              Text(
                "Let's set up your profile so others can get to know you!",
                style: TextStyle(
                  fontSize: 16,
                  color: AveaThemes.current().secondaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Basic Info Section
              Text(
                "Basic Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AveaThemes.current().textColor,
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                style:  TextStyle(color: AveaThemes.current().textColor),
                decoration: InputDecoration(
                  labelText: "Name *",
                  labelStyle:  TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon:  Icon(Icons.person_outline, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Region/Timezone *",
                  labelStyle:  TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon:  Icon(Icons.public, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
                style:  TextStyle(color: AveaThemes.current().textColor),
                dropdownColor: AveaThemes.current().cardBackgroundColor,
                value: _selectedTimezone,
                items: _timezoneOptions.map((String timezone) {
                  return DropdownMenuItem<String>(
                    value: timezone,
                    child: Text(timezone),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedTimezone = newValue;
                        });
                      },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Gender (Optional)",
                  labelStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon: Icon(Icons.wc, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(color: AveaThemes.current().textColor),
                dropdownColor: AveaThemes.current().cardBackgroundColor,
                value: _selectedGender,
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthdayController,
                enabled: !_isLoading,
                style:  TextStyle(color: AveaThemes.current().textColor),
                decoration: InputDecoration(
                  labelText: "Birthday (Optional)",
                  labelStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  hintText: 'MM/DD/YYYY',
                  hintStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon: Icon(Icons.cake_outlined, color: AveaThemes.current().primarySwatch),
                  suffixIcon: Icon(Icons.calendar_today, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectBirthday(context),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _educationController,
                enabled: !_isLoading,
                style:  TextStyle(color: AveaThemes.current().textColor),
                decoration: InputDecoration(
                  labelText: "Education (Optional)",
                  labelStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon: Icon(Icons.school_outlined, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _professionController,
                enabled: !_isLoading,
                style: TextStyle(color: AveaThemes.current().textColor),
                decoration: InputDecoration(
                  labelText: "Profession (Optional)",
                  labelStyle: TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon: Icon(Icons.work_outline, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hobbiesController,
                enabled: !_isLoading,
                style: TextStyle(color: AveaThemes.current().textColor),
                decoration: InputDecoration(
                  labelText: "Hobbies (Optional)",
                  labelStyle:  TextStyle(color: AveaThemes.current().secondaryTextColor),
                  prefixIcon:  Icon(Icons.sports_basketball_outlined, color: AveaThemes.current().primarySwatch),
                  filled: true,
                  fillColor: AveaThemes.current().cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AveaThemes.current().cardLighterBackground),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AveaThemes.current().primarySwatch,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Schedule Section
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: AveaThemes.current().primarySwatch,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Weekly Availability",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AveaThemes.current().textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
               Text(
                "Set your available time slots for each day (you can skip this for now and add it later)",
                style: TextStyle(
                  fontSize: 14,
                  color: AveaThemes.current().secondaryTextColor,
                ),
              ),
              const SizedBox(height: 15),

              // Schedule Editor for each day
              ..._weeklySchedule.entries.map((entry) {
                final day = entry.key;
                final slots = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  color: AveaThemes.current().cardBackgroundColor,
                  shape: RoundedRectangleBorder(
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AveaThemes.current().textColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: AveaThemes.current().primarySwatch,
                              ),
                              onPressed: _isLoading ? null : () => _addTimeSlot(day),
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
                              style: TextStyle(
                                color: AveaThemes.current().secondaryTextColor,
                                fontStyle: FontStyle.italic,
                              ),
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
                                color: AveaThemes.current().primarySwatch.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AveaThemes.current().primarySwatch.withAlpha(76),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Start time button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.access_time, size: 16),
                                      label: Text(_formatTime(slot['start']!)),
                                      onPressed: _isLoading
                                          ? null
                                          : () => _selectTime(
                                                context,
                                                day,
                                                index,
                                                'start',
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "to",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // End time button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.access_time, size: 16),
                                      label: Text(_formatTime(slot['end']!)),
                                      onPressed: _isLoading
                                          ? null
                                          : () => _selectTime(
                                                context,
                                                day,
                                                index,
                                                'end',
                                              ),
                                    ),
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () => _removeTimeSlot(day, index),
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

              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AveaThemes.current().primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AveaThemes.current().primarySwatch.withValues(alpha: 0.6),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Complete Setup",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
