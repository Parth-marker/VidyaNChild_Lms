import 'package:flutter/material.dart';

class SpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: 56.0,
    left: 24.0,
    bottom: 24.0,
    right: 24.0,
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              //Logo, header, notice
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    height: 150,
                    width: MediaQuery.sizeOf(context).width,
                    image: AssetImage('assets/images/VidyanChild_Logo.jpg'),
                    alignment: Alignment.center,
                  ),
                  Text(
                    'Login Page',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Access your assignments and learning resources',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              //login form
              Form(
                child: Column(
                  children: [
                    //Email
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                    const SizedBox(height: 16.0),

                    //Password
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 8.0),

                    //Remember me and Forgot Password
                    Row(
                      children: [
                        //Remember me
                        Row(
                          children: [
                            Checkbox(value: true, onChanged: (value){}),
                            const Text('Remember Me'),
                          ],
                        ),
                        //Forgot Passwork
                        TextButton(onPressed: (){}, child: const Text('Forgot Password')),
                      ],
                    ),
                    const SizedBox(height: 32.0),

                    //Sign In Button
                    ElevatedButton(onPressed: (){}, child: Text('Sign In')),
                    const SizedBox(height: 16.0),

                    //Create Account Button
                    OutlinedButton(onPressed: (){}, child: Text('Create Account')),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
