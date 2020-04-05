import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color _textColor = Color(0xFF222222);
final Color _primaryColor = Color(0xFF000133);
final Color _accentColor = Color(0xFFFC86AA);
final Color _canvasColor = Color(0xFFD8DCD6);

ThemeData appTheme(BuildContext context) {
  TextTheme baseTheme = Theme.of(context).textTheme;
  return ThemeData(
    primaryColor: _primaryColor,
    accentColor: _accentColor,
    canvasColor: _canvasColor,
    iconTheme: IconThemeData(color: _textColor),
    textTheme: TextTheme(
      // main appbar text style
      title: GoogleFonts.arvo(
        textStyle: baseTheme.title,
        color: _canvasColor,
        fontSize: baseTheme.title.fontSize * 1.2,
        fontWeight: FontWeight.w700,
      ),
      // collection editor title text style
      subtitle: GoogleFonts.arvo(
        textStyle: baseTheme.subtitle,
        color: _textColor,
        fontSize: baseTheme.subtitle.fontSize * 1.2,
      ),
      // input text dialog title text style
      display1: GoogleFonts.arvo(
        textStyle: baseTheme.display1,
        color: _primaryColor,
        fontSize: baseTheme.display1.fontSize * 0.8,
      ),
      // input text dialog title text style
      display2: GoogleFonts.arvo(
        textStyle: baseTheme.display2,
        color: _primaryColor,
        fontSize: baseTheme.display2.fontSize * 0.8,
      ),

      // input text dialog title text style
      display3: GoogleFonts.arvo(
        textStyle: baseTheme.display3,
        color: _primaryColor,
        fontSize: baseTheme.display2.fontSize * 1,
      )

    ),
  );
}
