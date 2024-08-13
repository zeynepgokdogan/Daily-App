import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart'; // Import the SignUpPage
import 'home_page.dart'; // Import the HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FirebaseAuth auth;
  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 32),
              // Email field
              TextField(
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Password field
              TextField(
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Login button
              ElevatedButton(
                onPressed: () {
                  signInWithEmailAndPassword();
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 8),
              // Create Account button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signInWithEmailAndPassword() async {
    print('Attempting to sign in with email: $_email');
    try {
      var userCredential = await auth.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );
      print('User logged in: ${userCredential.user?.email}');

      // Navigate to HomePage after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print('Error: ${e.toString()}');
      if (e is FirebaseAuthException) {
        print('Error Code: ${e.code}');
        print('Error Message: ${e.message}');
      } else {
        print('Unexpected error: $e');
      }
    }
  }
}
