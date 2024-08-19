import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/edit_diary.dart';
import 'package:flutter_app/pages/add_diary.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/util/styles.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _saveAsPdf(BuildContext context) async {
    final pdf = pw.Document();
    final User? user = FirebaseAuth.instance.currentUser;

    // Define custom font
    final font = pw.Font.ttf(await rootBundle
        .load('assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf'));

    try {
      if (user == null) {
        print('No user signed in');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diary_entries')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        pdf.addPage(pw.Page(
          build: (pw.Context context) => pw.Center(
              child: pw.Text('No memories found.',
                  style: pw.TextStyle(font: font))),
        ));
      } else {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final title = data['title'] ?? 'No Title';
          final content = data['content'] ?? 'No Content';
          final timestamp = data['timestamp'] as Timestamp?;
          final date = timestamp != null
              ? DateFormat('dd MMM yyyy').format(timestamp.toDate())
              : 'No Date';
          final imageUrl = data['image_url'] as String?;

          // Fetch image data if the image URL is present
          pw.ImageProvider? image;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final response = await http.get(Uri.parse(imageUrl));
            if (response.statusCode == 200) {
              final imageBytes = response.bodyBytes;
              image = pw.MemoryImage(imageBytes);
            }
          }

          pdf.addPage(pw.Page(
            build: (pw.Context context) => pw.Padding(
              padding: pw.EdgeInsets.all(16.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          font: font)),
                  pw.SizedBox(height: 8),
                  pw.Text(content,
                      style: pw.TextStyle(fontSize: 16, font: font)),
                  pw.SizedBox(height: 8),
                  pw.Text(date,
                      style: pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey, font: font)),
                  if (image != null) ...[
                    pw.SizedBox(height: 16),
                    pw.Image(image),
                  ],
                ],
              ),
            ),
          ));
        }
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0),
              child: AppBar(
                title: const Text(
                  'MEMORIES',
                  style: appBarTextStyle,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/5.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _saveAsPdf(context),
                        icon: const Icon(
                          Icons.picture_as_pdf_outlined,
                        ),
                        color: accentColor,
                        iconSize: 30,
                      ),
                      IconButton(
                        icon: const Icon(Icons.power_settings_new),
                        color: accentColor,
                        iconSize: 30,
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0, right: 20.0, left: 20.0),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: user != null
                          ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('diary_entries')
                              .orderBy('timestamp', descending: true)
                              .snapshots()
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No memories found.'));
                        }

                        final entries = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry =
                                entries[index].data() as Map<String, dynamic>;
                            final title = entry['title'] ?? 'No Title';
                            final content = entry['content'] ?? 'No Content';
                            final timestamp = entry['timestamp'] as Timestamp?;
                            final date = timestamp != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(timestamp.toDate())
                                : 'No Date';
                            final imageUrl = entry['image_url'] as String?;
                            final documentId = entries[index].id;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FCFF),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                  color: const Color(0xFFF7C9C1),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16.0),
                                        title: Text(title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              content,
                                              maxLines: 6,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (imageUrl != null &&
                                                imageUrl.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Image.network(imageUrl,
                                                    height: 150,
                                                    fit: BoxFit.cover),
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditDiary(
                                                  documentId: documentId),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        date,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDiary(),
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
