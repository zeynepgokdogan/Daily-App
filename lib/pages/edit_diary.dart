import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '/util/styles.dart';
import '/util/calendar.dart';

class EditDiary extends StatefulWidget {
  final String documentId;

  const EditDiary({super.key, required this.documentId});

  @override
  // ignore: library_private_types_in_public_api
  _EditDiaryState createState() => _EditDiaryState();
}

class _EditDiaryState extends State<EditDiary> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _selectedDate;
  String? _imageUrl;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _fetchData();
  }

  void _handleDateChanged(DateTime? selectedDate) {
    setState(() {
      _selectedDate = selectedDate;
    });
  }

  Future<void> _fetchData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('diary_entries')
        .doc(widget.documentId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _imageUrl = data['image_url'] as String?;
      _selectedDate = (data['timestamp'] as Timestamp?)?.toDate();
      setState(() {});
    }
  }

  Future<void> _updateEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      final entry = {
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
      } else if (_imageUrl != null) {
        entry['image_url'] = _imageUrl as Object;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('diary_entries')
          .doc(widget.documentId)
          .update(entry);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
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
              resizeToAvoidBottomInset: true,
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
                    'Edit Memory',
                    style: customTextStyle,
                  ),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Title',
                        hintStyle: hintTextStyle,
                      ),
                      style: customTextStyle,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Content',
                        hintStyle: hintTextStyle,
                      ),
                      style: customTextStyle,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: null,
                    ),
                    if (_imageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Image.file(
                          File(_imageFile!.path),
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Image.network(
                          _imageUrl!,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
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
                        Icons.update_sharp,
                        color: iconStyle().color,
                        size: iconStyle().size,
                      ),
                      onPressed: _updateEntry,
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
