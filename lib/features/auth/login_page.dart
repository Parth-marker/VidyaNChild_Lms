import 'package:flutter/material.dart';
import 'package:lms_project/features/auth/signup_page.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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

                //Email field
                _TextFieldWidget(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                //Password field
                _TextFieldWidget(
                  controller: passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                _LoginButton(
                  loading: loading,
                  onPressed: () async {
                    setState(() => loading = true);

                    final error = await authProvider.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                    setState(() => loading = false);

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  }
                ),
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
  final TextEditingController controller;

  const _TextFieldWidget({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
  final bool loading;
  final VoidCallback onPressed;
  const _LoginButton({
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[300],
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      child: loading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text("Login", style: AppTextStyles.buttonPrimary),
    );
  }
}