import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: const Text('Daily'),
        ),
        toolbarHeight: kToolbarHeight, // AppBar yüksekliğini korur
      ),
      body: Stack(
        children: [
          // Arka plan resmi eklemek için bir Container kullanabilirsiniz
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background_image.jpg'), // Arka plan resmi dosya yolunu buraya ekleyin
                fit: BoxFit.cover, // Resmi kaplamak için fit methodu
              ),
            ),
          ),
          // Diğer bileşenler buraya eklenebilir
        ],
      ),
    );
  }
}
