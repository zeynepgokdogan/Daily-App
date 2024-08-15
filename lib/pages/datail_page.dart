import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetailPage extends StatefulWidget {
  final String documentId;

  const DetailPage({Key? key, required this.documentId}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _selectedDate;
  String? _imageUrl;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
      _titleController = TextEditingController(text: data['title'] ?? '');
      _contentController = TextEditingController(text: data['content'] ?? '');
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
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
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
                title: const Text('Edit Memory'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _updateEntry,
                  ),
                ],
              ),
              body: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('diary_entries')
                    .doc(widget.documentId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Memory not found.'));
                  }

                  final entry = snapshot.data!.data() as Map<String, dynamic>;
                  final title = entry['title'] ?? 'No Title';
                  final content = entry['content'] ?? 'No Content';
                  final timestamp = entry['timestamp'] as Timestamp?;
                  final date = timestamp != null
                      ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
                      : 'No Date';
                  final imageUrl = entry['image_url'] as String?;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Title',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          date,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Content',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
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
                        else if (imageUrl != null && imageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Image.network(
                              imageUrl,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Add Photo'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
