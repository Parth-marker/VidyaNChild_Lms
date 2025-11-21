import 'package:flutter/material.dart';
import 'package:lms_project/features/auth/signup_page.dart';
import 'package:lms_project/theme/app_text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6), // pale yellow
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _LogoHeader(),
                const SizedBox(height: 40),
                _TextFieldWidget(
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _TextFieldWidget(
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                const _LoginButton(),
                const SizedBox(height: 20),
                Text("Forgot Password?", style: AppTextStyles.linkPurple),

                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                }, child: Text("Don't have an account? Register", style: AppTextStyles.linkPurple)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.school_rounded,
          size: 80,
          color: Colors.teal,
        ),
        const SizedBox(height: 15),
        Text("Welcome Back!", style: AppTextStyles.h1Teal),
        Text("Log in to continue learning", style: AppTextStyles.body),
      ],
    );
  }
}

class _TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const _TextFieldWidget({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[400]),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[300],
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      child: Text("Login", style: AppTextStyles.buttonPrimary),
    );
  }
}