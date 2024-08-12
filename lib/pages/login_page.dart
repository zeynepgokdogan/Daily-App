import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FirebaseAuth auth;
  String _email = 'zeufrefreıbg@gmail.com'; // Geçerli bir e-posta adresi
  String _password = 'password123';

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  createUserEmailAndPassword();
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
        email: _email.trim(), // E-posta adresini boşluklardan arındır
        password: _password,
      );
      print('Kullanıcı Oluşturuldu: $_userCredential');
    } catch (e) {
      // Özel Firebase Auth hatalarını ele al
      print('Hata: ${e.toString()}');
      if (e is FirebaseAuthException) {
        print('Hata Kodu: ${e.code}');
        print('Hata Mesajı: ${e.message}');
      } else {
        print('Beklenmeyen hata: $e');
      }
    }
  }
}
