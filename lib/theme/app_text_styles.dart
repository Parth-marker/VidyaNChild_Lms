import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headers
  static TextStyle get h1Teal => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.teal[700],
      );

  static TextStyle get h1Purple => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      );

  // Body / Paragraph
  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black,
      );

  // Inputs
  static TextStyle get input => GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black,
      );

  // Buttons
  static TextStyle get buttonPrimary => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  // Links / Actions
  static TextStyle get linkPurple => GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.purple,
        fontWeight: FontWeight.w500,
      );
}