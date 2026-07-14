import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color primaryRed = const Color(0xffE53935);
  static Color darkBg = const Color(0xff111827);
  static Color cardBg = const Color(0xff1F2937);
  static Color aiBlue = const Color(0xff2563EB);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,

    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
    ),

    colorScheme: ColorScheme.dark(primary: primaryRed),
  );
}
