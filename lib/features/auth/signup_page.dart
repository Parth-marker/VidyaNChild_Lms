import 'package:flutter/material.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:lms_project/theme/app_text_styles.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
                const _SignUpHeader(),
                const SizedBox(height: 40),
                const _SignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.group_add_sharp,
          color: Colors.purple,
          size: 80,
        ),
        const SizedBox(height: 10),
        Text("Create Your Account", style: AppTextStyles.h1Purple),
        Text("Join Vidya & Child LMS today!", style: AppTextStyles.body),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputField(icon: Icons.person_outline, hintText: "Full Name", obscure: true),
        const SizedBox(height: 20),
        _InputField(icon: Icons.email_outlined, hintText: "Email", obscure: true),
        const SizedBox(height: 20),
        _InputField(icon: Icons.lock_outline, hintText: "Password", obscure: true),
        const SizedBox(height: 20),
        _InputField(icon: Icons.lock_person_outlined, hintText: "Confirm Password", obscure: true),
        const SizedBox(height: 30),
        const _SignUpButton(),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool obscure;

  const _InputField({
    required this.icon,
    required this.hintText,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purple[300]),
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

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal[400],
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      child: Text("Sign Up", style: AppTextStyles.buttonPrimary),
    );
  }
}