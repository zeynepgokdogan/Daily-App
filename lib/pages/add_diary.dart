import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '/util/styles.dart';
import '/util/calendar.dart';

class AddDiary extends StatefulWidget {
  const AddDiary({super.key});

  @override
  State<AddDiary> createState() => _AddDiaryState();
}

class _AddDiaryState extends State<AddDiary> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;
  XFile? _imageFile;

  void _handleDateChanged(DateTime? selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
      // ignore: avoid_print
      print(
          "Date received in Daily: ${_selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : 'None'}");
    });
  }

  Future<void> _saveDaily() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    User? user = FirebaseAuth.instance.currentUser;

    if (title.isNotEmpty && content.isNotEmpty && user != null) {
      Map<String, dynamic> entry = {
        'title': title,
        'content': content,
        'timestamp': _selectedDate != null
            ? Timestamp.fromDate(_selectedDate!)
            : FieldValue.serverTimestamp(),
      };

      if (_imageFile != null) {
        try {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final ref = FirebaseStorage.instance
              .ref()
              .child('images')
              .child('$fileName.jpg');
          await ref.putFile(File(_imageFile!.path));
          final imageUrl = await ref.getDownloadURL();
          entry['image_url'] = imageUrl;
        } catch (e) {
          // ignore: avoid_print
          print('Error uploading image: $e');
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diary_entries')
          .add(entry);

      _titleController.clear();
      _contentController.clear();
      setState(() {
        _imageFile = null;
      });
      // ignore: use_build_context_synchronously
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera permission is required to pick images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: accentColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  'ADD MEMORY',
                  style: customTextStyle,
                  textAlign: TextAlign.left,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: SingleChildScrollView(
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
                      style:
                          customTextStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintStyle: customTextStyle,
                        hintText: 'Start typing...',
                      ),
                      style: customTextStyle,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: null,
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
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0
                  ? MediaQuery.of(context).viewInsets.bottom + 15.0
                  : 80.0,
              right: 15.0,
              child: Container(
                width: 120,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: primaryColor,
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
          ],
        );
      },
    );
  }
}
