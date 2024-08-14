import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart';
import '/util/styles.dart';
import '/util/calendar.dart';

class Daily extends StatefulWidget {
  const Daily({Key? key}) : super(key: key);

  @override
  State<Daily> createState() => _DailyState();
}

class _DailyState extends State<Daily> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;

  // Method to handle date changes
  void _handleDateChanged(DateTime? selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      print(
          "Date received in Daily: ${_selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : 'None'}"); // Debug print
    });
  }

  // Method to save daily entry
  Future<void> _saveDaily() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    User? user = FirebaseAuth.instance.currentUser; // Get current user

    if (title.isNotEmpty && content.isNotEmpty && user != null) {
      await FirebaseFirestore.instance
          .collection('users') // Use 'users' collection
          .doc(user.uid) // User ID as document ID
          .collection('diary_entries') // Sub-collection for diary entries
          .add({
        'title': title,
        'content': content,
        'timestamp': _selectedDate != null
            ? Timestamp.fromDate(_selectedDate!)
            : FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _contentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Günlük başarıyla kaydedildi!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen tüm alanları doldurun veya giriş yapın')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Center(
              child: Text(
                'Add Memories',
                style: customTextStyle,
                textAlign: TextAlign.left,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Calendar(onDateChanged: _handleDateChanged),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _titleController,
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: hintTextStyle,
                      hintText: 'Title',
                    ),
                    style: customTextStyle,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    textAlign: TextAlign.left,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintStyle: customTextStyle,
                      hintText: 'Start typing...',
                    ),
                    style: customTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80.0, right: 15.0),
            child: Container(
              width: 120,
              height: 50,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color(0xFFF26950),
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: iconStyle().color,
                      size: iconStyle().size,
                    ),
                    onPressed: () {
                      // Fotoğraf eklemek için kod
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.save_alt_outlined,
                      color: iconStyle().color,
                      size: iconStyle().size,
                    ),
                    onPressed: _saveDaily,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
