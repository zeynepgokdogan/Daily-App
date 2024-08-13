import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _surname = '';
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 32),
              // Name field
              TextField(
                onChanged: (value) {
                  setState(() {
                    _name = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your Name',
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Surname field
              TextField(
                onChanged: (value) {
                  setState(() {
                    _surname = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your Surname',
                  labelText: 'Surname',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
              // Sign Up button
              ElevatedButton(
                onPressed: createAccount,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createAccount() async {
    try {
      // Create the user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      // Store additional user information in Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': _name,
        'surname': _surname,
        'email': _email.trim(),
      });

      print('User Created and Data Stored: $userCredential');

      // Optional: Navigate to another page or show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
    } catch (e) {
      print('Error: ${e.toString()}');
      if (e is FirebaseAuthException) {
        handleAuthError(e);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    }
  }

  void handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already in use. Please use a different email.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid. Please check and try again.';
        break;
      case 'weak-password':
        message =
            'The password is too weak. Please choose a stronger password.';
        break;
      default:
        message = 'Authentication error: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
