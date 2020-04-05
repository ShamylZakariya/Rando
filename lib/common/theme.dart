import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColors {
  static final Color textColor = Color(0xFF222222);
  static final Color primaryColor = Color(0xFF000133);
  static final Color accentColor = Color(0xFFFC86AA);
  static final Color canvasColor = Color(0xFFD8DCD6);
}

ThemeData appTheme(BuildContext context) {
  TextTheme baseTheme = Theme.of(context).textTheme;
  return ThemeData(
    primaryColor: ThemeColors.primaryColor,
    accentColor: ThemeColors.accentColor,
    canvasColor: ThemeColors.canvasColor,
    iconTheme: IconThemeData(color: ThemeColors.textColor),
    textTheme: TextTheme(
      // main appbar text style
      title: GoogleFonts.arvo(
        textStyle: baseTheme.title,
        color: ThemeColors.canvasColor,
        fontSize: baseTheme.title.fontSize * 1.2,
        fontWeight: FontWeight.w700,
      ),
      // collection editor title text style
      subtitle: GoogleFonts.arvo(
        textStyle: baseTheme.subtitle,
        color: ThemeColors.textColor,
        fontSize: baseTheme.subtitle.fontSize * 1.2,
      ),
      // input text dialog title text style
      display1: GoogleFonts.arvo(
        textStyle: baseTheme.display1,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.display1.fontSize * 0.8,
      ),
      // input text dialog title text style
      display2: GoogleFonts.arvo(
        textStyle: baseTheme.display2,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.display2.fontSize * 0.8,
      ),

      // input text dialog title text style
      display3: GoogleFonts.arvo(
        textStyle: baseTheme.display3,
        color: ThemeColors.primaryColor,
        fontSize: baseTheme.display2.fontSize * 1,
      )

    ),
  );
}
