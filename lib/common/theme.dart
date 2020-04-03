import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color _textColor = Color(0xFF222222);

ThemeData appTheme(BuildContext context) {
  TextTheme baseTheme = Theme.of(context).textTheme;
  return ThemeData(
    primaryColor: Color(0xFF000133),
    accentColor: Color(0xFFFC86AA),
    canvasColor: Color(0xFFD8DCD6),
    iconTheme: IconThemeData(color: _textColor),
    textTheme: GoogleFonts.latoTextTheme(baseTheme).copyWith(
      body1: GoogleFonts.oswald(textStyle: baseTheme.body1),
      display1: GoogleFonts.oswald(textStyle: baseTheme.display1, color: Colors.white, fontSize: 16),
      display2: GoogleFonts.oswald(textStyle: baseTheme.display2, color: Colors.white, fontSize: 20),
      display3: GoogleFonts.oswald(textStyle: baseTheme.display3, color: _textColor, fontSize: 24),
      display4: GoogleFonts.oswald(textStyle: baseTheme.display4, color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
    ),
  );
}
