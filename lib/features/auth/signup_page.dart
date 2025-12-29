import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/provider/auth_provider.dart';

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

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool isStudent = true; // true for student, false for teacher

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputField(controller: nameController, icon: Icons.person_outline, hintText: "Full Name", obscure: false),
        const SizedBox(height: 20),
        _InputField(controller: emailController, icon: Icons.email_outlined, hintText: "Email", obscure: false),
        const SizedBox(height: 20),
        _InputField(controller: passwordController, icon: Icons.lock_outline, hintText: "Password", obscure: false),
        const SizedBox(height: 20),
        _InputField(controller: confirmPasswordController, icon: Icons.lock_person_outlined, hintText: "Confirm Password", obscure: false),
        const SizedBox(height: 20),
        _AccountTypeToggle(
          isStudent: isStudent,
          onChanged: (value) {
            setState(() {
              isStudent = value;
            });
          },
        ),
        const SizedBox(height: 30),
       Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return ElevatedButton(
          onPressed: () async {
            final accountType = isStudent ? 'student' : 'teacher';
            final res = await provider.signUp(nameController.text, emailController.text, passwordController.text, accountType);

            if(context.mounted){
              if(res){
                // Pop all routes back to root (AuthWrapper) which will handle routing based on account type
                // The auth state change will trigger AuthWrapper to rebuild and route correctly
                Navigator.of(context).popUntil((route) => route.isFirst);
              }else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went error")));
              }
            }
            
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
    )
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscure;

  const _InputField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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

class _AccountTypeToggle extends StatelessWidget {
  final bool isStudent;
  final ValueChanged<bool> onChanged;

  const _AccountTypeToggle({
    required this.isStudent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple[300]!, width: 2),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isStudent ? Colors.purple[300] : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Student',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: isStudent ? Colors.white : Colors.purple[300],
                    fontWeight: isStudent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isStudent ? Colors.purple[300] : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Teacher',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: !isStudent ? Colors.white : Colors.purple[300],
                    fontWeight: !isStudent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

