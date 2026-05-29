import 'package:flutter/material.dart';

/// Centralized app settings and theme configuration
class AppTheme {

  // Private constructor to prevent instantiation
  AppTheme._();

  // Theme Colors
  static const Color primarySwatch          = Color.fromARGB(255, 160, 126, 219);
  static const Color backgroundColor        = Color(0xFF363439);
  static const Color cardBackgroundColor    = Color(0xFF2A2829);
  static const Color cardLighterBackground  = Color(0xFF3D3A3F);
  static const Color textColor              = Color(0xFFE8E6E3);
  static const Color secondaryTextColor     = Color(0xFFB8B5B2);

  ////////////////////////////////////////////////////////////////////////////
  // Edit Profile Page Theme
  /////////////////////////////////////////////////////////////////////////////

  static const Icon basicInfoIcon = Icon(Icons.person_2_outlined, size: 24, color: Color.fromARGB(255, 160, 126, 219));
  /////////////////////////
  // Profile Availability

  static  Icon availabilityIcon = Icon(
    Icons.calendar_month,
    color: AppTheme.primarySwatch,
    size: 24,
  );

  static Icon availabilityAddIcon = Icon(
    Icons.add_circle,
    color: AppTheme.primarySwatch,
  );
  static const Icon availabilityTimeIcon = Icon(
    Icons.access_time,
      size: 16
  );



  static BoxDecoration availabilityBoxDecoration = BoxDecoration(
    color: Color.fromARGB(25, 160, 126, 219),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Color.fromARGB(76, 160, 126, 219)
      ),
    );

  // The delete availability icon
  static Icon availabilityDeleteIcon = Icon(
    Icons.delete_outline,
    color: Colors.red
  );

  /////////////////////////
  // Archetype Settings


  // Profile Archetype Days of the week selection
  static const Icon archTitleIcon = Icon(Icons.smart_toy_outlined, size: 24, color: Color.fromARGB(255, 160, 126, 219));


  // Text Colors for Forum Posts
  static const List<Color> postTextColors = [
    Color.fromARGB(255,   0, 235,  48),
    Color.fromARGB(255, 172,   4, 225),
    Color.fromARGB(255,  37, 150, 190),
    Color.fromARGB(255, 156, 255, 212),
    Color.fromARGB(255, 204, 204, 255),
    Color.fromARGB(255, 234, 255, 111),
    Color.fromARGB(255, 255, 160, 111),
  ];
}
