import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatelessWidget {
  final String documentId;

  const DetailPage({Key? key, required this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Details'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('diary_entries')
            .doc(documentId)
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 8),
                Text(date,
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 16),
                Text(content),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child:
                        Image.network(imageUrl, height: 300, fit: BoxFit.cover),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
