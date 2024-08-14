import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _imageFile; // Variable to store the selected image

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
      Map<String, dynamic> entry = {
        'title': title,
        'content': content,
        'timestamp': _selectedDate != null
            ? Timestamp.fromDate(_selectedDate!)
            : FieldValue.serverTimestamp(),
      };

      // If an image is selected, add its URL to the entry
      if (_imageFile != null) {
        // Code to upload image and get the URL
        // For now, we'll just use a placeholder URL
        entry['image_url'] = 'URL_OF_THE_UPLOADED_IMAGE';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diary_entries')
          .add(entry);

      _titleController.clear();
      _contentController.clear();
      setState(() {
        _imageFile = null; // Clear selected image
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory saved Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all areas.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera permission is required to pick images.')),
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
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Image.file(
                        File(_imageFile!.path),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
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
                    onPressed: _pickImage,
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
