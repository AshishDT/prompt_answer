import 'package:flutter/material.dart';
// ignore_for_file: public_member_api_docs

/// App Themes
class AppThemes {
  AppThemes._();

  static const Color dodgerBlue = Color.fromRGBO(29, 161, 242, 1);
  static const Color whiteLilac = Color.fromRGBO(248, 250, 252, 1);
  static const Color blackPearl = Color.fromRGBO(30, 31, 43, 1);
  static const Color brinkPink = Color.fromRGBO(255, 97, 136, 1);
  static const Color juneBud = Color.fromRGBO(186, 215, 97, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color nevada = Color.fromRGBO(105, 109, 119, 1);
  static const Color ebonyClay = Color.fromRGBO(40, 42, 58, 1);

  static String font1 = 'ProductSans';
  static String font2 = 'Roboto';

  //constants color range for light theme
  //main color
  static const Color _lightPrimaryColor = dodgerBlue;

  //Background Colors
  static const Color _lightBackgroundColor = whiteLilac;
  static const Color _lightBackgroundAppBarColor = _lightPrimaryColor;
  static const Color _lightBackgroundSecondaryColor = white;
  static const Color _lightBackgroundAlertColor = blackPearl;
  static const Color _lightBackgroundActionTextColor = white;

  //Text Colors
  static const Color _lightTextColor = Colors.black;

  //Border Color
  static const Color _lightBorderColor = nevada;

  //Icon Color
  static const Color _lightIconColor = nevada;

  //form input colors
  static const Color _lightBorderActiveColor = _lightPrimaryColor;
  static const Color _lightBorderErrorColor = brinkPink;

  //constants color range for dark theme
  static const Color _darkPrimaryColor = dodgerBlue;

  //Background Colors
  static const Color _darkBackgroundColor = ebonyClay;
  static const Color _darkBackgroundAppBarColor = _darkPrimaryColor;
  static const Color _darkBackgroundSecondaryColor =
      Color.fromRGBO(0, 0, 0, .6);
  static const Color _darkBackgroundAlertColor = blackPearl;
  static const Color _darkBackgroundActionTextColor = white;


  //Text Colors
  static const Color _darkTextColor = Colors.white;

  //Border Color
  static const Color _darkBorderColor = nevada;

  //Icon Color
  static const Color _darkIconColor = nevada;

  static const Color _darkInputFillColor = _darkBackgroundSecondaryColor;
  static const Color _darkBorderActiveColor = _darkPrimaryColor;
  static const Color _darkBorderErrorColor = brinkPink;

  //text theme for light theme
  static const TextTheme _lightTextTheme = TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: _lightTextColor),
    bodyLarge: TextStyle(fontSize: 18, color: _lightTextColor),
    bodySmall: TextStyle(fontSize: 14, color: _lightTextColor),
    headlineMedium: TextStyle(fontSize: 20, color: _lightTextColor),
    displaySmall: TextStyle(fontSize: 12, color: _lightTextColor),
    displayLarge: TextStyle(fontSize: 24, color: _lightTextColor),
    labelSmall: TextStyle(fontSize: 10, color: _lightTextColor),
    titleLarge: TextStyle(fontSize: 24, color: _lightTextColor),
    labelMedium: TextStyle(fontSize: 14, color: _lightTextColor),
    titleSmall: TextStyle(fontSize: 18, color: _lightTextColor),
    displayMedium: TextStyle(fontSize: 16, color: _lightTextColor),
    headlineLarge: TextStyle(fontSize: 24, color: _lightTextColor),
    headlineSmall: TextStyle(fontSize: 18, color: _lightTextColor),
    labelLarge: TextStyle(fontSize: 18, color: _lightTextColor),
    titleMedium: TextStyle(fontSize: 20, color: _lightTextColor),
  );

  //the light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: font1,
    scaffoldBackgroundColor: _lightBackgroundColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
    ),
    appBarTheme: const AppBarTheme(
      color: _lightBackgroundAppBarColor,
      iconTheme: IconThemeData(color: _lightTextColor),
    ),
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      // secondary: _lightSecondaryColor,
    ),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: _lightBackgroundAlertColor,
        actionTextColor: _lightBackgroundActionTextColor),
    iconTheme: const IconThemeData(
      color: _lightIconColor,
    ),
    popupMenuTheme:
        const PopupMenuThemeData(color: _lightBackgroundAppBarColor),
    textTheme: _lightTextTheme,
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: _lightPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _lightPrimaryColor,
    inputDecorationTheme: const InputDecorationTheme(
      //prefixStyle: TextStyle(color: _lightIconColor),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(8),
      )),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderActiveColor),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      fillColor: _lightBackgroundSecondaryColor,
      //focusColor: _lightBorderActiveColor,
    ),
  );

//text theme for dark theme
  /*static final TextStyle _darkScreenHeadingTextStyle =
      _lightScreenHeadingTextStyle.copyWith(color: _darkTextColor);
  static final TextStyle _darkScreenTaskNameTextStyle =
      _lightScreenTaskNameTextStyle.copyWith(color: _darkTextColor);
  static final TextStyle _darkScreenTaskDurationTextStyle =
      _lightScreenTaskDurationTextStyle;
  static final TextStyle _darkScreenButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _darkTextColor, fontWeight: FontWeight.w500);
  static final TextStyle _darkScreenCaptionTextStyle = TextStyle(
      fontSize: 12.0,
      color: _darkBackgroundAppBarColor,
      fontWeight: FontWeight.w100);*/

  static const TextTheme _darkTextTheme = TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: _darkTextColor),
    bodyLarge: TextStyle(fontSize: 18, color: _darkTextColor),
    bodySmall: TextStyle(fontSize: 14, color: _darkTextColor),
    headlineMedium: TextStyle(fontSize: 20, color: _darkTextColor),
    displaySmall: TextStyle(fontSize: 12, color: _darkTextColor),
    displayLarge: TextStyle(fontSize: 24, color: _darkTextColor),
    labelSmall: TextStyle(fontSize: 10, color: _darkTextColor),
    titleLarge: TextStyle(fontSize: 24, color: _darkTextColor),
    labelMedium: TextStyle(fontSize: 14, color: _darkTextColor),
    titleSmall: TextStyle(fontSize: 18, color: _darkTextColor),
    displayMedium: TextStyle(fontSize: 16, color: _darkTextColor),
    headlineLarge: TextStyle(fontSize: 24, color: _darkTextColor),
    headlineSmall: TextStyle(fontSize: 18, color: _darkTextColor),
    labelLarge: TextStyle(fontSize: 18, color: _darkTextColor),
    titleMedium: TextStyle(fontSize: 20, color: _darkTextColor),
  );

  //the dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    //primarySwatch: _darkPrimaryColor, //cant be Color on MaterialColor so it can compute different shades.
    //prefix icon color form input on focus

    fontFamily: font1,
    scaffoldBackgroundColor: _darkBackgroundColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
    ),
    appBarTheme: const AppBarTheme(
      color: _darkBackgroundAppBarColor,
      iconTheme: IconThemeData(color: _darkTextColor),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,

      // secondary: _darkSecondaryColor,
    ),
    snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(color: Colors.white),
        backgroundColor: _darkBackgroundAlertColor,
        actionTextColor: _darkBackgroundActionTextColor),
    iconTheme: const IconThemeData(
      color: _darkIconColor, //_darkIconColor,
    ),
    popupMenuTheme: const PopupMenuThemeData(color: _darkBackgroundAppBarColor),
    textTheme: _darkTextTheme,
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: _darkPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _darkPrimaryColor,
    inputDecorationTheme: const InputDecorationTheme(
      prefixStyle: TextStyle(color: _darkIconColor),
      //labelStyle: TextStyle(color: nevada),
      border: OutlineInputBorder(
          borderSide: BorderSide(width: 1),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          )),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderActiveColor),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      fillColor: _darkInputFillColor,
      //focusColor: _darkBorderActiveColor,
    ),
  );
}
