import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColors {
  static final Color textColor = Color(0xFF222222);
  static final Color primaryColor = Color(0xFF000133);
  static final Color accentColor = Color(0xFFFC86AA);
  static final Color canvasColor = Color(0xFFdcdcdc);
  static final Color canvasColorLight = Color(0xFFe7e7e7);
}

ThemeData appTheme(BuildContext context) {
  TextTheme baseTheme = Theme.of(context).textTheme;
  return ThemeData(
    primaryColor: ThemeColors.canvasColor,
    accentColor: ThemeColors.accentColor,
    canvasColor: ThemeColors.canvasColor,
    iconTheme: IconThemeData(color: ThemeColors.textColor),
    textTheme: TextTheme(
      // main appbar text style WAS TITLE
      headline6: GoogleFonts.arvo(
        textStyle: baseTheme.headline6,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.headline6.fontSize * 2.5,
        fontWeight: FontWeight.w700,
      ),
      // collection editor title text style WAS SUBTITLE
      subtitle2: GoogleFonts.arvo(
        textStyle: baseTheme.subtitle2,
        color: ThemeColors.textColor,
        fontSize: baseTheme.subtitle2.fontSize * 1.2,
      ),
      // input text dialog title text style WAS display1
      headline4: GoogleFonts.arvo(
        textStyle: baseTheme.headline4,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.headline4.fontSize * 0.8,
      ),
      // input text dialog title text style WAS display2
      headline3: GoogleFonts.arvo(
        textStyle: baseTheme.headline3,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.headline3.fontSize * 0.8,
      ),

      // input text dialog title text style WAS display3
      headline2: GoogleFonts.arvo(
        textStyle: baseTheme.headline2,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.headline2.fontSize * 1,
      )

    ),
  );
}
