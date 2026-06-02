
import 'package:flutter/material.dart';

class AveaTheme{

  Color? _defaultTextColor;
  Color? _backgroundBlack ;
  Color? _slightlyDarkerBackgroundBlack;
  Color? _primarySwatch ;
  Color? _cardLightBackground ;
  Color? _iconColor;


  Icon? _basicInformationIcon;
  Icon? _availabilityAddIcon;
  Icon? _availabilityTimeIcon;
  Icon? _availabilityDeleteIcon;
  BoxDecoration? _availabilityBoxDecoration;
  Icon? _archetypeIcon;
  ThemeData? _themeData;



  AveaTheme({
    required Color primarySwatch,
    required Color backgroundColor,
    required Color cardBackgroundColor,
    required Color cardLighterBackground,
    required Color textColor,
    required Color secondaryTextColor,
    Color? iconColor

    // TODO: Add button Color
    // TODO: Add selected chip color
    // TODO: Border button color


  }){
      _primarySwatch = primarySwatch;
      _backgroundBlack = backgroundColor;
      _slightlyDarkerBackgroundBlack = cardBackgroundColor;
      _cardLightBackground = cardLighterBackground;
      _defaultTextColor = textColor;

      _iconColor = iconColor;
      _iconColor ??= primarySwatch;

  }

  //////////////////////////////////////////////////////////////////////////////
  // Getters for colors used in the theme
  Color get primarySwatch => _primarySwatch!;
  Color get backgroundColor => _backgroundBlack!;
  Color get cardBackgroundColor => _slightlyDarkerBackgroundBlack!;
  Color get cardLighterBackground => _cardLightBackground!;
  Color get textColor => _defaultTextColor!;
  Color get secondaryTextColor => _defaultTextColor!;


  //////////////////////////////////////////////////////////////////////////////
  // Icons used in the app

  /// The icon used in edit profile -> Basic Information
  Icon get basicInformationIcon {
    _basicInformationIcon ??= Icon(
        Icons.person_2_outlined,
        size: 24,
        color: _iconColor
    );
    return _basicInformationIcon!;
  }

  /// The icon used in edit profile -> availability
  Icon get availabilityIcon => Icon(
    Icons.calendar_month,
    color: _iconColor,
    size: 24,
  );

  /// The icon used in edit profile to add availability
  Icon get availabilityAddIcon {
    _availabilityAddIcon ??= Icon(
        Icons.add_circle,
        color: _iconColor
    );
    return _availabilityAddIcon!;
  }

  /// Small clock icon used in select time border buttons
  Icon get availabilityTimeIcon {
    _availabilityTimeIcon ??= Icon(
        Icons.access_time,
        size: 16
    );
    return _availabilityTimeIcon!;
  }

  /// Delete icon 
  Icon get availabilityDeleteIcon {
    _availabilityDeleteIcon ??= Icon(
        Icons.delete_outline,
        color: Colors.red
    );
    return _availabilityDeleteIcon!;
  }

  /// Used to separate rows in a list of available times in edit profile
  BoxDecoration get availabilityBoxDecoration {
    _availabilityBoxDecoration ??= BoxDecoration(
      color: primarySwatch.withAlpha(25),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
          color: primarySwatch.withAlpha(76)
      ),
    );
    return _availabilityBoxDecoration!;
  }

  List<Color> get postTextColors => const [
    Color(0xFF6B3FA0),   // medium purple
    Color(0xFF9C5B1E),   // warm amber-brown
    Color(0xFF1F7A5C),   // muted teal-green
    Color(0xFF8B2E59),   // deep rose
    Color(0xFF2E5FA3),   // slate blue
    Color(0xFF6B6B1A),   // olive gold
    Color(0xFF3A7A3A),   // forest green
  ];

  /// Used in edit profile -> archetype
  Icon get archetypeIcon {
    _archetypeIcon ??= Icon(
        Icons.groups,
        size: 24,
        color: _iconColor
    );
    return _archetypeIcon!;
  }

  //////////////////////////////////////////////////////////////////////////////
  // ThemeData: Used to set the application wide default theme
  
  /// The theme data for setting global styles
   ThemeData get themeData {
    return ThemeData(

        scaffoldBackgroundColor: backgroundColor,
        textTheme: TextTheme(
          displayLarge: TextStyle(color: textColor),
          displayMedium: TextStyle(color: textColor),
          displaySmall: TextStyle(color: textColor),
          titleLarge: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          bodySmall: TextStyle(color: textColor),
          labelLarge: TextStyle(color: textColor),
          labelMedium: TextStyle(color: textColor),
          labelSmall: TextStyle(color: textColor),
        ),


        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBackgroundColor,
          labelStyle: TextStyle(
            color: textColor,
          ),
        ),


        dropdownMenuTheme: DropdownMenuThemeData(
            menuStyle: MenuStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(cardBackgroundColor)
            )
        ),

        canvasColor: cardBackgroundColor,


        // Card Data
        cardTheme: CardThemeData(
          color: cardBackgroundColor,

        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(color: primarySwatch),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            )

        ),

        chipTheme: ChipThemeData(
            selectedColor: primarySwatch,
            checkmarkColor: textColor,
            backgroundColor: cardBackgroundColor,
            labelStyle: TextStyle(color: textColor),
            secondaryLabelStyle: TextStyle(fontWeight: FontWeight.bold)
        )
    );
  }
}


class AveaThemes {

  static final AveaTheme darkPurple = AveaTheme(
    primarySwatch:         Color.fromARGB(255, 160, 126, 219),
    backgroundColor:       Color(0xFF363439),
    cardBackgroundColor:   Color(0xFF2A2829),
    cardLighterBackground: Color(0xFF3D3A3F),
    textColor:             Color(0xFFE8E6E3),
    secondaryTextColor:    Color(0xFFE8E6E3)
  );

  static final AveaTheme tan = AveaTheme(
      primarySwatch:         Color.fromARGB(255, 120, 80, 180),  // purple trim
      backgroundColor:       Color.fromARGB(255, 237, 228, 210),  // warm tan
      cardBackgroundColor:   Color.fromARGB(255, 249, 245, 237),  // lighter cream
      cardLighterBackground: Color.fromARGB(255, 255, 251, 244),
      textColor:             Color(0xFF2D2035),  // deep purple-brown for readability
      secondaryTextColor:    Color(0xFF5A4570),
      iconColor:             Color.fromARGB(255, 120, 80, 180),  // purple icons
  );



  static AveaTheme current() {
    return tan;
  }
}


